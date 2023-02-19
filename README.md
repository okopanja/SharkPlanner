# FlightPlanner
FlightPlanner is a mod for entry of waypoints into ABRIS and PVI-800, based on selection of locations from F10 map within DCS. It is 100% implemented in LUA and integrates into the DCS UI.
## FAQ
### How it works?
FlightPlanner runs as a LUA script hook and is able to utilize DCS's native UI in order to deliver minimalistic UI without requireing external application.
### Do I need binary?
No, FlightPlanner runs within the DCS as such does not require external tools to run. 
### Which DCS versions are supported?
Minimal requirement is *2.8* either *stable* or **openbeta**. 
### Which airframes are supported?
- BlackShark 3: Ka-50 version 2022 (implemented)
- BlackShark 3: Ka-50 version 2011 (planned)
- BlackShark 2: Ka-50 (planned)
### How do I report bugs?
Open the (issues)[https://github.com/okopanja/FlightPlanner/issues], read existing open issues to quickly figure out if your issue is already reported, and if you find none create **new issue**.
Please try to be precise and provide the steps for reproduction and if needed:
- screenshots if available
- links to video if available
- mission file if available (needs to be renamed into zip, I recommend my_mission.miz.zip)
- dcs.log
## Installation instructions
1. Download the latest (release)[https://github.com/okopanja/FlightPlanner/releases]. The needed file is named: FlightPlanner-VERSION.zip
2. Unpack the content of the zip file into **%USERPROFILE%\Saved Games\DCS.openbeta\Scripts** or **%USERPROFILE%\Saved Games\DCS\Scripts** depending on version of the DCS you are using.
3. Start or restart DCS
## Usage instractions
1. Start DCS
2. Hop into your Black Shark
3. Switch to F10 mode
4. Hit: **LCTRL+LSHIFT+y**
5. You should see a crosshair in the middle of screen. Above you will see buttons: **Hide**, **Add**, **Reset**, **Transfer** as well as label showing current and maximal number of waypoints.
6. Use your mouse to pan and zoom to your point of interest, and use Add button to select your waypoints
7. Once satisfied, click on **Transfer** button and FlightPlanner will start entering waypoints into ABRIS and PVI-800. It is recommended to do this on ground for maximal accuracy. 
8. If you would like to create a new route, hit **Reset** and go to step 5.
9. To hide FlightPlanner hit again Hit: **LCTRL+LSHIFT+y**
## Removal instructions
To remove FlightPlanner
1. Delete file **%USERPROFILE%\Saved Games\DCS.openbeta\Scripts\Hooks\FlightPlanner.lua** or **%USERPROFILE%\Saved Games\DCS\Scripts\Hooks\FlightPlanner.lua** depending on version of the DCS you are using.
2. Delete folder **%USERPROFILE%\Saved Games\DCS.openbeta\Scripts\FlightPlanner** or **%USERPROFILE%\Saved Games\DCS\Scripts\FlightPlanner** depending on version of the DCS you are using.
## Kudos
* [TheWay](https://github.com/aronCiucu/DCSTheWay) is a very cool project which enabled entry of waypoints for a rather large number of DCS airframes . My initial idea was to provide the code contribution to [TheWay](https://github.com/aronCiucu/DCSTheWay/pull/24/), but ABRIS proved to be very challanging to implement within existing framework and resulted in large changes that could not be easily harmonized and test with existing code base. [TheWay](https://github.com/aronCiucu/DCSTheWay) remains to be the most comprehensive software for waypoint entry in DCS and is highly recommended to use. 
* [DCS Scratchpad](https://github.com/rkusa/dcs-scratchpad) provided the idea how to inject the UI and trigger it with a keyboard shortcut.