-- load all 3 modules
local SA342LCommandGenerator = require("SharkPlanner.Modules.SA342Gazelle.SA342LCommandGenerator")
local SA342MCommandGenerator = require("SharkPlanner.Modules.SA342Gazelle.SA342MCommandGenerator")
local SA342MinigunCommandGenerator = require("SharkPlanner.Modules.SA342Gazelle.SA342MinigunCommandGenerator")

-- definition of variants and associated command generators
local COMMAND_GENERATORS = {}
COMMAND_GENERATORS["SA342L"] = SA342LCommandGenerator
COMMAND_GENERATORS["SA342M"] = SA342MCommandGenerator
COMMAND_GENERATORS["SA342Minigun"] = SA342MinigunCommandGenerator

-- returns table indicating the supported
local function getCommandGenerators()
    return COMMAND_GENERATORS
end

local function getConfigurationDefinition()
    return {
        SectionName = "SA-342 Gazelle",
        {
            SectionName = "NADIR",
            Options = {
                {
                    Name = "EnableSwitchToBUTMode",
                    Label = "Once entry is complete switch to BUT mode",
                    Default = true
                }
            }
        }
    }
end

-- Function tries to determine sub variant based on base_module_name and module specific criteria. E.g. by checking if certain device is implemented or not
-- For modules having single variant the function should return base_module_name
local function determineVariant(base_module_name)
    if base_module_name == "SA342L" then
        return base_module_name
    elseif base_module_name == "SA342M" then
        return base_module_name
    elseif base_module_name == "SA342Minigun" then
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
