# Robot Hand Simulator

This program will receive a `ROS` data from [MQTT2ROS](/MQTT2ROS/) and respond in Simulation world in realtime.

## How it work

All of simulation world and interacting is write in State flow call `THE_VERY_REAL.sfx`
This include simulation world, animating robot arm, convert angle data to position xyz.

The main file `mainROS.m` will call `THE_VERY_REAL.sfx` and wait for ROS Command. when it receive a `ROS` data, it will call `THE_VERY_REAL.sfx` to show respond in Simulation world.

**THE MAIN TO RUN FILE IS** `mainROS.m`
