local BaseCommandGenerator = require("SharkPlanner.Base.BaseCommandGenerator")
local Table = require("SharkPlanner.Utils.Table")

-- declare dummy generate with 100 for each position type
local FC3CommandGenerator = BaseCommandGenerator:new()

function FC3CommandGenerator:getMaximalWaypointCount()
  return 100
end

function FC3CommandGenerator:getMaximalFixPointCount()
  return 100
end

function FC3CommandGenerator:getMaximalTargetPointCount()
  return 100
end


-- definition of variants and associated command generators
local COMMAND_GENERATORS = {}
COMMAND_GENERATORS["Su-27"] = FC3CommandGenerator
COMMAND_GENERATORS["Su-33"] = FC3CommandGenerator
COMMAND_GENERATORS["J-11A"] = FC3CommandGenerator
COMMAND_GENERATORS["MiG-29A"] = FC3CommandGenerator
COMMAND_GENERATORS["MiG-29S"] = FC3CommandGenerator
COMMAND_GENERATORS["Su-25T"] = FC3CommandGenerator
COMMAND_GENERATORS["Su-25"] = FC3CommandGenerator
COMMAND_GENERATORS["A-10A"] = FC3CommandGenerator
COMMAND_GENERATORS["F-15C"] = FC3CommandGenerator
COMMAND_GENERATORS["TF-51D"] = FC3CommandGenerator

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
    
    -- if base_module_name == "Su-27" then return base_module_name end
    if Table.is_in_keys(COMMAND_GENERATORS, base_module_name) then return base_module_name end
    -- the base_module_name is not ammong supported
    return nil
end

-- return module
return {
    getCommandGenerators = getCommandGenerators,
    determineVariant = determineVariant,
    getConfigurationDefinition = getConfigurationDefinition
}
