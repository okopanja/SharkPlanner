local COMMAND_GENERATORS = {
    "Ka-50_3 2022": nil,
    "Ka-50_3 2011": nil,
    "Ka-50": nil
}

-- returns table indicating the supported
local function getCommandGenerators()
    return COMMAND_GENERATORS
end

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
    getVariant = getVariant
}