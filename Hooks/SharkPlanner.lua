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
  local eventHandlers = {}
  local window = nil
  local crosshairWindow = nil
  local statusWindow = nil
  local waypointListWindow = nil
  local windowDefaultSkin = nil
  local windowSkinHidden = Skin.windowSkinChatMin()
  local hideButton = nil
  local addWaypointButton = nil
  local resetButton = nil
  local transferButton = nil
  local waypointCounterStatic = nil
  local waypointToggle = nil
  local fixpointToggle = nil
  local targetPointToggle = nil
  local toggleGroup = nil
  local isHidden = true
  local isMissionActive = false
  local aircraftModel = nil
  local coordinateData = SharkPlanner.Base.CoordinateData
  local commandGenerator = nil
  local commands = {}
  local delayed_depress_commands = {}
  local ENTRY_STATES = {}
  ENTRY_STATES.WAYPOINTS = "W"
  ENTRY_STATES.FIXPOINTS = "F"
  ENTRY_STATES.TARGET_POINTS = "T"
  -- handle lua 5.4 deprecation
  if table.unpack == nil then
    table.unpack = unpack
  end
  -- local keyboardLocked = true

  local function unlockKeyboardInput()
      if keyboardLocked then
          DCS.unlockKeyboardInput(true)
          keyboardLocked = false
      end
  end

  local function lockKeyboardInput()
      if keyboardLocked then
          return
      end
      local keyboardEvents = Input.getDeviceKeys(Input.getKeyboardDeviceName())
      DCS.lockKeyboardInput(keyboardEvents)
      keyboardLocked = true
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
    updateToggleStates(getEntryState())
    updateWayPointUIState()
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
        lfs.writedir() .. "Scripts\\SharkPlanner\\UI\\Window.dlg"
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

  local function startWaypointEntry()
    Logging.info("Start waypoint entry")
    hideButton:setEnabled(true)
    addWaypointButton:setEnabled(true)
    resetButton:setEnabled(true)
    transferButton:setEnabled(false)
    updateToggleStates(ENTRY_STATES.WAYPOINTS)
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
    -- saveDump("geoCoordinates", geoCoordinates)
    -- ensure waypoints is created
    -- if coordinateData.wayPoints == nil then coordinateData.wayPoints = {} end
    -- ensure coordinateData.fixPoints is created
    if coordinateData.fixPoints == nil then coordinateData.fixPoints = {} end
    -- ensure coordinateData.targetPoints are created
    if coordinateData.targetPoints == nil then coordinateData.targetPoints = {} end
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

  local function schedule_commands(commands)
    -- introduce 100ms delay at start
    local schedule_time = DCS.getModelTime() + 0.100
    Logging.info("Expected schedule start: "..schedule_time)
    for k, command in pairs(commands) do
      command:setSchedule(schedule_time)
      Logging.info(command:getText())
      -- adjust the schedule_time by delay caused by current command. (causes all remaning to be delayed)
      schedule_time = schedule_time + (command:getDelay() / 1000)
    end
    Logging.info("Expected schedule end: "..schedule_time)
    return commands
  end

  local function transfer()
    Logging.info("Transfer")
    addWaypointButton:setEnabled(false)
    resetButton:setEnabled(false)
    transferButton:setFocused(false)
    transferButton:setEnabled(false)
    delayed_depress_commands = {}
    -- commandGenerator = SharkPlanner.Base.CommandGeneratorFactory.createGenerator(aircraftModel)
    commands = schedule_commands(commandGenerator:generateCommands(coordinateData.wayPoints, coordinateData.fixPoints, coordinateData.targetPoints))
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
    window = createControlWindow(crosshairWindow)
    statusWindow = SharkPlanner.UI.StatusWindow:new{crosshairWindow = crosshairWindow}
    -- statusWindow = createStatusWindow(crosshairWindow)

    waypointListWindow = SharkPlanner.UI.WaypointListWindow.createWaypointListWindow(crosshairWindow)
    -- register waypointListWindow to receive events from coordanteData
    coordinateData:addEventHandler(SharkPlanner.Base.CoordinateData.EventTypes.AddWayPoint, waypointListWindow, waypointListWindow.OnAddWaypoint)
    coordinateData:addEventHandler(SharkPlanner.Base.CoordinateData.EventTypes.RemoveWayPoint, waypointListWindow, waypointListWindow.OnRemoveWaypoint)
    coordinateData:addEventHandler(SharkPlanner.Base.CoordinateData.EventTypes.AddFixPoint, waypointListWindow, waypointListWindow.OnAddFixpoint)
    coordinateData:addEventHandler(SharkPlanner.Base.CoordinateData.EventTypes.RemoveFixPoint, waypointListWindow, waypointListWindow.OnRemoveFixpoint)
    coordinateData:addEventHandler(SharkPlanner.Base.CoordinateData.EventTypes.AddTargetPoint, waypointListWindow, waypointListWindow.OnAddTargetpoint)
    coordinateData:addEventHandler(SharkPlanner.Base.CoordinateData.EventTypes.RemoveTargetPoint, waypointListWindow, waypointListWindow.OnRemoveTargetpoint)
    coordinateData:addEventHandler(SharkPlanner.Base.CoordinateData.EventTypes.Reset, waypointListWindow, waypointListWindow.OnReset)
    -- register statusWindow to receive events fronm coordinateData
    coordinateData:addEventHandler(SharkPlanner.Base.CoordinateData.EventTypes.AddWayPoint, statusWindow, statusWindow.OnAddWaypoint)
    coordinateData:addEventHandler(SharkPlanner.Base.CoordinateData.EventTypes.RemoveWayPoint, statusWindow, statusWindow.OnRemoveWaypoint)
    coordinateData:addEventHandler(SharkPlanner.Base.CoordinateData.EventTypes.AddFixPoint, statusWindow, statusWindow.OnAddFixpoint)
    coordinateData:addEventHandler(SharkPlanner.Base.CoordinateData.EventTypes.RemoveFixPoint, statusWindow, statusWindow.OnRemoveFixpoint)
    coordinateData:addEventHandler(SharkPlanner.Base.CoordinateData.EventTypes.AddTargetPoint, statusWindow, statusWindow.OnAddTargetpoint)
    coordinateData:addEventHandler(SharkPlanner.Base.CoordinateData.EventTypes.RemoveTargetPoint, statusWindow, statusWindow.OnRemoveTargetpoint)
    coordinateData:addEventHandler(SharkPlanner.Base.CoordinateData.EventTypes.Reset, statusWindow, statusWindow.OnReset)

    -- register UI callbacks
    hideButton:addMouseDownCallback(
      function(self)
        hide()
      end
    )
    addWaypointButton:addMouseDownCallback(
      function(self)
        addWaypoint()
      end
    )
    addWaypointButton:addMouseUpCallback(
      function(self)
        addWaypointButton:setFocused(false)
      end
    )
    resetButton:addMouseDownCallback(
      function(self)
        reset()
      end
    )
    resetButton:addMouseUpCallback(
      function(self)    
        resetButton:setFocused(false)
      end
    )
    transferButton:addMouseDownCallback(
      function(self)
        transfer()
      end
    )
    transferButton:addMouseUpCallback(
      function(self)
        transferButton:setFocused(false)
      end
    )

    waypointToggle:addChangeCallback(toggleStateChanged)
    fixpointToggle:addChangeCallback(toggleStateChanged)
    targetPointToggle:addChangeCallback(toggleStateChanged)

    Logging.info("Adding hotkey callback")
    -- add open/close hotkey
    window:addHotKeyCallback(
        "Ctrl+Shift+space",
        function()
            Logging.info("Hotkey pressed!")
            Logging.info("Game state: "..SharkPlanner.Base.GameState.getGameState())
            local currentAircraftModel = SharkPlanner.Base.CommandGeneratorFactory.getCurrentAirframe()
            Logging.info("Current airframe: "..tostring(currentAircraftModel))
            if CommandGeneratorFactory.isSupported(currentAircraftModel) then
              Logging.info("Airframe is supported: "..currentAircraftModel)
            -- if isMissionActive then
              if isHidden == true then
                  if currentAircraftModel ~= aircraftModel then
                    eventHandlers.onSimulationStart()
                  end
                  show()
              else
                  hide()
              end
            else
              Logging.info("Airframe is not supported: "..currentAircraftModel)
            end
        end
    )

    Logging.info("Hidding the window")
    hide()
    reset()
    Logging.info("Window creation completed")
  end

  function eventHandlers.onSimulationStart()
    Logging.info("Simulation started")
    isMissionActive = true
    if not window then
        Logging.info("Windows is not yet created")
        initializeUI()
    end
    Logging.info("Game state: "..SharkPlanner.Base.GameState.getGameState())
    aircraftModel = SharkPlanner.Base.CommandGeneratorFactory.getCurrentAirframe()
    if aircraftModel ~= nil then
      Logging.info("Detected: "..aircraftModel)
      if CommandGeneratorFactory.isSupported(aircraftModel) then
        Logging.info("Airframe is supported: "..aircraftModel)
        Logging.info("Creating command generator")
        commandGenerator = SharkPlanner.Base.CommandGeneratorFactory.createGenerator(aircraftModel)
        if commandGenerator ~= nil then
          Logging.info("Command generator for was created")
        else
          Logging.info("Command generator for was not created")
        end
        -- reset()
        normalize()
      else
        Logging.info("Airframe is not supported: "..aircraftModel)
      end
    end
  end

  function eventHandlers.onSimulationStop()
    Logging.info("Simulation stopped")
    isMissionActive = false
    aircraftModel = nil
    commandGenerator = nil
    hide()
  end

  function eventHandlers.onPlayerChangeSlot(id)
    local my_id = net.get_my_player_id()
    if id == my_id then
      Logging.info("Game state: "..SharkPlanner.Base.GameState.getGameState())
      Logging.info("User has changed slot: "..tostring(SharkPlanner.Base.CommandGeneratorFactory.getCurrentAirframe()))
      isMissionActive = false
      aircraftModel = nil
      commandGenerator = nil
      hide()
    end
  end

  function find_last_due_command_index(command_list, reference_time)
    local last_due_command_index = 0
    for k, command in pairs(command_list) do
      if command:getSchedule() > reference_time then
        return k - 1
      end
      last_due_command_index = k
    end
    return last_due_command_index
  end

  local minimalInterval = 0.001
  local lastTime = DCS.getModelTime()

  function eventHandlers.onSimulationFrame()
    -- ensure we run command checks at most every minimalInterval miliseconds
    local current_time = DCS.getModelTime()
    if( lastTime + minimalInterval <= current_time) then
      -- lastTime = current_time
      if transferIsActive() then
        -- determine what can be depressed
        local last_command_due_for_depress = find_last_due_command_index(delayed_depress_commands, current_time)
        if last_command_due_for_depress > 0 then
          Logging.info("Last command due for depress: "..last_command_due_for_depress)
          -- depress all matching
          for i = 1, last_command_due_for_depress do
            local command = delayed_depress_commands[i]
            Export.GetDevice(command:getDevice()):performClickableAction(command:getCode(), 0)
          end
          -- remove depressed commands
          for i = 1, last_command_due_for_depress do
            table.remove(delayed_depress_commands, 1)
          end
          -- if the delayed_depress_commands is still not empty we need to wait further, and not proceed with scheduled!
          if #delayed_depress_commands > 0 then
            return
          end
        end

        -- determine commands that have reach the point for execition
        local last_scheduled_command = find_last_due_command_index(commands, current_time)
        if last_scheduled_command > 0 then
          Logging.info("Commands found: "..last_scheduled_command)
          for i = 1, last_scheduled_command do
            local command = commands[i]
            Logging.info(command:getText())
            Export.GetDevice(command:getDevice()):performClickableAction(command:getCode(), command:getIntensity())
            Logging.info("Pressed")
            -- check if the command needs depress
            if command:getDepress() then
              -- check for Delay
              if command:getDelay() == 0 then
                -- if the delay is 0, the command can be immidiatly depressed
                Export.GetDevice(command:getDevice()):performClickableAction(command:getCode(), 0)
                Logging.info("Depressed")
              else
                -- Delayed commands can not be depressed now
                command:setSchedule(current_time + (command:getDelay() / 1000))
                delayed_depress_commands[#delayed_depress_commands + 1] = command
                Logging.info("Queued for delayed depress")
              end
            end
          end
          -- remove depressed commands (includes both depressed and those that were moved to delayed depress queue)
          for i = 1, last_scheduled_command do
            table.remove(commands, 1)
          end
          local min, max = statusWindow.progressBar:getRange()
          statusWindow.progressBar:setValue(max - #commands)
        end

        if transferIsInactive() then
          -- Transfer has stopped
          Logging.info("Commands have been fully executed.")
          -- TODO: event handler
          statusWindow.statusStatic:setText("Transfer completed")
          statusWindow.progressBar:setVisible(false)
          -- transferButton:setEnabled(true)
          updateWayPointUIState()
        end
      end
    end
  end

  Logging.info("Registering event handlers")
  DCS.setUserCallbacks(eventHandlers)
  Logging.info("Game state: "..SharkPlanner.Base.GameState.getGameState())
end

local status, err = pcall(loadSharkPlanner)
if not status then
  net.log("[SharkPlanner] load error: " .. tostring(err))
end
