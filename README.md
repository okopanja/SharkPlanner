# SharkPlanner
SharkPlanner is a MOD for entry of waypoints into DCS modules:
- **Ka-50** attack helicopter
  - **ABRIS** 
  - **PVI-800** 
- **SA-342 Gazelle** light attack helicopter
  - **NADIR**

It is 100% implemented in LUA and integrates into the DCS UI.

[![SharkPlannerThumbnail](http://img.youtube.com/vi/hBLJIa6ZC6c/0.jpg)](http://www.youtube.com/watch?v=hBLJIa6ZC6c)

## FAQ
### How does it work?
SharkPlanner runs as a LUA script hook and is able to utilize DCS's native UI in order to deliver minimalistic UI without requiring external application.
### Do I need binary/exe?
No, SharkPlanner runs within the DCS, and as such does not require external tools to run.
### Which DCS versions are supported?
Minimal requirement is **2.8** either **stable** or **openbeta**.
### Which airframes are supported?
- BlackShark 3: Ka-50 version 2022
- BlackShark 3: Ka-50 version 2011
- BlackShark 2: Ka-50
- Gazelle: SA-342L
- Gazelle: SA-342M
- Gazelle: SA-342Minigun
- F-16C

### How do I report bugs?
Open the [issues](https://github.com/okopanja/SharkPlanner/issues), read existing open issues to quickly figure out if your issue is already reported, and if you find none create **new issue**.
Please try to be precise and provide the steps for reproduction and if needed:
- screenshots if available
- links to video if available
- mission file if available (needs to be renamed into zip, I recommend my_mission.miz.zip)
- dcs.log, located at **%USERPROFILE%\Saved Games\DCS.openbeta\Logs** or **%USERPROFILE%\Saved Games\DCS\Logs**
## Installation instructions
1. Download the latest [release](https://github.com/okopanja/SharkPlanner/releases). The needed package is named like this: SharkPlanner-VERSION.zip
2. Unpack the content of the zip file into **%USERPROFILE%\Saved Games\DCS.openbeta\Scripts** or **%USERPROFILE%\Saved Games\DCS\Scripts** depending on version of the DCS you are using.
3. Start or restart DCS
## Usage instractions
1. Start DCS
2. Hop into your Black Shark
3. Switch to F10 mode
4. Hit: **CTRL+SHIFT+SPACE**
5. You should see a crosshair in the middle of screen. Above crosshair the following buttons are located: **Hide**, **Add**, **Reset**, **Transfer** as well as label showing current and maximal number of waypoints.
6. Use your mouse to zoom and pan to your point of interest, and use **Add** button to select your waypoints.
7. Once you add at least one waypoint, you can click on **Transfer** button and SharkPlanner will start entering waypoints into ABRIS and PVI-800. It is recommended to do this on ground for maximal accuracy. 
8. If you would like to create a new route, hit **Reset** and go to step 5.
9. To hide SharkPlanner hit again: **CTRL+SHIFT+SPACE**
## Removal instructions
To remove SharkPlanner:
1. Delete file **%USERPROFILE%\Saved Games\DCS.openbeta\Scripts\Hooks\SharkPlanner.lua** or **%USERPROFILE%\Saved Games\DCS\Scripts\Hooks\SharkPlanner.lua** depending on version of the DCS you are using.
2. Delete folder **%USERPROFILE%\Saved Games\DCS.openbeta\Scripts\SharkPlanner** or **%USERPROFILE%\Saved Games\DCS\Scripts\SharkPlanner** depending on version of the DCS you are using.
3. Restart DCS if it was running
## Kudos
* [TheWay](https://github.com/aronCiucu/DCSTheWay) is a very cool project which enables entry of waypoints for a rather large number of DCS airframes. My initial motivation was to provide the ABRIS support as code contribution to [TheWay](https://github.com/aronCiucu/DCSTheWay/pull/24/), but ABRIS proved to be very challanging to implement within existing framework since coordinates entry can be done only non-numerically through dials. This limitation has resulted in large changes that could not be easily harmonized and tested with existing code base. Please note that [TheWay](https://github.com/aronCiucu/DCSTheWay) remains to be the most comprehensive software for waypoint entry in DCS and is highly recommended to use for all other supported aircrafts. You can use both **SharkPlanner** and [TheWay](https://github.com/aronCiucu/DCSTheWay/pull/24/) as long as you remember not to invoke transfer of waypoints at the same time!
* [DCS Scratchpad](https://github.com/rkusa/dcs-scratchpad) provided the idea how to inject the UI and trigger it with a keyboard shortcut.
