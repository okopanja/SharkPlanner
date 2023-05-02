local VERSION_INFO = require("SharkPlanner.VersionInfo")
local Utils = require("SharkPlanner.Utils")
local Logging = Utils.Logging
Logging.info("Version: "..VERSION_INFO)
local Base = require("SharkPlanner.Base")
local Modules = require("SharkPlanner.Modules")
local UI = require("SharkPlanner.UI")
local window = nil
local crosshairWindow = nil
local statusWindow = nil
local waypointListWindow = nil
local coordinateData = Base.CoordinateData
-- local http = require("socket.http")
Logging.info("Registering event handlers")
Base.DCSEventHandlers.register()

-- TODO: think about how to get HTTPS support. It appears LuaRocks attempts to switch to port 80, which causes github to response 301 permanent redirect toward HTTPS
local function checkForUpdates()
    Logging.info("Checking for latest version")
    local response, code, headers, status = socket.http.request {
        method = "GET",
        url = "https://api.github.com/repos/okopanja/SharkPlanner/releases/latest",
        headers = {
            ["Host"] = "api.github.com",
            ["User-Agent"] = "curl/7.87.0",
            ["accept"] = "*/*",
            ["Upgrade-Insecure-Requests"] = "1",
            ["DNT"] = "1",
        }
      }
    Logging.info("Status: "..status)
    for k, v in pairs(headers) do
        Logging.info(k..": "..v)
    end
    local tag_location = "https://github.com/okopanja/SharkPlanner/releases/tag/"
    Logging.info("Response: "..response)
    Logging.info("Got: "..tostring(code))
    if code == 301 or code == 302 then
        Logging.info("Redirect location: " .. headers.location)
        if headers.location then
            Logging.info("checking")      
            if Utils.String.starts_with(headers.location, tag_location) then
                local latestVersion = string.strsub(headers.location, string.strlen(tag_location))
                Logging("Latest version: "..latestVersion)
            end
        end
    end
end

crosshairWindow = UI.CrosshairWindow:new{}

-- create status window
statusWindow = UI.StatusWindow:new{crosshairWindow = crosshairWindow}
-- register statusWindow to receive events from coordinateData
coordinateData:addEventHandler(Base.CoordinateData.EventTypes.AddWayPoint, statusWindow, statusWindow.OnAddWaypoint)
coordinateData:addEventHandler(Base.CoordinateData.EventTypes.RemoveWayPoint, statusWindow, statusWindow.OnRemoveWaypoint)
coordinateData:addEventHandler(Base.CoordinateData.EventTypes.AddFixPoint, statusWindow, statusWindow.OnAddFixpoint)
coordinateData:addEventHandler(Base.CoordinateData.EventTypes.RemoveFixPoint, statusWindow, statusWindow.OnRemoveFixpoint)
coordinateData:addEventHandler(Base.CoordinateData.EventTypes.AddTargetPoint, statusWindow, statusWindow.OnAddTargetpoint)
coordinateData:addEventHandler(Base.CoordinateData.EventTypes.RemoveTargetPoint, statusWindow, statusWindow.OnRemoveTargetpoint)
coordinateData:addEventHandler(Base.CoordinateData.EventTypes.Reset, statusWindow, statusWindow.OnReset)
coordinateData:addEventHandler(Base.CoordinateData.EventTypes.FlightPlanSaved, statusWindow, statusWindow.OnFlightPlanSaved)
coordinateData:addEventHandler(Base.CoordinateData.EventTypes.FlightPlanLoaded, statusWindow, statusWindow.OnFlightPlanLoaded)

-- register statusWindow to receive events from DCS
Base.DCSEventHandlers.addEventHandler(Base.DCSEventHandlers.EventTypes.TransferStarted, statusWindow, statusWindow.OnTransferStarted)
Base.DCSEventHandlers.addEventHandler(Base.DCSEventHandlers.EventTypes.TransferFinished, statusWindow, statusWindow.OnTransferFinished)
Base.DCSEventHandlers.addEventHandler(Base.DCSEventHandlers.EventTypes.TransferProgressUpdated, statusWindow, statusWindow.OnTransferProgressUpdated)
Base.DCSEventHandlers.addEventHandler(Base.DCSEventHandlers.EventTypes.PlayerEnteredSupportedVehicle, statusWindow, statusWindow.OnPlayerEnteredSupportedVehicle)

