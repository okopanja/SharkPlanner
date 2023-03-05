local KA50IIICommandGenerator = require("SharkPlanner.Modules.Ka-50.KA50IIICommandGenerator")
local KA50IICommandGenerator = require("SharkPlanner.Modules.Ka-50.KA50IICommandGenerator")

local COMMAND_GENERATORS = {
    -- "Ka-50_3 2022" = KA50IIICommandGenerator,
    -- "Ka-50_3 2011" = KA50IICommandGenerator,
    -- "Ka-50" = KA50IICommandGenerator,
}

-- returns table indicating the supported
local function getCommandGenerators()
    return COMMAND_GENERATORS
end

-- function tries to detect exact sub variant based on base_module_name and module specific criteria
local function detectVariant(base_module_name)
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
    detectVariant = detectVariant
}
