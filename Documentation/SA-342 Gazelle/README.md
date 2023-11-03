# SA-342 Module capabilities

SA-342 Gazelle poses 2 navigation devices:
- **NADIR**, a hybrid navigation system based on: doppler navigation, gyrocompass, vertical compass and air speed sensor in order to implement navigation through dead reckoning.
- **Tablet**, generic tablet device used as moving map. It allows selection of zoom and different map types.

![SA-342 Gazelle outside](images/SA-342_Gazelle_outside.jpg)

# Features

**NADIR** system offers several modes with most important being **BUT** (waypoint mode). Up to **9** waypoints can be entered into NADIR.

| Description | Cockpit screenshot|
| --- | --- |
| Waypoints are designated in waypoint mode selected and indicated by **W** button | ![waypoints designation](images/designation_of_aircraft_waypoints.png) |
| By selecting the waypoint in **BUT** mode system will show the coordinates of waypoints. Upon entry waypoint 1 is automatically selected. The user has to take care of the waypoint switching, since no automatic switching is implemented. | ![NADIR current waypoint](images/NADIR_current_waypoint.png) |
| If the **NADIR** is active and has valid waypoint selected the wide needle will display the direction of the waypoint. In addition the in upper right corner distance to waypoint is displayed in km, with additional 100m precision. Since this indicator is electromechanical, the maximal displayed distance is 99,9km. | ![NADIR/ADF gauge current waypoint](images/NADIR_ADF_gauge-current_waypoint.png) |

# Known limitations

- **NADIR** provides only navigation aid. 
- Automatic switching of waypoints is not implemented. Each waypoint has to be selected manually based to the remaining distance. 
- **Tablet** device does not provide the entry method at this moment. Depending on future development of this device support may be added.

# References:

- **DCS: SA342 Gazelle - NADIR MARK I** (e.g. C:\Program Files\Eagle Dynamics\DCS World OpenBeta\Mods\aircraft\SA342\Doc\DCS SA342M Gazelle NADIR Manual_en.pdf)
- **DCS: SA342 Gazelle - Flight Manual** (e.g. C:\Program Files\Eagle Dynamics\DCS World OpenBeta\Mods\aircraft\SA342\Doc\DCS SA342M Flight manual_en.pdf)
