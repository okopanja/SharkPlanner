# JF-17 Module capabilities

JF-17 offers a rather attractive selection of precision ammunition, which combined with the advanced navigation system enables not only precision navigation, but also a selection of interesting tactics based on pre planning of flights and targets.
Normally interaction takes place through and F10 map and DTC mechanism, which limits the updates only to ground. The users can update the data inside navigation system through UFCP or onboard sensors. In case of UFCP this can be a bit cumbersome and labor intensive.

SharkPlanner can help with enabling you to:
- update flight plan during the flight with less effort and more precision,
- save the flight plan for future use into file,
- load the flight plan from file.

![JF-17 armed with 2 cruise missiles and a datalink pod](images/jf-17_outside.jpg)

# Features

Following table provides the overview of different types of points, along the information on how they can be entered using SharkPlanner. For most accurate information on how to use different weapons and sensors, please consult the documentation references listed at the end of this document. 

| Range | Purpose | SharkPlanner |
| --- | --- | --- |
| 00 | Aircraft position for INS alignment | Not implemented |
| 01-29 | Flight plan FP-A | Implemented, use **W** toggle |
| 30-35 | Route points | Implemented, use **F** toggle | 
| 36-39 | Pre planned points | Implemented, use **T** toggle |
| 40 | SPI point | Not applicable |
| 41-49 | Mark points | Not implemented at this time, need to learn more about mark points |
| 50-59 | Nearest airports | Not applicable |

## Entry of aircraft navigation waypoints

| Description | Cockpit screenshot|
| --- | --- |
| For entry of navigation waypoints please use the standard **waypoint entry mode**. Up to **29** waypoints can be entered. **Elevation** is by default set to **altitude**. User can modify elevation and delta will be displayed above.<br>Once you trigger the transfer of waypoints, you can find them in **left MFCD** within **DST** page. You can use MAN/AUTO mode to automatically switch to next waypoint or use UFCP to select the waypoint by entering it's number.  | ![waypoints designation](images/designation_of_aircraft_waypoints.png) | 
| DST page with entered waypoints | ![DST page with entered waypoints](images/entered_aircraft_waypoints_dst_page.png) |
| HSD page with entered waypoints | ![HSD page with entered waypoints](images/entered_aircraft_waypoints_hsd_page.png) |


## Entry of cruise missile waypoints (30-35)

After transfer, the entered missile waypoints will be shown used in different places.

| Description | Cockpit screenshot|
| --- | --- |
| It is possible to enter up to 6 missile waypoints, these can be used to program the flight path of CM-802AKG cruise missile when using in **MANUAL** mode. To enter them you need to toggle **F**. | ![missile waypoints designation](images/designation_of_missile_waypoints.png) |
| DST page with entered missile waypoints | ![DST page with entered missile waypoints](images/entered_missile_waypoints.png) |
| SMS page with CM-802AKG in MANUAL mode and missile waypoints | ![allocated missile waypoints in manual mode](images/allocation_manual_mode.png) |

## Entry of pre planned target points (36-39)

| Description | Cockpit screenshot|
| --- | --- |
| It is possible to enter up to **4** pre-planned points, these can be used to prepare the attack on ground targets. To enter them you need to toggle **T**.<br> | ![missile target points](images/designation_of_missile_target_points.png) |
| Once the entry of  target points is complete, they can be seen on DST page. | ![DST page with entered waypoints](images/entered_target_point.png) |

# Known limitations

- Repeated entry in Southern/Western hemispheres results in inversion of hemisphere to East/North. The limitation comes from the module itself.
  - https://forum.dcs.world/topic/335543-upfc-entry-dst-clr-does-not-fully-clear-waypoint/
  - https://forum.dcs.world/topic/335539-ufcp-coordinate-entry-unable-the-toggle-westereastern-hemisphere/?do=getNewComment/


# References:

- **DCS JF-17 Quick Guide EN** (e.g. C:\Program Files\Eagle Dynamics\DCS World OpenBeta\Mods\aircraft\JF-17\Doc\DCS JF-17 Quick Guide EN.pdf).
- **DCS JF-17 Flight Manual CN**, located in the DOC folder of the module within your installation (e.g. C:\Program Files\Eagle Dynamics\DCS World OpenBeta\Mods\aircraft\JF-17\Doc\DCS JF-17 Flight Manual CN.pdf). 
- [Chuck's Guide: DCS Guide - JF-16 Thunder](https://chucksguides.com/aircraft/dcs/jf-17/#[322,%22XYZ%22,-8e-06,540,1])