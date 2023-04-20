local function loadSharkPlanner()
  local DialogLoader = require("DialogLoader")
  local dxgui = require('dxgui')
  local lfs = require("lfs")
  local SkinUtils = require("SkinUtils")
  -- local FileDialog = require("FileDialog")
  package.path = package.path .. lfs.writedir() .. "Scripts\\?\\init.lua"
  local SharkPlanner = require("SharkPlanner")
  local Logging = SharkPlanner.Utils.Logging
  local window = nil
  local crosshairWindow = nil
  local statusWindow = nil
  local waypointListWindow = nil
  local coordinateData = SharkPlanner.Base.CoordinateData

  local function createCrosshairWindow()
    Logging.info("Creating crosshair window")
    crosshairWindow = DialogLoader.spawnDialogFromFile(
        lfs.writedir() .. "Scripts\\SharkPlanner\\UI\\CrosshairWindow.dlg"
    )
    -- crosshair picture location depends on user DCS folder, therefore we will reload the skin by constructing definite path at runtime
    local skin = crosshairWindow.WaypointCrosshair:getSkin()
    local crosshair_picture_path = lfs.writedir()..skin.skinData.states.released[1].picture.file
    Logging.info("Path to crosshair picture: "..crosshair_picture_path)
    crosshairWindow.WaypointCrosshair:setSkin(SkinUtils.setStaticPicture(crosshair_picture_path, skin))

    local screenWidth, screenHeight = dxgui.GetScreenSize()
    local x = math.floor(screenWidth/2) - 200
    local y = math.floor(screenHeight/2) - 200
    Logging.info("X: "..x.." Y: "..y)
    Logging.info("Setting bounds")
    crosshairWindow:setBounds(x, y, 400, 400)
    crosshairWindow:setTransparentForUserInput(true)
    Logging.info("Showing the crosshair window")
    crosshairWindow:setVisible(true)
    return crosshairWindow
  end

  local function initializeUI()
    -- check if window already exists
    if window ~= nil then
      return
    end
    crosshairWindow = createCrosshairWindow()

    -- create status window
    statusWindow = SharkPlanner.UI.StatusWindow:new{crosshairWindow = crosshairWindow}
    -- register statusWindow to receive events from coordinateData
    coordinateData:addEventHandler(SharkPlanner.Base.CoordinateData.EventTypes.AddWayPoint, statusWindow, statusWindow.OnAddWaypoint)
    coordinateData:addEventHandler(SharkPlanner.Base.CoordinateData.EventTypes.RemoveWayPoint, statusWindow, statusWindow.OnRemoveWaypoint)
    coordinateData:addEventHandler(SharkPlanner.Base.CoordinateData.EventTypes.AddFixPoint, statusWindow, statusWindow.OnAddFixpoint)
    coordinateData:addEventHandler(SharkPlanner.Base.CoordinateData.EventTypes.RemoveFixPoint, statusWindow, statusWindow.OnRemoveFixpoint)
    coordinateData:addEventHandler(SharkPlanner.Base.CoordinateData.EventTypes.AddTargetPoint, statusWindow, statusWindow.OnAddTargetpoint)
    coordinateData:addEventHandler(SharkPlanner.Base.CoordinateData.EventTypes.RemoveTargetPoint, statusWindow, statusWindow.OnRemoveTargetpoint)
    coordinateData:addEventHandler(SharkPlanner.Base.CoordinateData.EventTypes.Reset, statusWindow, statusWindow.OnReset)
    -- register statusWindow to receive events from DCS
    SharkPlanner.Base.DCSEventHandlers.addEventHandler(SharkPlanner.Base.DCSEventHandlers.EventTypes.TransferStarted, statusWindow, statusWindow.OnTransferStarted)
    SharkPlanner.Base.DCSEventHandlers.addEventHandler(SharkPlanner.Base.DCSEventHandlers.EventTypes.TransferFinished, statusWindow, statusWindow.OnTransferFinished)
    SharkPlanner.Base.DCSEventHandlers.addEventHandler(SharkPlanner.Base.DCSEventHandlers.EventTypes.TransferProgressUpdated, statusWindow, statusWindow.OnTransferProgressUpdated)
    SharkPlanner.Base.DCSEventHandlers.addEventHandler(SharkPlanner.Base.DCSEventHandlers.EventTypes.PlayerEnteredSupportedVehicle, statusWindow, statusWindow.OnPlayerEnteredSupportedVehicle)

    -- create waypoint list window
    waypointListWindow = SharkPlanner.UI.WaypointListWindow:new{crosshairWindow = crosshairWindow}
    -- register waypointListWindow to receive events from coordinateData
    coordinateData:addEventHandler(SharkPlanner.Base.CoordinateData.EventTypes.AddWayPoint, waypointListWindow, waypointListWindow.OnAddWaypoint)
    coordinateData:addEventHandler(SharkPlanner.Base.CoordinateData.EventTypes.RemoveWayPoint, waypointListWindow, waypointListWindow.OnRemoveWaypoint)
    coordinateData:addEventHandler(SharkPlanner.Base.CoordinateData.EventTypes.AddFixPoint, waypointListWindow, waypointListWindow.OnAddFixpoint)
    coordinateData:addEventHandler(SharkPlanner.Base.CoordinateData.EventTypes.RemoveFixPoint, waypointListWindow, waypointListWindow.OnRemoveFixpoint)
    coordinateData:addEventHandler(SharkPlanner.Base.CoordinateData.EventTypes.AddTargetPoint, waypointListWindow, waypointListWindow.OnAddTargetpoint)
    coordinateData:addEventHandler(SharkPlanner.Base.CoordinateData.EventTypes.RemoveTargetPoint, waypointListWindow, waypointListWindow.OnRemoveTargetpoint)
    coordinateData:addEventHandler(SharkPlanner.Base.CoordinateData.EventTypes.Reset, waypointListWindow, waypointListWindow.OnReset)

    -- create control window, and pass other windows
    window = SharkPlanner.UI.ControlWindow:new{
      crosshairWindow = crosshairWindow,
      statusWindow = statusWindow,
      waypointListWindow = waypointListWindow,
      coordinateData = coordinateData
    }
    -- register window to receive vents from coordinateData
    coordinateData:addEventHandler(SharkPlanner.Base.CoordinateData.EventTypes.AddWayPoint, window, window.OnAddWaypoint)
    coordinateData:addEventHandler(SharkPlanner.Base.CoordinateData.EventTypes.RemoveWayPoint, window, window.OnRemoveWaypoint)
    coordinateData:addEventHandler(SharkPlanner.Base.CoordinateData.EventTypes.AddFixPoint, window, window.OnAddFixPoint)
    coordinateData:addEventHandler(SharkPlanner.Base.CoordinateData.EventTypes.RemoveFixPoint, window, window.OnRemoveFixPoint)
    coordinateData:addEventHandler(SharkPlanner.Base.CoordinateData.EventTypes.AddTargetPoint, window, window.OnAddTargetPoint)
    coordinateData:addEventHandler(SharkPlanner.Base.CoordinateData.EventTypes.RemoveTargetPoint, window, window.OnRemoveTargetPoint)
    coordinateData:addEventHandler(SharkPlanner.Base.CoordinateData.EventTypes.Reset, window, window.OnReset)
    SharkPlanner.Base.DCSEventHandlers.addEventHandler(SharkPlanner.Base.DCSEventHandlers.EventTypes.SimulationStarted, window, window.OnSimulationStarted)
    SharkPlanner.Base.DCSEventHandlers.addEventHandler(SharkPlanner.Base.DCSEventHandlers.EventTypes.PlayerChangeSlot, window, window.OnPlayerChangeSlot)
    SharkPlanner.Base.DCSEventHandlers.addEventHandler(SharkPlanner.Base.DCSEventHandlers.EventTypes.PlayerEnteredSupportedVehicle, window, window.OnPlayerEnteredSupportedVehicle)
    SharkPlanner.Base.DCSEventHandlers.addEventHandler(SharkPlanner.Base.DCSEventHandlers.EventTypes.SimulationStopped, window, window.OnSimulationStopped)
    SharkPlanner.Base.DCSEventHandlers.addEventHandler(SharkPlanner.Base.DCSEventHandlers.EventTypes.TransferFinished, window, window.OnTransferFinished)

    -- register waypointListWindow to receive events from controlWindow    
    window:addEventHandler(SharkPlanner.UI.ControlWindow.EventTypes.EntryModeChanged, waypointListWindow, waypointListWindow.OnEntryModeChanged)

    Logging.info("Hidding the window")
    window:hide()

    Logging.info("Window creation completed")
  end

  Logging.info("Registering event handlers")
  -- DCS.setUserCallbacks(eventHandlers)
  SharkPlanner.Base.DCSEventHandlers.register()
  initializeUI()
  Logging.info("Game state: "..SharkPlanner.Base.GameState.getGameState())
end

local status, err = pcall(loadSharkPlanner)
if not status then
  net.log("[SharkPlanner] load error: " .. tostring(err))
end
