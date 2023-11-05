# Ka-50 Module capabilities

**Ka-50 Black Shark** is fitted with advanced piloting, navigation and sighting system **PrPNK Rubikon (L-041)** and **ABRIS**. Pilots interact with **Rubikon** through keyboard and display of **PVI-800** console, **HUD** and number of **switches** located on right side. **ABRIS** is completely separate **GPS** based navigation system. 

It is worth to note that there is a very limited interaction between 2 systems. Namely: **target points** selected with **PVI-800** can be displayed on **ABRIS** screen.

![Ka-50 BlackShark 3](images/ka-50_outside.jpg)

# Features

SharkPlanner supports entry of:

- up to **6 waypoints** into **PVI-800** (Rubikon),
- up to **4 fixpoints** into **PVI-800**,
- up to **9 target points** into **PVI-800**,
- up to **6 waypoints** into **ABRIS** (there is no technical limitation, but this feature is best used together with Rubikon, so limit was set to 6),
- up to **9 target points** into **ABRIS** (there is no technical limitation, but this feature is best used together with Rubikon, so limit was set to 9). 


## Entry of aircraft navigation waypoints

For entry of navigation waypoints please use the standard waypoint entry mode. Up to 6 waypoints can be entered. SharkPlanner will display the flight profile of the flight plan. 


| Description | Cockpit screenshot|
| --- | --- |
| After the transfer of waypoints, route will be selected for both ABRIS and Rubikon. You can toggle autopilot route following by hitting "R" button on your keyboard. Please ensure that pitch, bank and heading autopilot AXIS are activated on the autopilot panel. Otherwise the autopilot might not properly follow your route.  | ![waypoints designation](images/designation_of_aircraft_waypoints.png) |
| Flight plan in ABRIS | ![Flight plan in ABRIS](images/flight_plan_in_ABRIS.png) |
| Current Waypoint in PVI-800 | ![Current Waypoint in PVI-800](images/current_waypoint_PVI-800.png) |
| Current Waypoint in HUD, designated with rectangle on heading indiction | ![Current Waypoint in HUD](images/current_waypoint_HUD.png) |




## Entry of fix points

It is possible to enter up to 4 fix points. 

| Description | Cockpit screenshot|
| --- | --- |
| Fix points are used to calibrate the INS system (part of Rubikon) in flight based on the coordinates of known objects. To enter them you need to toggle **F**. After transfer, the entered missile waypoints will be shown used in different places. | ![missile waypoints designation](images/designation_of_fix_points.png) |
| Fix points in ABRIS: not implemented | <!-- ![ABRIS with fix points](images/entered_fix_points.png) --> |
| Fix point 1 in PVI-800 | ![Fix point 1 in PVI-800](images/fix_point_1_PVI-800.png) |


## Entry of target points

It is possible to enter up to 6 target points, these can be used to prepare the attack on ground targets. To enter them you need to toggle **T**.

| Description | Cockpit screenshot|
| --- | --- |
| Entry of target points | ![missile target points](images/designation_of_target_points.png) |
| Target point 1 in ABRIS <br> The Black mark in upper screen represents target.<br>You will notice the designation of PVI-800 target point.<br>Target in PVI-800 is different than target in ABRIS due to PVI-800 having less precision.| ![Target point 1 in ABRIS](images/entered_target_point_ABRIS.png) |
| Target point 1 in PVI-800 | ![Target point 1 in PVI-800](images/target_point_1_PVI-800.png) |
| Target point 1 in HUD, designated as circle with inside point. | ![Target point 1 in HUD](images/target_point_1_HUD.png) |

# Known limitations

- Target entry to PVI-800 does not allow you to directly slew SHKVAL onto target due to insufficient precision of entered coordinates. You will have to search the target in the general vicinity. For **latitude** the error is **185m**. For **longitude** it depends on latitude, but is generally from 90-110m for majority of maps.
- Entry of target points into ABRIS is experimental.
- Experimental target point may fail, and will the entry of waypoints. To fix this: reslot or reload the mission.
- PVI-800 offers reduced precision of entry compared to ABRIS. This is best seen when you select target point and compare the point entered into ABRIS. 
- Entry of FIX points is not yet implemented.

# References:

- DCS BS3 Flight Manual EN (e.g. C:\Program Files\Eagle Dynamics\DCS World OpenBeta\Mods\aircraft\Ka-50_3\Doc\DCS BS3 Flight Manual EN.pdf).
- [Chuck's Guide: DCS Guide - Ka-50 Black Shark](https://chucksguides.com/aircraft/dcs/ka-50/)