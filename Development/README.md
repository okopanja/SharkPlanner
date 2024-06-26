# Development of module entry
## Pre-requisites
### Mandatory
- You have patience and motivation.
- You know to program lua on basic or intermidiate level.
- You know how to use git on basic or intermidiate level (forks, pull requests, merge, branch are not foreign concepts to you).
- You have valid [Github](https://github.com) account. 
- You have installed a good code editor. E.g. Microsoft Visual Studio Code would be good.
- You have git client installed. E.g. you can use download Github Desktop or simple command line git.
### Optional
- Install log viewer such as [Advanced Log Viewer](https://github.com/Scarfsail/AdvancedLogViewer) so you can see the output and understand the errors

## Prepation work
Before you start developing you need to perform a number of information-gathering tasks
1. Learn well the procedure of entry by reading the sources such as: official module manual and/or [Chuck's guide](https://chucksguides.com/). A single module can have multiple input devices. Sometimes they act independently (e.g. Ka-50), and sometimes they are actually alternative methods of input (e.g. JF-17).
2. Determine identifier of your module. This is typically aircraft model. It should be noted that no official documentation exists, but this is the best unofficial source I could find: https://github.com/pydcs/dcs/blob/bbd92f7c3aa67a8b6f7e1bb1f5534580ca05e892/tools/pydcs_export.lua#L213. Also you may get clue from some of the modules from their lua files.
4. Determine ID of the entry device. Your first step is to determine the name of the device from manual. Once you know the name of the device, within the module located relative to DCS installation folder, read **Mods\aircraft\F-16C\Cockpit\Scripts\devices.lua** (adjust to your module). This file defines devices and corresponding IDs. 
5. Determine which ID codes correspond to each command (valid for button, lever, dial, switch, etc) from **Mods\aircraft\F-16C\Cockpit\Scripts\command_defs.lua** (adjust according to your module). Entries in this file are typically: 
   1. not unique per device, 
   2. calculated in runtime via counter function (no explicitly stated values),
   3. typically they start with 3000 and get incremented by each entry which assigns the value by calling counter function.
6. Carefully read [example module init script](MyModuleTemplate/init.lua) and [example command generator](MyModuleTemplate/MyModuleCommandGenerator.lua)

## Development environment setup
1. Remove any installed version of SharkPlanner. See main [README.md](../README.md#removal-instructions) on how to uninstall existing SharkPlanner
2. Prepare for working with github
   1. Fork SharkPlanner repository from https://github.com/okopanja/SharkPlanner
   2. Clone your fork repository to e.g. **%USERPROFILE%\sources\SharkPlanner**. Inside this folder you will see README.md as well as folders SharkPlanner and Hooks.
   3. Create git development branch on your local repository. E.g. implement_f18_module.
   4. run **cmd** as **administrator** (this is needed so you get privilege to create symlink to folder)
   5. Create symlink to hook entry script, by running 
   
   ```mklink "%USERPROFILE%\sources\SharkPlanner\Hooks\SharkPlanner.lua" "%USERPROFILE%\Saved Games\DCS.openbeta\Scripts\Hooks\SharkPlanner.lua"```
    
   6. Create synlink to mod folder, by running 
    
    ```mklink /D "%USERPROFILE%\sources\SharkPlanner\SharkPlanner" "%USERPROFILE%\Saved Games\DCS.openbeta\Scripts\SharkPlanner"```

5. Copy [Development/MyModuleTemplate](MyModuleTemplate) as complete folder into **%USERPROFILE%\sources\SharkPlanner\SharkPlanner\Modules\**
6. Rename the resulting folder to resemble the name corresponding to your module to module ID e.g. you should have folder **SharkPlanner/Modules/F-18A**
7. Replace all occurrences of **MyModule** to e.g. **F18** (remove any underscore/hyphen or special characters) inside of both lua files (rename **MyModuleCommandGenerator.lua** to e.g. **F18CommandGenerator.lua**)
8. Replace **My_Module_ID** with module ID (use original name, e.g. F-16C)
9. Replace **MyEntryDevice** with name of entry device (underscore and hyphen are acceptable)
10. Replace **my_EntryDevice** with name of entry devices without underscore and hyphen, ideally camelBack notation.
11. Copy the [experiment.lua](experiment.lua) into **"%USERPROFILE%\Saved Games\DCS.openbeta\Scripts\SharkPlanner"**. You also need to edit this file to reload correct entry module.
12. Review the files

## Development process
### Common guidelines
- log your operations using class Logging with methods error, info, warning and debug.
- module entry must fulfill following requirements:
  - Entry can be performed with no errors multiple times within mission lifecycle.
  - Entry should return the device to the default mod.

### Log files
Logs files are located in **%USERPROFILE%\Saved Games\DCS.openbeta\Logs**:
- **dcs.log** is the ED's log system, you should only see one mention of SharkPlanner with no errors there. However, if you see more than one it means there is an error you need to read and understand. The message my give you information on which file and line the SharkPlanner has failed to initialize
- **SharkPlanner.log**, it's own log, which details operations performed by SharkPlanner but also your the entry module extension.
I recommend using of **Advanced Log Viewer** for log inspection.  

### Updating of code
Witch each restart DCS will load your newest code changes. This means for a single line change you may end up restarting whole DCS. This is where patience comes handy. Remember: Patient! => Saved!

In order to avoid restart, we have install **experiment.lua** file, which will allow us to reload without restarting DCS. If the file is properly installed **SharkPlanner** will display the **Exp** button in UI. Clicking on the **Exp** will execute experiment.lua which in turn will reload the module. Be sure to edit the **experiment.lua** to match the name of your CommandGenerator class for reloading. In 99% of cases you will not need to reload DCS.

