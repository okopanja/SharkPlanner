local Logging = require("SharkPlanner.Utils.Logging")
local CACommandGenerator = require("SharkPlanner.Modules.CA.CACommandGenerator")

-- definition of variants and associated command generators
local COMMAND_GENERATORS = {}
-- COMMAND_GENERATORS["nil"] = CACommandGenerator
COMMAND_GENERATORS["artillery_commander"] = CACommandGenerator
COMMAND_GENERATORS["forward_observer"] = CACommandGenerator
COMMAND_GENERATORS["instructor"] = CACommandGenerator
COMMAND_GENERATORS["observer"] = CACommandGenerator


local Coalitions = { "red", "blue"}


-- returns table indicating the supported
local function getCommandGenerators()
    return COMMAND_GENERATORS
end

local function getSlotInfo(side_id, slot_id)
    local availableSlots = DCS.getAvailableSlots(Coalitions[side_id])
    for k,v in pairs(availableSlots) do
        if v.unitId == slot_id then
            return v
        end
    end
    return nil
end

-- Function tries to determine sub variant based on base_module_name and module specific criteria. E.g. by checking if certain device is implemented or not
-- For modules having single variant the function should return base_module_name
local function determineVariant(base_module_name)
    Logging.info("Determening variant for: "..tostring(base_module_name))
    if base_module_name ~= "Combined Arms" then return nil end    
    local my_player_id = net.get_my_player_id()
    local side_id, slot_id = net.get_slot(my_player_id)
    if slot_id == nil then return nil end
    local slot_info = getSlotInfo(side_id, slot_id)
    if slot_info ~= nil then
        return slot_info.type
    end
    -- the base_module_name is not ammong supported
    return nil
end

-- return module
return {
    getCommandGenerators = getCommandGenerators,
    determineVariant = determineVariant
}
