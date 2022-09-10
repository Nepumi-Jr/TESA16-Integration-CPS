# MQTT to ROS

This **GUI** program will receive a `MQTT` data and then convert into `ROS` and sent it to [RobotHandSimulation](/RobotHandSimulator/) via `ROS`

Other than converting, It can generate and simulate the `ROS` Data such as set an rotation angle, gestures

### THE MAIN FILE TO RUN IS `mqttAndRosController.mlapp`

## noted

This file is used to **hardcoded** the broker of mqtt. so If you want to use custom broker and auth, you can modify them on source code at line 157.

## code

This is the code. because matlab App are stored data in Binary not Text.

```matlab
classdef mqttAndRosController < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                       matlab.ui.Figure
        ROSPanel                       matlab.ui.container.Panel
        ROSSendEditField               matlab.ui.control.EditField
        ROSSendEditFieldLabel          matlab.ui.control.Label
        TabGroup                       matlab.ui.container.TabGroup
        initializeTab                  matlab.ui.container.Tab
        MQTTLamp                       matlab.ui.control.Lamp
        StartMQTTButton                matlab.ui.control.Button
        ROSLamp                        matlab.ui.control.Lamp
        StartROSButton                 matlab.ui.control.Button
        MQTTmonitorTab                 matlab.ui.container.Tab
        GestureEditField               matlab.ui.control.EditField
        GestureEditFieldLabel          matlab.ui.control.Label
        ModeEditField                  matlab.ui.control.EditField
        ModeEditFieldLabel             matlab.ui.control.Label
        ArmmoveEditField               matlab.ui.control.EditField
        ArmmoveEditFieldLabel          matlab.ui.control.Label
        WARNINGMQTTisntconnectedyetLabel  matlab.ui.control.Label
        MQTTRecieveLabel               matlab.ui.control.Label
        ROSHandFreeTab                 matlab.ui.container.Tab
        DropButton_2                   matlab.ui.control.Button
        GrabButton_2                   matlab.ui.control.Button
        IndegreeLabel                  matlab.ui.control.Label
        HFMoveButton                   matlab.ui.control.Button
        RzEditField                    matlab.ui.control.NumericEditField
        RzEditFieldLabel               matlab.ui.control.Label
        RyEditField                    matlab.ui.control.NumericEditField
        RyEditFieldLabel               matlab.ui.control.Label
        RxEditField                    matlab.ui.control.NumericEditField
        RxEditFieldLabel               matlab.ui.control.Label
        ROSHFLamp                      matlab.ui.control.Lamp
        HandFreeModeButton             matlab.ui.control.Button
        WARNINGROSisntstartedyetLabel  matlab.ui.control.Label
        ROSGestureTab                  matlab.ui.container.Tab
        HomeButton                     matlab.ui.control.Button
        TableRightButton               matlab.ui.control.Button
        TableLeftButton                matlab.ui.control.Button
        DropButton                     matlab.ui.control.Button
        GrabButton                     matlab.ui.control.Button
        ROSGesLamp                     matlab.ui.control.Lamp
        GestureModeButton              matlab.ui.control.Button
        WARNINGROSisntstartedyetLabel_2  matlab.ui.control.Label
        Part3Button                    matlab.ui.control.Button
        Part2Button                    matlab.ui.control.Button
        Part1Button                    matlab.ui.control.Button
        AuthorTab                      matlab.ui.container.Tab
        Member4_2                      matlab.ui.control.Label
        TeamAdvisorLabel               matlab.ui.control.Label
        Member5                        matlab.ui.control.Label
        Member4                        matlab.ui.control.Label
        Member3                        matlab.ui.control.Label
        Member2                        matlab.ui.control.Label
        Member1                        matlab.ui.control.Label
        TeamMemberLabel                matlab.ui.control.Label
        SeeIt2022Label                 matlab.ui.control.Label
        Image                          matlab.ui.control.Image
        banner_bottom                  matlab.ui.control.Image
        banner_top                     matlab.ui.control.Image
    end


    properties (Access = private)
        ROScliNode
        ROSResNode
        ROSStrPub
        ROSVecPub
        ROSStrTopic = "See_it_2022_Str";
        ROSREVTopic = "it_See_2022_Str";

        mqttClient
        mqttFingerTopic = "See_it2022/glove/grasp"; % See_it2022/simulation/glove/grasp
        mqttArmTopic = "See_it2022/arm/move";
        mqttmodeTopic = "See_it2022/mode";
        mqttGestureTopic = "See_it2022/gesture";

        RobotMode;
    end

    methods (Access = private)

        function handleMQTTmsg(app, topic, data)
            fprintf("GUI << receive MQTT Data : %s\n",data);

            if topic == app.mqttArmTopic
                app.ArmmoveEditField.Value = data;
            elseif topic == app.mqttmodeTopic
                app.ModeEditField.value = data;
            elseif topic == app.mqttGestureTopic
                app.GestureEditField.Value = data;
            end

            jsonData = jsondecode(data);

            if topic == app.mqttmodeTopic
                app.changeGloveMode(jsonData.mode)

            elseif topic == app.mqttGestureTopic
                if app.RobotMode == "gesture"
                    gCode = jsonData.gesture;
                    if gCode == 1
                        app.ROSSendStringData('GESTURE1');
                    elseif gCode == 2
                        app.ROSSendStringData('GESTURE2');
                    elseif gCode == 3
                        app.ROSSendStringData('GESTURE3');
                    elseif gCode == 4
                        app.ROSSendStringData('GO_LEFT');
                    elseif gCode == 5
                        app.ROSSendStringData('GO_RIGHT');
                    elseif gCode == 6
                        app.ROSSendStringData('GRAB');
                    elseif gCode == 7
                        app.ROSSendStringData('DROP');
                    elseif gCode == 8
                        app.ROSSendStringData('HOME');
                    end

                elseif app.RobotMode == "free-hand"
                    gCode = jsonData.gesture;
                    if gCode == 6
                        app.ROSSendStringData('GRAB');
                    elseif gCode == 7
                        app.ROSSendStringData('DROP');
                    end
                end
            elseif topic == app.mqttFingerTopic
                if json.Index_finger >= 1600
                    app.ROSSendStringData('DROP');
                elseif json.Index_finger <= 1400
                    app.ROSSendStringData('GRAB');
                end
            elseif topic == app.mqttArmTopic
                if app.RobotMode == "free-hand"
                    rx = mod(deg2rad(jsonData.Pitch), 2*pi);
                    ry = mod(deg2rad(jsonData.Roll), 2*pi);
                    rz = mod(deg2rad(jsonData.Yaw), 2*pi);

                    app.ROSSendStringData(sprintf('{"rx" : %g , "ry" : %g , "rz" : %g}', rx, ry, rz));
                end

            end

        end

%         function handleROSMsg(app, msg)
%             rosStr = msg.data;
%             fprintf("GOOD BACK %s !\n", rosStr);
%         end

        function statusCode = initializeMqttVariable(app)
            fprintf("Begin init mqtt variables\n");
            try
                % HARD CODED
                % Try to change this one
                app.mqttClient = mqttclient("SOME Broker", "Username", "USER_NAME", ...
                    "Password", "PASS_WORD", ...
                    "Port", "PORT");

                subscribe(app.mqttClient, app.mqttFingerTopic, "Callback", @app.handleMQTTmsg);
                subscribe(app.mqttClient, app.mqttArmTopic, "Callback", @app.handleMQTTmsg);
                fprintf("Success!\n");
                statusCode = true;
            catch error
                disp(error)
                statusCode = false;
            end
        end

        function statusCode = initializeRosVariable(app)
            disp("Enter initialize ROS variables...")
            try
                app.ROScliNode = ros2node("cliNode");
                app.ROSStrPub = ros2publisher(app.ROScliNode, app.ROSStrTopic, "std_msgs/String");

                app.ROSResNode = ros2node("cliBackNode");
                %ros2subscriber(app.ROSResNode, app.ROSREVTopic, @app.handleROSMsg);
                disp("Success!")
                statusCode = true;
            catch error
                disp(error)
                statusCode = false;
            end
        end


        function ROSSendStringData(app, msg)
            thisROSMsg = ros2message(app.ROSStrPub);
            thisROSMsg.data = msg;
            app.ROSSendEditField.Value = msg;
            fprintf("GUI >> send ROS Data : %s\n",msg);
            send(app.ROSStrPub, thisROSMsg);
        end

        function changeGloveMode(app, mode)
            if mode == "gesture"
                app.ROSSendStringData('GESTURE');
                app.ROSGesLamp.Color = 'G';
                app.ROSHFLamp.Color = [0.40, 0.04, 0.04];
                app.RobotMode = mode;
            elseif mode == "free-hand"
                app.ROSSendStringData('HANDFREE');
                app.ROSHFLamp.Color = 'G';
                app.ROSGesLamp.Color = [0.40, 0.04, 0.04];
                app.RobotMode = mode;
            end
        end
    end


    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            % initialize MQTT
            % DEV ONLY please do not put it in production!
%             app.MQTTbrokerEditField.Value = "tcp://159.223.39.71";
%             app.PortCheckBox.Value = true;
%             app.userAuthCheckBox.Value = true;
%             app.UserEditField.Value = "cps-see-it2022";
%             app.PasswordHTMLField.Data = "daranee";
            % initialize robot setting
        end

        % Callback function
        function ConnectButtonPushed(app, event)
            app.ConnectButton.Enable = "off";
            if app.PortCheckBox.Value && app.userAuthCheckBox.Value
                disp(app.PasswordHTMLField.get.Data);
                fprintf("Password is %s", app.PasswordHTMLField.get.Data);
                app.mqttClient = mqttclient(app.MQTTbrokerEditField.Value, "Username", app.UserEditField.Value, ...
                    "Password", app.PasswordHTMLField.get.Data, ...
                    "Port", app.PortEditField.Value);
                disp(app.mqttClient)
                class(app.mqttClient)
            end
            if app.mqttClient.Connected == 1
                app.ConnectButton.Text = "Connected";
                app.StatusLamp.Color = 'g';
                app.mqttCmdSub = subscribe(app.mqttClient, app.mqttTopic,Callback=@app.handleMQTTmsg);
            end
            app.initializeMqttVariable();
            fprintf("mqtt arm sub...\n");
            app.mqttArmSub;
            fprintf("mqtt finger sub...\n");
            app.mqttFingerSub;
            app.WARNINGMQTTisntconnectedyetLabel.Visible = "off";
            app.ConnectButton.Enable = "on";
        end

        % Callback function
        function HOMEButtonPushed(app, event)

        end

        % Close request function: UIFigure
        function UIFigureCloseRequest(app, event)
            delete(app)
            close all;
        end

        % Callback function
        function STARTButtonPushed(app, event)

        end

        % Callback function
        function YButton_PosPushed(app, event)

        end

        % Callback function
        function ZButton_NegPushed(app, event)
            app.robotMove(0, 0, -0.05);
        end

        % Callback function
        function ZButton_PosPushed(app, event)
            app.robotMove(0, 0, 0.05);
        end

        % Callback function
        function YButton_NegPushed(app, event)
            app.robotMove(0, -0.05, 0);
        end

        % Callback function
        function XButton_PosPushed(app, event)
            app.robotMove(0.05, 0, 0);
        end

        % Callback function
        function XButton_NegPushed(app, event)
            app.robotMove(-0.05, 0, 0);
        end

        % Callback function
        function ButtonPushed(app, event)

        end

        % Callback function
        function Button_2Pushed(app, event)

        end

        % Callback function
        function PartSpinnerValueChanged(app, event)

        end

        % Callback function
        function xEditFieldValueChanged(app, event)

        end

        % Callback function
        function yEditFieldValueChanged(app, event)

        end

        % Callback function
        function zEditFieldValueChanged(app, event)

        end

        % Callback function
        function GripButtonValueChanged(app, event)

        end

        % Callback function
        function GrabButtonPushed(app, event)
            % Grab Debug Just Debug
            if app.GrabButton.Text == "Grab"
                status = app.gripPart();
                if status
                    app.GrabButton.Text = "Drop";
                end
            else
                status = app.dropPart();
                if status
                    app.GrabButton.Text = "Grab";
                end
            end
        end

        % Callback function
        function PortCheckBoxValueChanged(app, event)
            value = app.PortCheckBox.Value;
            if value
                app.PortEditField.Enable = "on";
            else
                app.PortEditField.Enable = "off";
            end
        end

        % Callback function
        function userAuthCheckBoxValueChanged(app, event)
            value = app.userAuthCheckBox.Value;
            if value
                app.UserEditField.Enable = "on";
                app.PasswordHTMLField.Visible = "on";
            else
                app.UserEditField.Enable = "off";
                app.PasswordHTMLField.Visible = "off";
            end
        end

        % Button pushed function: Part1Button
        function Part1ButtonPushed(app, event)
            app.ROSSendStringData('GESTURE1');
        end

        % Button pushed function: Part2Button
        function Part2ButtonPushed(app, event)
            app.ROSSendStringData('GESTURE2');
        end

        % Button pushed function: Part3Button
        function Part3ButtonPushed(app, event)
            app.ROSSendStringData('GESTURE3');
        end

        % Button pushed function: HandFreeModeButton
        function HandFreeModeButtonPushed(app, event)
            app.changeGloveMode("free-hand")
        end

        % Callback function
        function GestureButtonPushed(app, event)

        end

        % Callback function
        function MQTTHFMoveButtonPushed(app, event)
            app.rosMsg = ros2message(app.pub);
            app.rosMsg.data = 'HF'; % GADGET
            fprintf("send ROS : %s\n",msg);
        end

        % Callback function
        function GoLEFTButtonPushed(app, event)
            app.ROSSendStringData('GO_LEFT');
        end

        % Callback function
        function GoRIGHTButtonPushed(app, event)
            app.ROSSendStringData('GO_RIGHT');
        end

        % Callback function
        function GrabButtonPushed2(app, event)
            app.ROSSendStringData('GRAB');
        end

        % Callback function
        function DropButtonPushed(app, event)
            app.ROSSendStringData('DROP');
        end

        % Button pushed function: StartROSButton
        function StartROSButtonPushed(app, event)
            app.StartROSButton.Text = "Starting ros...";
            app.StartROSButton.Enable = "off";
            pause(0.05);
            isComplete = app.initializeRosVariable();
            if isComplete
                app.StartROSButton.Text = "Started ros";
                app.ROSLamp.Color = "G";

                app.WARNINGROSisntstartedyetLabel.Visible = "off";
                app.WARNINGROSisntstartedyetLabel_2.Visible = "off";

            else
                app.StartROSButton.Text = "Failed ROS";
                app.ROSLamp.Color = "R";
            end
        end

        % Button pushed function: GestureModeButton
        function GestureModeButtonPushed(app, event)
            app.changeGloveMode("gesture")
        end

        % Button pushed function: TableLeftButton
        function TableLeftButtonPushed(app, event)
            app.ROSSendStringData('GO_LEFT');
        end

        % Button pushed function: TableRightButton
        function TableRightButtonPushed(app, event)
            app.ROSSendStringData('GO_RIGHT');
        end

        % Button pushed function: HomeButton
        function HomeButtonPushed(app, event)
            app.ROSSendStringData('HOME');
        end

        % Button pushed function: DropButton
        function DropButtonPushed2(app, event)
            app.ROSSendStringData('DROP');
        end

        % Button pushed function: GrabButton
        function GrabButtonPushed3(app, event)
            app.ROSSendStringData('GRAB');
        end

        % Button pushed function: HFMoveButton
        function HFMoveButtonPushed(app, event)
            rx = mod(deg2rad(app.RxEditField.Value), 2*pi);
            ry = mod(deg2rad(app.RyEditField.Value), 2*pi);
            rz = mod(deg2rad(app.RzEditField.Value), 2*pi);

            app.ROSSendStringData(sprintf('{"rx" : %g , "ry" : %g , "rz" : %g}', rx, ry, rz));
        end

        % Button pushed function: GrabButton_2
        function GrabButton_2Pushed(app, event)
            app.ROSSendStringData('GRAB');
        end

        % Button pushed function: DropButton_2
        function DropButton_2Pushed(app, event)
            app.ROSSendStringData('Drop');
        end

        % Button pushed function: StartMQTTButton
        function StartMQTTButtonPushed(app, event)
            app.initializeMqttVariable();
            app.StartMQTTButton.Text = "Starting mqtt...";
            app.StartMQTTButton.Enable = "off";
            pause(0.05);
            isComplete = app.initializeMqttVariable();
            if isComplete
                app.StartMQTTButton.Text = "Started mqtt";
                app.MQTTLamp.Color = "G";

                app.WARNINGMQTTisntconnectedyetLabel.Visible = "off";

            else
                app.StartMQTTButton.Text = "Failed mqtt";
                app.MQTTLamp.Color = "R";
            end
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Get the file path for locating images
            pathToMLAPP = fileparts(mfilename('fullpath'));

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Color = [0.6549 0.2314 0.1412];
            app.UIFigure.Position = [100 100 687 598];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.CloseRequestFcn = createCallbackFcn(app, @UIFigureCloseRequest, true);

            % Create banner_top
            app.banner_top = uiimage(app.UIFigure);
            app.banner_top.Position = [3 364 687 243];
            app.banner_top.ImageSource = 'banner_top.jpg';

            % Create banner_bottom
            app.banner_bottom = uiimage(app.UIFigure);
            app.banner_bottom.Position = [5 2 685 88];
            app.banner_bottom.ImageSource = fullfile(pathToMLAPP, 'banner_bottom.jpg');

            % Create TabGroup
            app.TabGroup = uitabgroup(app.UIFigure);
            app.TabGroup.Position = [42 195 610 170];

            % Create initializeTab
            app.initializeTab = uitab(app.TabGroup);
            app.initializeTab.Title = 'initialize';

            % Create StartROSButton
            app.StartROSButton = uibutton(app.initializeTab, 'push');
            app.StartROSButton.ButtonPushedFcn = createCallbackFcn(app, @StartROSButtonPushed, true);
            app.StartROSButton.Position = [244 96 121 31];
            app.StartROSButton.Text = 'Start ROS';

            % Create ROSLamp
            app.ROSLamp = uilamp(app.initializeTab);
            app.ROSLamp.Position = [210 100 20 20];
            app.ROSLamp.Color = [0.4 0.0353 0.0353];

            % Create StartMQTTButton
            app.StartMQTTButton = uibutton(app.initializeTab, 'push');
            app.StartMQTTButton.ButtonPushedFcn = createCallbackFcn(app, @StartMQTTButtonPushed, true);
            app.StartMQTTButton.Position = [245 46 122 31];
            app.StartMQTTButton.Text = 'Start MQTT';

            % Create MQTTLamp
            app.MQTTLamp = uilamp(app.initializeTab);
            app.MQTTLamp.Position = [211 50 20 20];
            app.MQTTLamp.Color = [0.4 0.0353 0.0353];

            % Create MQTTmonitorTab
            app.MQTTmonitorTab = uitab(app.TabGroup);
            app.MQTTmonitorTab.Title = 'MQTT monitor';

            % Create MQTTRecieveLabel
            app.MQTTRecieveLabel = uilabel(app.MQTTmonitorTab);
            app.MQTTRecieveLabel.FontSize = 16;
            app.MQTTRecieveLabel.FontWeight = 'bold';
            app.MQTTRecieveLabel.Position = [22 113 115 22];
            app.MQTTRecieveLabel.Text = 'MQTT Recieve';

            % Create WARNINGMQTTisntconnectedyetLabel
            app.WARNINGMQTTisntconnectedyetLabel = uilabel(app.MQTTmonitorTab);
            app.WARNINGMQTTisntconnectedyetLabel.HorizontalAlignment = 'right';
            app.WARNINGMQTTisntconnectedyetLabel.FontColor = [1 0 0];
            app.WARNINGMQTTisntconnectedyetLabel.Position = [372 113 213 22];
            app.WARNINGMQTTisntconnectedyetLabel.Text = 'WARNING : MQTT isn''t connected yet.';

            % Create ArmmoveEditFieldLabel
            app.ArmmoveEditFieldLabel = uilabel(app.MQTTmonitorTab);
            app.ArmmoveEditFieldLabel.HorizontalAlignment = 'right';
            app.ArmmoveEditFieldLabel.Position = [23 83 85 22];
            app.ArmmoveEditFieldLabel.Text = 'Arm move';

            % Create ArmmoveEditField
            app.ArmmoveEditField = uieditfield(app.MQTTmonitorTab, 'text');
            app.ArmmoveEditField.Editable = 'off';
            app.ArmmoveEditField.Position = [123 83 456 22];

            % Create ModeEditFieldLabel
            app.ModeEditFieldLabel = uilabel(app.MQTTmonitorTab);
            app.ModeEditFieldLabel.HorizontalAlignment = 'right';
            app.ModeEditFieldLabel.Position = [24 55 85 22];
            app.ModeEditFieldLabel.Text = 'Mode';

            % Create ModeEditField
            app.ModeEditField = uieditfield(app.MQTTmonitorTab, 'text');
            app.ModeEditField.Editable = 'off';
            app.ModeEditField.Position = [124 55 456 22];

            % Create GestureEditFieldLabel
            app.GestureEditFieldLabel = uilabel(app.MQTTmonitorTab);
            app.GestureEditFieldLabel.HorizontalAlignment = 'right';
            app.GestureEditFieldLabel.Position = [24 25 85 22];
            app.GestureEditFieldLabel.Text = 'Gesture';

            % Create GestureEditField
            app.GestureEditField = uieditfield(app.MQTTmonitorTab, 'text');
            app.GestureEditField.Editable = 'off';
            app.GestureEditField.Position = [124 25 456 22];

            % Create ROSHandFreeTab
            app.ROSHandFreeTab = uitab(app.TabGroup);
            app.ROSHandFreeTab.Title = 'ROS HandFree';

            % Create WARNINGROSisntstartedyetLabel
            app.WARNINGROSisntstartedyetLabel = uilabel(app.ROSHandFreeTab);
            app.WARNINGROSisntstartedyetLabel.HorizontalAlignment = 'right';
            app.WARNINGROSisntstartedyetLabel.FontColor = [1 0 0];
            app.WARNINGROSisntstartedyetLabel.Position = [405 109 193 31];
            app.WARNINGROSisntstartedyetLabel.Text = 'WARNING : ROS isn''t started yet.';

            % Create HandFreeModeButton
            app.HandFreeModeButton = uibutton(app.ROSHandFreeTab, 'push');
            app.HandFreeModeButton.ButtonPushedFcn = createCallbackFcn(app, @HandFreeModeButtonPushed, true);
            app.HandFreeModeButton.Position = [67 108 122 23];
            app.HandFreeModeButton.Text = 'Hand Free Mode';

            % Create ROSHFLamp
            app.ROSHFLamp = uilamp(app.ROSHandFreeTab);
            app.ROSHFLamp.Position = [35 110 20 20];
            app.ROSHFLamp.Color = [0.4 0.0353 0.0353];

            % Create RxEditFieldLabel
            app.RxEditFieldLabel = uilabel(app.ROSHandFreeTab);
            app.RxEditFieldLabel.HorizontalAlignment = 'right';
            app.RxEditFieldLabel.Position = [23 75 25 22];
            app.RxEditFieldLabel.Text = 'Rx';

            % Create RxEditField
            app.RxEditField = uieditfield(app.ROSHandFreeTab, 'numeric');
            app.RxEditField.Position = [63 75 70 22];

            % Create RyEditFieldLabel
            app.RyEditFieldLabel = uilabel(app.ROSHandFreeTab);
            app.RyEditFieldLabel.HorizontalAlignment = 'right';
            app.RyEditFieldLabel.Position = [158 75 25 22];
            app.RyEditFieldLabel.Text = 'Ry';

            % Create RyEditField
            app.RyEditField = uieditfield(app.ROSHandFreeTab, 'numeric');
            app.RyEditField.Position = [198 75 70 22];

            % Create RzEditFieldLabel
            app.RzEditFieldLabel = uilabel(app.ROSHandFreeTab);
            app.RzEditFieldLabel.HorizontalAlignment = 'right';
            app.RzEditFieldLabel.Position = [313 75 25 22];
            app.RzEditFieldLabel.Text = 'Rz';

            % Create RzEditField
            app.RzEditField = uieditfield(app.ROSHandFreeTab, 'numeric');
            app.RzEditField.Position = [353 75 70 22];

            % Create HFMoveButton
            app.HFMoveButton = uibutton(app.ROSHandFreeTab, 'push');
            app.HFMoveButton.ButtonPushedFcn = createCallbackFcn(app, @HFMoveButtonPushed, true);
            app.HFMoveButton.Position = [517 75 69 23];
            app.HFMoveButton.Text = 'HFMove';

            % Create IndegreeLabel
            app.IndegreeLabel = uilabel(app.ROSHandFreeTab);
            app.IndegreeLabel.HorizontalAlignment = 'right';
            app.IndegreeLabel.FontColor = [1 0 0];
            app.IndegreeLabel.Position = [429 67 61 31];
            app.IndegreeLabel.Text = '**In degree';

            % Create GrabButton_2
            app.GrabButton_2 = uibutton(app.ROSHandFreeTab, 'push');
            app.GrabButton_2.ButtonPushedFcn = createCallbackFcn(app, @GrabButton_2Pushed, true);
            app.GrabButton_2.Position = [136 29 100 23];
            app.GrabButton_2.Text = 'Grab';

            % Create DropButton_2
            app.DropButton_2 = uibutton(app.ROSHandFreeTab, 'push');
            app.DropButton_2.ButtonPushedFcn = createCallbackFcn(app, @DropButton_2Pushed, true);
            app.DropButton_2.Position = [339 29 100 23];
            app.DropButton_2.Text = 'Drop';

            % Create ROSGestureTab
            app.ROSGestureTab = uitab(app.TabGroup);
            app.ROSGestureTab.Title = 'ROS Gesture';

            % Create Part1Button
            app.Part1Button = uibutton(app.ROSGestureTab, 'push');
            app.Part1Button.ButtonPushedFcn = createCallbackFcn(app, @Part1ButtonPushed, true);
            app.Part1Button.Position = [73 75 100 23];
            app.Part1Button.Text = 'Part 1';

            % Create Part2Button
            app.Part2Button = uibutton(app.ROSGestureTab, 'push');
            app.Part2Button.ButtonPushedFcn = createCallbackFcn(app, @Part2ButtonPushed, true);
            app.Part2Button.Position = [73 49 100 23];
            app.Part2Button.Text = 'Part 2';

            % Create Part3Button
            app.Part3Button = uibutton(app.ROSGestureTab, 'push');
            app.Part3Button.ButtonPushedFcn = createCallbackFcn(app, @Part3ButtonPushed, true);
            app.Part3Button.Position = [73 23 100 23];
            app.Part3Button.Text = 'Part 3';

            % Create WARNINGROSisntstartedyetLabel_2
            app.WARNINGROSisntstartedyetLabel_2 = uilabel(app.ROSGestureTab);
            app.WARNINGROSisntstartedyetLabel_2.HorizontalAlignment = 'right';
            app.WARNINGROSisntstartedyetLabel_2.FontColor = [1 0 0];
            app.WARNINGROSisntstartedyetLabel_2.Position = [405 109 193 31];
            app.WARNINGROSisntstartedyetLabel_2.Text = 'WARNING : ROS isn''t started yet.';

            % Create GestureModeButton
            app.GestureModeButton = uibutton(app.ROSGestureTab, 'push');
            app.GestureModeButton.ButtonPushedFcn = createCallbackFcn(app, @GestureModeButtonPushed, true);
            app.GestureModeButton.Position = [67 108 122 23];
            app.GestureModeButton.Text = 'Gesture Mode';

            % Create ROSGesLamp
            app.ROSGesLamp = uilamp(app.ROSGestureTab);
            app.ROSGesLamp.Position = [35 110 20 20];
            app.ROSGesLamp.Color = [0.4 0.0392 0.0392];

            % Create GrabButton
            app.GrabButton = uibutton(app.ROSGestureTab, 'push');
            app.GrabButton.ButtonPushedFcn = createCallbackFcn(app, @GrabButtonPushed3, true);
            app.GrabButton.Position = [430 75 100 23];
            app.GrabButton.Text = 'Grab';

            % Create DropButton
            app.DropButton = uibutton(app.ROSGestureTab, 'push');
            app.DropButton.ButtonPushedFcn = createCallbackFcn(app, @DropButtonPushed2, true);
            app.DropButton.Position = [430 51 100 23];
            app.DropButton.Text = 'Drop';

            % Create TableLeftButton
            app.TableLeftButton = uibutton(app.ROSGestureTab, 'push');
            app.TableLeftButton.ButtonPushedFcn = createCallbackFcn(app, @TableLeftButtonPushed, true);
            app.TableLeftButton.Position = [254 75 100 23];
            app.TableLeftButton.Text = 'Table Left';

            % Create TableRightButton
            app.TableRightButton = uibutton(app.ROSGestureTab, 'push');
            app.TableRightButton.ButtonPushedFcn = createCallbackFcn(app, @TableRightButtonPushed, true);
            app.TableRightButton.Position = [254 49 100 23];
            app.TableRightButton.Text = 'Table Right';

            % Create HomeButton
            app.HomeButton = uibutton(app.ROSGestureTab, 'push');
            app.HomeButton.ButtonPushedFcn = createCallbackFcn(app, @HomeButtonPushed, true);
            app.HomeButton.Position = [254 23 100 23];
            app.HomeButton.Text = 'Home';

            % Create AuthorTab
            app.AuthorTab = uitab(app.TabGroup);
            app.AuthorTab.Title = 'Author';

            % Create Image
            app.Image = uiimage(app.AuthorTab);
            app.Image.Position = [29 27 100 100];
            app.Image.ImageSource = fullfile(pathToMLAPP, 'KKULogo.png');

            % Create SeeIt2022Label
            app.SeeIt2022Label = uilabel(app.AuthorTab);
            app.SeeIt2022Label.FontSize = 18;
            app.SeeIt2022Label.FontWeight = 'bold';
            app.SeeIt2022Label.FontAngle = 'italic';
            app.SeeIt2022Label.Position = [129 104 100 23];
            app.SeeIt2022Label.Text = 'See-It-2022';

            % Create TeamMemberLabel
            app.TeamMemberLabel = uilabel(app.AuthorTab);
            app.TeamMemberLabel.FontSize = 14;
            app.TeamMemberLabel.FontWeight = 'bold';
            app.TeamMemberLabel.FontAngle = 'italic';
            app.TeamMemberLabel.Position = [139 82 99 22];
            app.TeamMemberLabel.Text = 'Team Member';

            % Create Member1
            app.Member1 = uilabel(app.AuthorTab);
            app.Member1.FontSize = 14;
            app.Member1.Position = [139 61 130 22];
            app.Member1.Text = '- นายเชี่ยวชาญ พลศรี';

            % Create Member2
            app.Member2 = uilabel(app.AuthorTab);
            app.Member2.FontSize = 14;
            app.Member2.Position = [139 40 135 22];
            app.Member2.Text = '- นายเมธี ยิ่งยงวัฒนกิจ';

            % Create Member3
            app.Member3 = uilabel(app.AuthorTab);
            app.Member3.FontSize = 14;
            app.Member3.Position = [139 19 127 22];
            app.Member3.Text = '- นายพีรพล สุดภู่ทอง';

            % Create Member4
            app.Member4 = uilabel(app.AuthorTab);
            app.Member4.FontSize = 14;
            app.Member4.Position = [286 62 153 22];
            app.Member4.Text = '- นายพีร์พัทธ ขานทะราชา';

            % Create Member5
            app.Member5 = uilabel(app.AuthorTab);
            app.Member5.FontSize = 14;
            app.Member5.Position = [286 41 135 22];
            app.Member5.Text = '- นายจิราวัฒน์ กุระขันธ์';

            % Create TeamAdvisorLabel
            app.TeamAdvisorLabel = uilabel(app.AuthorTab);
            app.TeamAdvisorLabel.FontSize = 14;
            app.TeamAdvisorLabel.FontWeight = 'bold';
            app.TeamAdvisorLabel.FontAngle = 'italic';
            app.TeamAdvisorLabel.Position = [481 82 97 22];
            app.TeamAdvisorLabel.Text = 'Team Advisor';

            % Create Member4_2
            app.Member4_2 = uilabel(app.AuthorTab);
            app.Member4_2.FontSize = 14;
            app.Member4_2.Position = [472 61 117 22];
            app.Member4_2.Text = 'ผศ.ดร.ดารณี หอมดี';

            % Create ROSPanel
            app.ROSPanel = uipanel(app.UIFigure);
            app.ROSPanel.Title = 'ROS';
            app.ROSPanel.Position = [43 99 608 84];

            % Create ROSSendEditFieldLabel
            app.ROSSendEditFieldLabel = uilabel(app.ROSPanel);
            app.ROSSendEditFieldLabel.HorizontalAlignment = 'right';
            app.ROSSendEditFieldLabel.Position = [47 31 62 22];
            app.ROSSendEditFieldLabel.Text = 'ROS Send';

            % Create ROSSendEditField
            app.ROSSendEditField = uieditfield(app.ROSPanel, 'text');
            app.ROSSendEditField.Editable = 'off';
            app.ROSSendEditField.Position = [124 31 456 22];

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = mqttAndRosController

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end
```
