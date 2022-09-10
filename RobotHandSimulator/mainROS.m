global nowMode;
global bigStateFlow;

rosNode = ros2node("rosSimNode");

ROSStrTopic = "See_it_2022_Str";
bigStateFlow = THE_VERY_REAL();
nowMode = "";

ros2subscriber(rosNode, ROSStrTopic, @ROSRobotStrHandle);

function ROSRobotVecHandle(msg)
    global nowMode;
    global bigStateFlow;
    
    rx = msg.angular.x;
    ry = msg.angular.y;
    rz = msg.angular.z;

    if nowMode == "HFMode"
        bigStateFlow.Rx = rx;
        bigStateFlow.Ry = ry;
        bigStateFlow.Rz = rz;
        if bigStateFlow.isBusy == 0
            % not busy
            bigStateFlow.HFMove();
        end
    end
end

function ROSRobotStrHandle(msg)
    global nowMode;
    global bigStateFlow;
    rosStr = msg.data;
    isJson = false;
    try
        jsonData = jsondecode(rosStr);
        isJson = true;
    catch

    end


    if rosStr =="GESTURE"
        bigStateFlow.ChangeToGesture()
        nowMode = "GMode";
    elseif rosStr == "HANDFREE"
        bigStateFlow.ChangeToHandFree()
        nowMode = "HFMode"; 
    else
        if nowMode == "GMode"

            if rosStr == "HOME"
                bigStateFlow.HOME();
            elseif rosStr == "GESTURE1"
                bigStateFlow.GoPart1();
            elseif rosStr == "GESTURE2"
                bigStateFlow.GoPart2();
            elseif rosStr == "GESTURE3"
                bigStateFlow.GoPart3();
            elseif rosStr == "GO_LEFT"
                bigStateFlow.GoTableLeft();
            elseif rosStr == "GO_RIGHT"
                bigStateFlow.GoTableRight();
            elseif rosStr == "GRAB"
                
                bigStateFlow.Grab();
            elseif rosStr == "DROP"
                bigStateFlow.Drop();
            end

        elseif nowMode == "HFMode"

            if rosStr == "GRAB"
                bigStateFlow.Grab();
            elseif rosStr == "DROP"
                bigStateFlow.Drop();
            elseif isJson
                bigStateFlow.Rx = jsonData.rx;
                bigStateFlow.Ry = jsonData.ry;
                bigStateFlow.Rz = jsonData.rz;
                if bigStateFlow.isBusy == 0
                    % not busy
                    bigStateFlow.HFMove();
                end
            end

        end

    end
end


