-- init.lua file is used by CommandGeneratorFactory to discover the modules, by iterating over folders in SharkPlanner/Modules folder
-- it defines a module with following functions:
-- getCommandGenerators -- used to determine which command generators are provided by module and which to use with each discovered variant (e.g. see Ka-50)
-- determineVariant -- used to determine variant in cases where this is not possible through builtin ID of the module. E.g. Black Shark and Combined Arms need special handling, while SA-342 Gazelle politely reports different ID for each variant. 
-- getConfigurationDefinition -- used to define the configuration options for the module

-- load command generator class. Sometimes a module requires multiple generators if it offers multiple versions. E.g Combined Arms, Ka-50. 
local UH60LCommandGenerator = require("SharkPlanner.Modules.UH-60L.UH60LCommandGenerator")

-- definition of variants and associated command generators
local COMMAND_GENERATORS = {}
-- as a key use the official identifier of module
COMMAND_GENERATORS["UH-60L"] = UH60LCommandGenerator

-- returns table indicating the supported varients along their associated command generator. E.g. Ka-50 BS2 and BS3 have slight entry differences inside PVI-800 device.
local function getCommandGenerators()
    return COMMAND_GENERATORS
end

-- define configuration options for module. You do not need to define config file, on first load the SharkPlanner will recognize the options and add them to existing config file or if it does not exist create valid configuration file containing all possible options for all modules.
local function getConfigurationDefinition()
    return {
        SectionName = "UH-60L", -- defines top most section name,        
        {
            SectionName = "ASN-128B", -- subsection should be named according to the name of the device. Each used device should have own subsection
            Options = {
                {
                    Name = "CommandDelay", -- defines the name of option. Later you can reference this particular option as 'UH60L.ASN-128B.CommandDelay'
                    Label = "Command delay (ms)", -- label displayed in configuration menu to end user
                    Default = 100, -- default value
                    Control = "HorzSlider", -- control to be used for editing the value, in this case it's a HorzSlided which needs additional parameters
                    Min = 70, -- minimal value
                    Max = 500, -- maximal value
                    Step = 1, -- increment/decrement step
                },
                -- {
                --     Name = "SelectWaypoint1", -- defines the name of option. Later you can reference this particular option as 'UH60L.ASN-128B.SelectWaypoint1'
                --     Label = "E.g. Select waypoint 1", -- label displayed in configuration menu to end user
                --     Default = true, -- default value
                --     Control = "CheckBox", -- control to be used for editing the value
                -- },
                {
                    Name = "SelectDisplay",
                    Label = "Select display",
                    Default = UH60LCommandGenerator.SelectDisplayPositions.PP.name,
                    Control = "ComboList",
                    Items = {
                        UH60LCommandGenerator.SelectDisplayPositions.WIND_UTC_DATA,
                        UH60LCommandGenerator.SelectDisplayPositions.XTX_TKC_KEY,
                        UH60LCommandGenerator.SelectDisplayPositions.GS_TK_NAV_M,
                        UH60LCommandGenerator.SelectDisplayPositions.PP,
                        UH60LCommandGenerator.SelectDisplayPositions.DEST_BRG_TIME,
                        UH60LCommandGenerator.SelectDisplayPositions.WP_TGT,
                        UH60LCommandGenerator.SelectDisplayPositions.DATUM_ROUTE,
                    },
                    -- UpdateCallback = Logging.updateVerbosity
                },
                {
                    Name = "SelectMode",
                    Label = "Select mode",
                    Default = UH60LCommandGenerator.SelectModePositions.MGRS.name,
                    Control = "ComboList",
                    Items = {
                        UH60LCommandGenerator.SelectModePositions.OFF,
                        UH60LCommandGenerator.SelectModePositions.LAMP_TEST,
                        UH60LCommandGenerator.SelectModePositions.TEST,
                        UH60LCommandGenerator.SelectModePositions.MGRS,
                        UH60LCommandGenerator.SelectModePositions.LAT_LONG,
                        UH60LCommandGenerator.SelectModePositions.GPS_LDG,
                    },
                    -- UpdateCallback = Logging.updateVerbosity
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
    if base_module_name == "UH-60L" then
        return base_module_name
    end
    -- the base_module_name is not ammong supported
    return nil
end

-- return module functions
return {
    getCommandGenerators = getCommandGenerators,
    determineVariant = determineVariant,
    getConfigurationDefinition = getConfigurationDefinition
}
