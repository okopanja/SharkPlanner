local function loadSharkPlanner()
  local DialogLoader = require("DialogLoader")
  local dxgui = require('dxgui')
  local Input = require("Input")
  local lfs = require("lfs")
  local Skin = require("Skin")
  local SkinUtils = require("SkinUtils")
  local Terrain = require('terrain')
  local Tools = require("tools")
  local U = require("me_utilities")
  -- local FileDialog = require("FileDialog")
  package.path = package.path .. lfs.writedir() .. "Scripts\\?\\init.lua"
  local SharkPlanner = require("SharkPlanner")
  local Logging = SharkPlanner.Utils.Logging
  local window = nil
  local crosshairWindow = nil
  local statusWindow = nil
  local waypointListWindow = nil
  local windowDefaultSkin = nil
  local windowSkinHidden = Skin.windowSkinChatMin()
  local coordinateData = SharkPlanner.Base.CoordinateData
  local commandGenerator = nil
  -- local commands = {}
  -- local delayed_depress_commands = {}

  -- handle lua 5.4 deprecation
  if table.unpack == nil then
    table.unpack = unpack
  end
  
  local function getEntryState()
    if waypointToggle:getState() then
      return ENTRY_STATES.WAYPOINTS
    end
    if fixpointToggle:getState() then
      return ENTRY_STATES.FIXPOINTS
    end
    if targetPointToggle:getState() then
      return ENTRY_STATES.TARGET_POINTS
    end
    return nil
  end

  local function updateToggleStates(state)
    local waypointState = false
    local fixpointState = false
    local targetPointState = false

    if state == ENTRY_STATES.WAYPOINTS then
      waypointState = true
    elseif state == ENTRY_STATES.FIXPOINTS then
      fixpointState = true
    elseif state == ENTRY_STATES.TARGET_POINTS then
      targetPointState = true
    end

    waypointToggle:setState(waypointState)
    fixpointToggle:setState(fixpointState)
    targetPointToggle:setState(targetPointState)
  end

  local function transferIsInactive()
    -- Logging.info("Commands: "..#commands)
    -- Logging.info("Depressed commands: "..#delayed_depress_commands)
    return #commands == 0 and #delayed_depress_commands == 0
  end

  local function transferIsActive()
    return not transferIsInactive()
  end

  local function updateWayPointUIState()
    resetButton:setEnabled((#coordinateData.wayPoints > 0 or #coordinateData.fixPoints > 0 or #coordinateData.targetPoints > 0) and transferIsInactive())
    transferButton:setEnabled((#coordinateData.wayPoints > 0 or #coordinateData.fixPoints > 0 or #coordinateData.targetPoints > 0) and transferIsInactive() and commandGenerator:getAircraftName() ~= "Combined Arms")
    -- this thing is needed to ensure that transferButton does not capture the mouse. 
    -- This appears to be a glitch in dxgui, where disabled and then enabled components reacts to mouse down events for all controls.
    transferButton:releaseMouse()
    if commandGenerator == nil then return end
    local entryState = getEntryState()
    if entryState == ENTRY_STATES.WAYPOINTS then
      waypointCounterStatic:setText(""..#coordinateData.wayPoints.."/"..commandGenerator:getMaximalWaypointCount())
      -- prevent further entry if maximal number reached
      addWaypointButton:setEnabled((#coordinateData.wayPoints < commandGenerator:getMaximalWaypointCount()) and transferIsInactive())
    elseif entryState == ENTRY_STATES.FIXPOINTS then
      waypointCounterStatic:setText(""..#coordinateData.fixPoints.."/"..commandGenerator:getMaximalFixPointCount())
      -- prevent further entry if maximal number reached
      addWaypointButton:setEnabled((#coordinateData.fixPoints < commandGenerator:getMaximalFixPointCount()) and transferIsInactive())
    elseif entryState == ENTRY_STATES.TARGET_POINTS then
      waypointCounterStatic:setText(""..#coordinateData.targetPoints.."/"..commandGenerator:getMaximalTargetPointCount())
      -- prevent further entry if maximal number reached
      addWaypointButton:setEnabled((#coordinateData.targetPoints < commandGenerator:getMaximalTargetPointCount()) and transferIsInactive())
    end
  end

  local function normalize()
    Logging.info("Normalizing data structures")
    -- no commandGenerator nothing to do
    if commandGenerator == nil then return end
    -- trim number of waypoints
    Logging.info("Setting correct structure size")
    if #coordinateData.wayPoints > commandGenerator:getMaximalWaypointCount() then
      Logging.info("Prunning waypoints from "..#coordinateData.wayPoints.." to "..commandGenerator:getMaximalWaypointCount())
      coordinateData.wayPoints = { table.unpack(coordinateData.wayPoints, 1, math.min(#coordinateData.wayPoints, commandGenerator:getMaximalWaypointCount())) }
      Logging.info("Result: "..#coordinateData.wayPoints)
    end
    if #coordinateData.fixPoints > commandGenerator:getMaximalFixPointCount() then
      Logging.info("Prunning fixpoints...")
      coordinateData.fixPoints = { table.unpack(coordinateData.fixPoints, 1, math.min(#coordinateData.fixPoints, commandGenerator:getMaximalFixPointCount())) }
    end
    if #coordinateData.targetPoints > commandGenerator:getMaximalTargetPointCount() then
      Logging.info("Prunning target points...")
      coordinateData.targetPoints = { table.unpack(coordinateData.targetPoints, 1, math.min(#coordinateData.targetPoints, commandGenerator:getMaximalTargetPointCount())) }
    end    
    -- display waypoints vs maximal waypoint count
    if commandGenerator ~= nil then
      waypointCounterStatic:setText(""..#coordinateData.wayPoints.."/"..commandGenerator:getMaximalWaypointCount())
    end
    updateToggleStates(ENTRY_STATES.WAYPOINTS)
    statusWindow.statusStatic:setText("Entered: "..SharkPlanner.Base.CommandGeneratorFactory.getCurrentAirframe())
  end

  local function show()
    Logging.info("show")
    window:setVisible(true)
    window:setSkin(windowDefaultSkin)
    window:setHasCursor(true)
    crosshairWindow.WaypointCrosshair:setVisible(true)
    crosshairWindow:setVisible(true)
    -- show all widgets on control window
    local count = window:getWidgetCount()
  	for i = 1, count do
  		local index 		= i - 1
  		local widget 		= window:getWidget(index)
      widget:setVisible(true)
    end

    statusWindow:show()
    waypointListWindow:show()    
    -- normalize()
    -- updateToggleStates(getEntryState())
    -- updateWayPointUIState()
    -- DCS.unlockKeyboardInput(false)
    isHidden = false
  end

  local function hide()
    Logging.info("hide")
    window:setSkin(windowSkinHidden)
    -- do not: window:setVisible(false) it will remove the window from event loop
    -- window:setVisible(false) -- do not do this!!!

    -- hide all widgets on control window
  	local count = window:getWidgetCount()
  	for i = 1, count do
  		local index 		= i - 1
  		local widget 		= window:getWidget(index)
      widget:setVisible(false)
      widget:setFocused(false)
    end
    window:setHasCursor(false)

    statusWindow:hide()

    crosshairWindow:setVisible(false)
    waypointListWindow:hide()
    -- unlockKeyboardInput()
    isHidden = true
  end

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

  local function createControlWindow(crosshairWindow)
    Logging.info("Creating window")
    local x, y, w, h = crosshairWindow:getBounds()
    window = DialogLoader.spawnDialogFromFile(
        lfs.writedir() .. "Scripts\\SharkPlanner\\UI\\ControlWindow.dlg"
    )

    -- calculate actual width
    local totalWidth = 0
  	for i = 1, window:getWidgetCount() do
  		local index 		= i - 1
  		local widget 		= window:getWidget(index)
      local x, y, w, h = widget:getBounds()
      totalWidth = totalWidth + w
    end
    -- calculate offset to make it center aligned
    local offsetX = (w - totalWidth) / 2
    Logging.info("Setting bounds")
    window:setBounds(x + offsetX, y - 30, w, 30)
    hideButton = window.HideButton
    addWaypointButton = window.AddWaypointButton
    resetButton = window.ResetButton
    transferButton = window.TransferButton
    waypointCounterStatic = window.WaypointCounter
    waypointToggle = window.WaypointToggle
    fixpointToggle = window.FixpointToggle
    targetPointToggle = window.TargetPointToggle
    toggleGroup = {waypointToggle, fixpointToggle, targetPointToggle}
    updateToggleStates(ENTRY_STATES.WAYPOINTS)

    Logging.info("Getting default skin")
    windowDefaultSkin = window:getSkin()
    Logging.info("Showing the control window")
    window:setVisible(true)
    return window
  end

  local function isValidWaypoint(w)
    return w['x']['x'] == 0 and w['x']['y'] == -1 and w['x']['z'] == 0 and w['y']['x'] == 1 and w['y']['y'] == 0 and w['y']['z'] == 0 and w['z']['x'] == 0 and w['z']['y'] == 0 and w['z']['z'] == 1
  end

  local function logPosition(w)
    Logging.info( "cameraPosition: {\n"..
      "x={x="..w['x']['x']..", y="..w['x']['y']..", z="..w['x']['z'].."}\n"..
      "y={x="..w['y']['x']..", y="..w['y']['y']..", z="..w['y']['z'].."}\n"..
      "z={x="..w['z']['x']..", z="..w['z']['y']..", z="..w['z']['z'].."}\n"..
      "p={x="..w['p']['x']..", y="..w['p']['y']..", z="..w['p']['z'].."}\n}"
    )
  end

  local function addWaypoint()
    Logging.info("Add waypoint")
    local cameraPosition = Export.LoGetCameraPosition()
    logPosition(cameraPosition)
    if isValidWaypoint(cameraPosition) == false then
      Logging.info("Invalid waypoint, ignoring")
      addWaypointButton:setEnabled(true)
      return
    end

    hideButton:setEnabled(true)
    addWaypointButton:setEnabled(true)
    resetButton:setEnabled(true)
    transferButton:setEnabled(true)

    local x = cameraPosition['p']['x']
    local z = cameraPosition['p']['z']
    local elevation = Export.LoGetAltitude(x, z)
    local geoCoordinates = Export.LoLoCoordinatesToGeoCoordinates(x, z)
    for k, v in pairs(geoCoordinates) do
      Logging.info("geoCoordinates k: "..tostring(k).." v: "..tostring(v))
    end
    local position = SharkPlanner.Base.Position:new{x = x, y = elevation, z = z, longitude = geoCoordinates['longitude'], latitude = geoCoordinates['latitude'] }
    -- -- ensure coordinateData.fixPoints is created
    -- if coordinateData.fixPoints == nil then coordinateData.fixPoints = {} end
    -- -- ensure coordinateData.targetPoints are created
    -- if coordinateData.targetPoints == nil then coordinateData.targetPoints = {} end
    local entryState = getEntryState()
    if entryState == ENTRY_STATES.WAYPOINTS then
      coordinateData:addWaypoint(position)
    elseif entryState == ENTRY_STATES.FIXPOINTS then
      coordinateData:addFixpoint(position)
    elseif entryState == ENTRY_STATES.TARGET_POINTS then
      coordinateData:addTargetpoint(position)
    else
    end
    updateWayPointUIState()
  end

  local function reset()
    Logging.info("Reset")
    hideButton:setEnabled(true)
    addWaypointButton:setEnabled(true)
    resetButton:setEnabled(false)
    transferButton:setEnabled(false)
    coordinateData:reset()
    normalize()
    updateWayPointUIState()
  end

  local function transfer()
    Logging.info("Transfer")
    addWaypointButton:setEnabled(false)
    resetButton:setEnabled(false)
    transferButton:setFocused(false)
    transferButton:setEnabled(false)
    delayed_depress_commands = {}
    -- commandGenerator = SharkPlanner.Base.CommandGeneratorFactory.createGenerator(aircraftModel)
    -- TODO: transfer to new processor
    -- commands = schedule_commands(commandGenerator:generateCommands(coordinateData.wayPoints, coordinateData.fixPoints, coordinateData.targetPoints))
    SharkPlanner.Base.DCSEventHandlers.transfer(commandGenerator:generateCommands(coordinateData.wayPoints, coordinateData.fixPoints, coordinateData.targetPoints))
    -- TODO: handle in event handler
    statusWindow.progressBar:setValue(1)
    statusWindow.progressBar:setRange(1, #commands)
    statusWindow.progressBar:setVisible(true)
    statusWindow.statusStatic:setText("Transfer in progress...")
    updateWayPointUIState()
  end

  local function toggleStateChanged(self)
    Logging.info("Changed: "..self:getText().." to "..tostring(self:getState()))
    -- if state is changed true, we need to lower others
    if self:getState() then
      for k, v in pairs(toggleGroup) do
        if self == v then
        else
          v:setState(false)
        end
      end
    else
      -- if set to false: we need to check the others
      local overall_status = false
      for k, v in pairs(toggleGroup) do
        overall_status = overall_status or v:getState()
      end
      -- if none of the buttons is selected make sure that current is selected again
      if overall_status == false then
        self:setState(true)
      end
    end
    -- unfocus!
    self:setFocused(false)
    updateWayPointUIState()
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

    -- register waypointListWindow to receive events from controlWindow    
    window:addEventHandler(SharkPlanner.UI.ControlWindow.EventTypes.EntryModeChanged, waypointListWindow, waypointListWindow.OnEntryModeChanged)

    Logging.info("Hidding the window")
    window:hide()

    Logging.info("Window creation completed")
  end

  -- function eventHandlers.onSimulationStop()
  --   Logging.info("Simulation stopped")
  --   aircraftModel = nil
  --   commandGenerator = nil
  --   hide()
  -- end

  -- function eventHandlers.onPlayerChangeSlot(id)
  --   local my_id = net.get_my_player_id()
  --   if id == my_id then
  --     Logging.info("Game state: "..SharkPlanner.Base.GameState.getGameState())
  --     Logging.info("User has changed slot: "..tostring(SharkPlanner.Base.CommandGeneratorFactory.getCurrentAirframe()))
  --     aircraftModel = nil
  --     commandGenerator = nil
  --     hide()
  --   end
  -- end

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
