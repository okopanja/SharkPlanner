-- init.lua file is used by CommandGeneratorFactory to discover the modules, by iterating over folders in SharkPlanner/Modules folder
-- it defines a module with following functions:
-- getCommandGenerators -- used to determine which command generators are provided by module and which to use with each discovered variant (e.g. see Ka-50)
-- determinVariant -- used detect the variant of the module (this is sometimes tricky business, e.g. ED's Ka-50 Black Shark 3 has version 2008 and 2022 which share the same identified, but also there is Black Shark 2)
-- getConfigurationDefinition -- used to define the configuration options for the module

-- load all the accutal command generator class (you can have multiple classes if your variants need special handling, depending on variant, e.g. Black Shark or Combined Arms)
local MyModuleCommandGenerator = require("SharkPlanner.Modules.Module.MyModuleCommandGenerator")

-- definition of variants and associated command generators
local COMMAND_GENERATORS = {}
-- as a key use the official identifier of module
COMMAND_GENERATORS["MyModule"] = MyModuleCommandGenerator

-- returns table indicating the supported
local function getCommandGenerators()
    return COMMAND_GENERATORS
end

-- define configuration options for module. You do not need to define config file, on first load the SharkPlanner will recognize the options and add them to existing config file or if it does not exist create valid configuration file containing all possible options for all modules.
local function getConfigurationDefinition()
    return {
        SectionName = "MyModule", -- defines top most section name
        {
            SectionName = "MyEntryDevice", -- if the module has multiple devices that need to be interacted with, each should have it's own section
            Options = {
                {
                    Name = "SelectWaypoint1", -- defines the name of option. Later you can reference this particilar option as 'MyModule.MyEntryDevice.SelectWaypoint1'
                    Label = "E.g. Select waypoint 1", -- label displayed in configuration menu to end user
                    Default = true, -- default value
                    Control = "CheckBox", -- control to be used for editing the value
                },
            },
            -- More sub sections may follow..
        },
        -- More sections may follow...
    }
end

-- Function tries to determine sub variant based on base_module_name and module specific criteria. E.g. by checking if certain device is implemented or not
-- For modules having single variant the function should return base_module_name
local function determineVariant(base_module_name)
    if base_module_name == "MyModule" then
        return base_module_name
    end
    -- the base_module_name is not ammong supported
    return nil
end

-- return module
return {
    getCommandGenerators = getCommandGenerators,
    determineVariant = determineVariant,
    getConfigurationDefinition = getConfigurationDefinition
}
