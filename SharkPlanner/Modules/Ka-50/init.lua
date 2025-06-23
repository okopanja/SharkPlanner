local KA50IIICommandGenerator = require("SharkPlanner.Modules.Ka-50.KA50IIICommandGenerator")
local KA50IICommandGenerator = require("SharkPlanner.Modules.Ka-50.KA50IICommandGenerator")
local KA50InputActionProcessor = require("SharkPlanner.Modules.Ka-50.KA50InputActionProcessor")

local KA50_VARIANTS = {
    BS3_2022 = "Ka-50_3 2022",
    BS3_2011 = "Ka-50_3 2011",
    BS2 = "Ka-50"
}
-- definition of variants and associated command generators
local COMMAND_GENERATORS = {}
COMMAND_GENERATORS[KA50_VARIANTS.BS3_2022] = KA50IIICommandGenerator
COMMAND_GENERATORS[KA50_VARIANTS.BS3_2011] = KA50IICommandGenerator
COMMAND_GENERATORS[KA50_VARIANTS.BS2] = KA50IICommandGenerator

local INPUT_ACTION_PROCESSORS = {}
INPUT_ACTION_PROCESSORS[KA50_VARIANTS.BS3_2022] = KA50InputActionProcessor
INPUT_ACTION_PROCESSORS[KA50_VARIANTS.BS3_2011] = KA50InputActionProcessor
INPUT_ACTION_PROCESSORS[KA50_VARIANTS.BS2] = KA50InputActionProcessor

-- returns table containing generators per each variant
local function getCommandGenerators()
    return COMMAND_GENERATORS
end

-- return table contaninig input action processors per each variant
local function getInputActionProcessors()
    return INPUT_ACTION_PROCESSORS
end

local function getConfigurationDefinition()
    return {
        SectionName = "Ka-50",
        {
            SectionName = "ABRIS",
            Options = {
                {
                    Name = "EnableWayPointEntry",
                    Label = "Enable entry of waypoints points",
                    Default = true,
                    Control = "CheckBox"
                },
                -- {
                --     Name = "EnableFixPointEntry",
                --     Label = "Enable entry of fix points (not implemented)",
                --     Default = false,
                --     Control = "CheckBox"
                -- },
                {
                    Name = "EnableTargetPointEntry",
                    Label = "Enable entry of target points (experimental)",
                    Default = false,
                    Control = "CheckBox"
                },
            }
        },
        {
            SectionName = "PVI-800",
            Options = {
                {
                    Name = "EnableWayPointEntry",
                    Label = "Enable entry of waypoints points",
                    Default = true,
                    Control = "CheckBox"
                },
                {
                    Name = "EnableFixPointEntry",
                    Label = "Enable entry of fix points",
                    Default = true,
                    Control = "CheckBox"
                },
                {
                    Name = "EnableTargetPointEntry",
                    Label = "Enable entry of target points",
                    Default = true,
                    Control = "CheckBox"
                },
                -- {
                --     Name = "InitialCorrectionDelay",
                --     Label = "Initial correction delay (ms)",
                --     Default = 2000,
                --     Control = "HorzSlider",
                --     Min = 0,
                --     Max = 5000,
                --     Step = 1,
                -- }
            }
        },
        {
            SectionName = 'SHKVAL',
            Options = {
                {
                    Name = "EnableVerticalCorrection",
                    Label = "Enable vertical correction (exp)",
                    Default = false,
                    Control = "CheckBox"
                },
                {
                    Name = "InitialCorrectionDelay",
                    Label = "Initial correction delay (ms)",
                    Default = 20,
                    Control = "HorzSlider",
                    Min = 0,
                    Max = 5000,
                    Step = 1,
                }
            }
        }
    }
end

-- Function tries to determine sub variant based on base_module_name and module specific criteria. E.g. by checking if certain device is implemented or not
-- For modules having single variant the function should return base_module_name
local function determineVariant(base_module_name)
    if base_module_name == "Ka-50" then return base_module_name end
    if base_module_name == "Ka-50_3" then
        if Export.GetDevice(64) ~= nil then
            return KA50_VARIANTS.BS3_2022
        else
            return KA50_VARIANTS.BS3_2011
        end
    end
    -- the base_module_name is not ammong supported
    return nil
end

-- return module
return {
    getCommandGenerators = getCommandGenerators,
    getInputActionProcessors = getInputActionProcessors,
    determineVariant = determineVariant,
    getConfigurationDefinition = getConfigurationDefinition
}