-- create waypoint list window
waypointListWindow = UI.WaypointListWindow:new{crosshairWindow = crosshairWindow}
-- register waypointListWindow to receive events from coordinateData
coordinateData:addEventHandler(Base.CoordinateData.EventTypes.AddWayPoint, waypointListWindow, waypointListWindow.OnAddWaypoint)
coordinateData:addEventHandler(Base.CoordinateData.EventTypes.RemoveWayPoint, waypointListWindow, waypointListWindow.OnRemoveWaypoint)
coordinateData:addEventHandler(Base.CoordinateData.EventTypes.AddFixPoint, waypointListWindow, waypointListWindow.OnAddFixpoint)
coordinateData:addEventHandler(Base.CoordinateData.EventTypes.RemoveFixPoint, waypointListWindow, waypointListWindow.OnRemoveFixpoint)
coordinateData:addEventHandler(Base.CoordinateData.EventTypes.AddTargetPoint, waypointListWindow, waypointListWindow.OnAddTargetpoint)
coordinateData:addEventHandler(Base.CoordinateData.EventTypes.RemoveTargetPoint, waypointListWindow, waypointListWindow.OnRemoveTargetpoint)
coordinateData:addEventHandler(Base.CoordinateData.EventTypes.Reset, waypointListWindow, waypointListWindow.OnReset)
coordinateData:addEventHandler(Base.CoordinateData.EventTypes.FlightPlanLoaded, waypointListWindow, waypointListWindow.OnFlightPlanLoaded)
coordinateData:addEventHandler(Base.CoordinateData.EventTypes.FlightPlanSaved, waypointListWindow, waypointListWindow.OnFlightPlanSaved)

-- create control window, and pass other windows
window = UI.ControlWindow:new{
crosshairWindow = crosshairWindow,
statusWindow = statusWindow,
waypointListWindow = waypointListWindow,
coordinateData = coordinateData
}
-- register window to receive vents from coordinateData
coordinateData:addEventHandler(Base.CoordinateData.EventTypes.AddWayPoint, window, window.OnAddWaypoint)
coordinateData:addEventHandler(Base.CoordinateData.EventTypes.RemoveWayPoint, window, window.OnRemoveWaypoint)
coordinateData:addEventHandler(Base.CoordinateData.EventTypes.AddFixPoint, window, window.OnAddFixPoint)
coordinateData:addEventHandler(Base.CoordinateData.EventTypes.RemoveFixPoint, window, window.OnRemoveFixPoint)
coordinateData:addEventHandler(Base.CoordinateData.EventTypes.AddTargetPoint, window, window.OnAddTargetPoint)
coordinateData:addEventHandler(Base.CoordinateData.EventTypes.RemoveTargetPoint, window, window.OnRemoveTargetPoint)
coordinateData:addEventHandler(Base.CoordinateData.EventTypes.Reset, window, window.OnReset)
Base.DCSEventHandlers.addEventHandler(Base.DCSEventHandlers.EventTypes.SimulationStarted, window, window.OnSimulationStarted)
Base.DCSEventHandlers.addEventHandler(Base.DCSEventHandlers.EventTypes.PlayerChangeSlot, window, window.OnPlayerChangeSlot)
Base.DCSEventHandlers.addEventHandler(Base.DCSEventHandlers.EventTypes.PlayerEnteredSupportedVehicle, window, window.OnPlayerEnteredSupportedVehicle)
Base.DCSEventHandlers.addEventHandler(Base.DCSEventHandlers.EventTypes.SimulationStopped, window, window.OnSimulationStopped)
Base.DCSEventHandlers.addEventHandler(Base.DCSEventHandlers.EventTypes.TransferFinished, window, window.OnTransferFinished)
Base.DCSEventHandlers.addEventHandler(Base.DCSEventHandlers.EventTypes.PlayerEnteredSupportedVehicle, coordinateData, coordinateData.OnPlayerEnteredSupportedVehicle)

-- register waypointListWindow to receive events from controlWindow    
window:addEventHandler(UI.ControlWindow.EventTypes.EntryModeChanged, waypointListWindow, waypointListWindow.OnEntryModeChanged)

Logging.info("Hidding the window")
window:hide()

Logging.info("Window creation completed")
Logging.info("Game state: "..Base.GameState.getGameState())

-- make Base, Modules Utils, and VERSION_INFO available
return {
    Base = Base,
    Modules = Modules,
    Utils = Utils,
    UI = UI,
    VERSION_INFO = VERSION_INFO
}
