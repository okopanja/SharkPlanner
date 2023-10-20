local F16CBL50CommandGenerator = require("SharkPlanner.Modules.JF-17.JF17CommandGenerator")

-- definition of variants and associated command generators
local COMMAND_GENERATORS = {}
COMMAND_GENERATORS["JF-17"] = F16CBL50CommandGenerator

-- returns table indicating the supported
local function getCommandGenerators()
    return COMMAND_GENERATORS
end

local function getConfigurationDefinition()
    return {
        SectionName = "JF-17",
        {
            SectionName = "UFCP",
            Options = {
                {
                    Name = "CommandDelay",
                    Label = "Command delay (ms)",
                    Default = 100,
                    Control = "HorzSlider",
                    Min = 70,
                    Max = 500,
                    Step = 1,
                },
            }
        },
        {
            SectionName = "MFCD",
            Options = {
                {
                    Name = "CommandDelay",
                    Label = "Command delay (ms)",
                    Default = 100,
                    Control = "HorzSlider",
                    Min = 70,
                    Max = 2000,
                    Step = 1,
                },
            }
        },
    }
end
-- Function tries to determine sub variant based on base_module_name and module specific criteria. E.g. by checking if certain device is implemented or not
-- For modules having single variant the function should return base_module_name
local function determineVariant(base_module_name)
    if base_module_name == "JF-17" then return base_module_name end
    -- the base_module_name is not ammong supported
    return nil
end

-- return module
return {
    getCommandGenerators = getCommandGenerators,
    determineVariant = determineVariant,
    getConfigurationDefinition = getConfigurationDefinition
}
