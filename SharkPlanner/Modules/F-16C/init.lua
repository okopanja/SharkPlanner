local F16CBL50CommandGenerator = require("SharkPlanner.Modules.F-16C.F16CBL50CommandGenerator")

-- definition of variants and associated command generators
local COMMAND_GENERATORS = {}
COMMAND_GENERATORS["F-16C_50"] = F16CBL50CommandGenerator

-- returns table indicating the supported
local function getCommandGenerators()
    return COMMAND_GENERATORS
end

local function getConfigurationDefinition()
    return {}
end
-- Function tries to determine sub variant based on base_module_name and module specific criteria. E.g. by checking if certain device is implemented or not
-- For modules having single variant the function should return base_module_name
local function determineVariant(base_module_name)
    if base_module_name == "F-16C_50" then return base_module_name end
    -- the base_module_name is not ammong supported
    return nil
end

-- return module
return {
    getCommandGenerators = getCommandGenerators,
    determineVariant = determineVariant,
    getConfigurationDefinition = getConfigurationDefinition
}
