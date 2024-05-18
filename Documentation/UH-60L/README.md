# UH-60L Module capabilities

UH-60L Black Hawk in DCS has 3 navigation devices:
- **ASN-128B**, a hybrid navigation system based on: doppler navigation, gyrocompass, vertical compass and air speed sensor in order to implement navigation through dead reckoning.
- **HSI**
- **VSI**

![UH-60L Black Hawk outside](images/UH-60L_Black_Hawk_outside.jpg)

# Features

**ASN-128B** system offers several modes with most important being **MGRS** and **LAT/LONG**. **ASN-128** also provides the selection of displays with most important: **PP**, **DIST/BRG**, **WP TGT**. Up to **70** waypoints [0-69] can be entered into ASN-128B. Each waypoint will be automatically assigned with the name of the nearest inhabited place base on the database provided with active DCS terrain. 

| Description | Cockpit screenshot|
| --- | --- |
| The waypoints are captured in **F10** mode when you active the **SharkPlanner** pressing **CTRL+SHIFT+SPACE**. Once waypoints are selected **Transfer** button can be pressed to perform entry into ASN-128B via keypad. | ![waypoints designation](images/designation_of_aircraft_waypoints.png) |
| Information on next waypoint can be seen in **DIST/BRG TIME** mode by entering the corresponding waypoint point. Selected waypoint is show in the first raw. | ![ASN-128B current waypoint](images/ASN-128B_current_waypoint.png) |
| If the **ASN-128B** is active and has valid waypoint selected the pentagon needle will display the direction of the waypoint. Make sure you active the DOPPLER/GPS and Navigation Master Mode | ![ADF gauge current waypoint](images/VSI_HSI_gauge-current_waypoint.png) |
| On **ASN-128B** within DIST/BRG TIME mode you can see distance, azimuth and estimated flight time. | ![ADF gauge current waypoint](images/ASN-128B_current_waypoint_DIST_BRG_TIME.png) |



# Known limitations

- **ASN-128B** provides only navigation aid.
- **ASN-128B** does not allow the selection of absolute position of starting waypoint. Then entry will be always relative to the last selected waypoint in WP TGT display (second row).
- Next waypoint must be entered manually

# References:

- **Module Built-in Manual** (found in Menu)

