local KA50IIICommandGenerator = require("SharkPlanner.Modules.Ka-50.KA50IIICommandGenerator")
local KA50IICommandGenerator = require("SharkPlanner.Modules.Ka-50.KA50IICommandGenerator")

-- definition of variants and associated command generators
local COMMAND_GENERATORS = {}
COMMAND_GENERATORS["Ka-50_3 2022"] = KA50IIICommandGenerator
COMMAND_GENERATORS["Ka-50_3 2011"] = KA50IICommandGenerator
COMMAND_GENERATORS["Ka-50"] = KA50IICommandGenerator

-- returns table indicating the supported
local function getCommandGenerators()
    return COMMAND_GENERATORS
end

-- Function tries to determine sub variant based on base_module_name and module specific criteria. E.g. by checking if certain device is implemented or not
-- For modules having single variant the function should return base_module_name
local function determineVariant(base_module_name)
    if base_module_name == "Ka-50" then return base_module_name end
    if base_module_name == "Ka-50_3" then
        if Export.GetDevice(64) ~= nil then
            return "Ka-50_3 2022"
        else
            return "Ka-50_3 2011"
        end
    end
    -- the base_module_name is not ammong supported
    return nil
end

-- return module
return {
    getCommandGenerators = getCommandGenerators,
    determineVariant = determineVariant
}
