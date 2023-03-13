local Logging = require("SharkPlanner.Utils.Logging")

local States = {}
local Coalitions = { "red", "blue"}



States.SimulationInactive = "SimulationInactive"
States.SinglePlayerSimulationActive = "SinglePlayerSimulationActive"
States.SlotSelectionNoSlot = "SlotSelectionNoSlot"
States.SlotSelected = "SlotSelected"
States.MultiplayerSimulationActive = "MultiplayerSimulationActive"


local function getSlotInfo(side_id, slot_id)
    local availableSlots = DCS.getAvailableSlots(Coalitions[side_id])
    for k,v in pairs(availableSlots) do
        if v.unitId == slot_id then
            return v
        end
    end
    return nil
end

local function getGameState()
    local my_player_id = net.get_my_player_id()
    Logging.info("my_player_id: "..tostring(my_player_id))
    local selfData = Export.LoGetSelfData()
    Logging.info("selfData: "..tostring(selfData))

    -- not having the player id and self data indicates the mission is not running
    if my_player_id == 0 and selfData == nil then return States.SimulationInactive end

    -- player id set to 0 and actual selfData means single player mission is running
    if my_player_id == 0 and selfData ~= nil then return States.SinglePlayerSimulationActive end

    local side_id, slot_id = net.get_slot(my_player_id)
    Logging.info("side_id: "..tostring(side_id))
    Logging.info("slot_id: "..tostring(slot_id))

    -- having player id but not having slot_id (indicated by empty string) indicates slot selection dialog.
    if slot_id == "" then return States.SlotSelectionNoSlot end
    local slot_info = getSlotInfo(side_id, slot_id)
    Logging.info("Type: "..slot_info.type)
    Logging.info("Role: "..slot_info.role)

    -- multiplayer session at the end
    return States.MultiplayerSimulationActive
end

return {
    States = States,
    getGameState = getGameState
}