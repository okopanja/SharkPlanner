DEBUG_ENABLED=false

local function loadSharkPlanner()
  package.path = package.path .. ";.\\Scripts\\?.lua;.\\Scripts\\UI\\?.lua;"

  local DialogLoader = require("DialogLoader")
  local dxgui = require('dxgui')
  local Input = require("Input")
  local lfs = require("lfs")
  -- package.path = package.path .. ";"..lfs.writedir().."Scripts\\SharkPlanner\\?.lua;"
  local Skin = require("Skin")
  local SkinUtils = require("SkinUtils")
  local Terrain = require('terrain')
  local Tools = require("tools")
  local U = require("me_utilities")
  -- local utils = require("SharkPlanner.utils")
  require("SharkPlanner.VersionInfo")
  require("SharkPlanner.Position")
  local CommandGeneratorFactory = require("SharkPlanner.CommandGeneratorFactory")

  local window = nil
  local crosshairWindow = nil
  local statusWindow = nil
  local windowDefaultSkin = nil
  local windowSkinHidden = Skin.windowSkinChatMin()
  local hideButton = nil
  local addWaypointButton = nil
  local resetButton = nil
  local transferButton = nil
  local waypointTargetCheckBox = nil
  local statusStatic = nil
  local versionInfoStatic = nil
  local isHidden = true
  local isMissionActive = false
  local aircraftModel = nil
  local wayPoints = nil
  local targets = nil
  local commandGenerator = nil
  local commands = nil
  local delayed_depress_commands = nil
  -- local keyboardLocked = true

  local function log(message)
    net.log("[SharkPlanner] "..message)
  end

  log("Version: "..VERSION_INFO)

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

  local function show()
    log("show")
    window:setVisible(true)
    window:setSkin(windowDefaultSkin)
    window:setHasCursor(true)
    statusWindow:setVisible(true)
    crosshairWindow.WaypointCrosshair:setVisible(true)
    crosshairWindow:setVisible(true)

    -- show all widgets on control window
    local count = window:getWidgetCount()
  	for i = 1, count do
  		local index 		= i - 1
  		local widget 		= window:getWidget(index)
      widget:setVisible(true)
    end

    -- show all widgets on status window
    local count = statusWindow:getWidgetCount()
  	for i = 1, count do
  		local index 		= i - 1
  		local widget 		= window:getWidget(index)
      widget:setVisible(true)
    end

    -- DCS.unlockKeyboardInput(false)
    isHidden = false
  end

  local function hide()
    -- do not: window:setVisible(false) it remove the window from event loop
    log("hide")
    window:setSkin(windowSkinHidden)
    -- window:setVisible(false) -- do not do this!!!

    -- hide all widgets on conrol window
  	local count = window:getWidgetCount()
  	for i = 1, count do
  		local index 		= i - 1
  		local widget 		= window:getWidget(index)
      widget:setVisible(false)
      widget:setFocused(false)
    end
    window:setHasCursor(false)

    -- hide all widgets on conrol window
  	local count = statusWindow:getWidgetCount()
  	for i = 1, count do
  		local index 		= i - 1
  		local widget 		= window:getWidget(index)
      widget:setVisible(false)
      widget:setFocused(false)
    end
    statusWindow:setHasCursor(false)
    statusWindow:setVisible(false)

    crosshairWindow:setVisible(false)
    -- unlockKeyboardInput()
    isHidden = true
  end

  local function createCrosshairWindow()
    log("Creating crosshair window")
    crosshairWindow = DialogLoader.spawnDialogFromFile(
        lfs.writedir() .. "Scripts\\SharkPlanner\\UI\\CrosshairWindow.dlg"
    )
    -- crosshair picture location depends on user DCS folder, therefore we will reload the skin by constructing definite path at runtime
    local skin = crosshairWindow.WaypointCrosshair:getSkin()
    local crosshair_picture_path = lfs.writedir()..skin.skinData.states.released[1].picture.file
    log("Path to crosshair picture: "..crosshair_picture_path)
    crosshairWindow.WaypointCrosshair:setSkin(SkinUtils.setStaticPicture(crosshair_picture_path, skin))

    local screenWidth, screenHeight = dxgui.GetScreenSize()
    local x = math.floor(screenWidth/2) - 200
    local y = math.floor(screenHeight/2) - 200
    log("X: "..x.." Y: "..y)
    log("Setting bounds")
    crosshairWindow:setBounds(x, y, 400, 400)
    crosshairWindow:setTransparentForUserInput(true)
    log("Showing the crosshair window")
    crosshairWindow:setVisible(true)
    return crosshairWindow
  end

  local function createStatusWindow(crosshairWindow)
    log("Creating status window")
    local x, y, w, h = crosshairWindow:getBounds()
    statusWindow = DialogLoader.spawnDialogFromFile(
        lfs.writedir() .. "Scripts\\SharkPlanner\\UI\\StatusWindow.dlg"
    )

    local skin = statusWindow.Status:getSkin()
    skin.skinData.states.released[1].text.horzAlign.type = "min"
    statusWindow.Status:setSkin(skin)

    local screenWidth, screenHeight = dxgui.GetScreenSize()
    log("StatusWindow: setting bounds below crosshair")
    statusWindow:setBounds(x, y + h, w, 30)
    statusStatic = statusWindow.Status
    versionInfoStatic = statusWindow.VersionInfo
    versionInfoStatic:setText(VERSION_INFO)
    log("Showing StatusWindow")
    statusWindow:setVisible(true)
    return statusWindow
  end

  local function createControlWindow(crosshairWindow)
    log("Creating window")
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
    log("Setting bounds")
    window:setBounds(x + offsetX, y - 30, w, 30)
    hideButton = window.HideButton
    addWaypointButton = window.AddWaypointButton
    resetButton = window.ResetButton
    transferButton = window.TransferButton
    waypointCounterStatic = window.WaypointCounter
    waypointTargetCheckBox = window.WaypointTargetCheckBox
    waypointTargetCheckBox:setTooltipText("Waypoint entry")
    waypointTargetCheckBox:setState(false)

    log("Getting default skin")
    windowDefaultSkin = window:getSkin()
    log("Showing the control window")
    window:setVisible(true)
    return window
  end

  local function startWaypointEntry()
    log("Start waypoint entry")
    hideButton:setEnabled(true)
    addWaypointButton:setEnabled(true)
    resetButton:setEnabled(true)
    transferButton:setEnabled(false)
    waypointTargetCheckBox:setState(false)
  end

  local function isValidWaypoint(w)
    return w['x']['x'] == 0 and w['x']['y'] == -1 and w['x']['z'] == 0 and w['y']['x'] == 1 and w['y']['y'] == 0 and w['y']['z'] == 0 and w['z']['x'] == 0 and w['z']['y'] == 0 and w['z']['z'] == 1
  end

  local function logPosition(w)
    log( "cameraPosition: {\n"..
      "x={"..w['x']['x']..", y="..w['x']['y']..", z="..w['x']['z'].."}\n"..
      "y={"..w['y']['x']..", y="..w['y']['y']..", z="..w['y']['z'].."}\n"..
      "z={"..w['z']['x']..", z="..w['z']['y']..", z="..w['z']['z'].."}\n"..
      "p={"..w['p']['x']..", y="..w['p']['y']..", z="..w['p']['z'].."}\n}"
    )
  end

  local function updateWayPointUIState()
    if waypointTargetCheckBox:getState() == false then
      waypointTargetCheckBox:setTooltipText("Waypoint entry")
      waypointCounterStatic:setText(""..#wayPoints.."/"..commandGenerator:getMaximalWaypointCount())
      -- prevent further entry if maximal number reached
      addWaypointButton:setEnabled(#wayPoints < commandGenerator:getMaximalWaypointCount())
    else
      waypointTargetCheckBox:setTooltipText("Target entry")
      waypointCounterStatic:setText(""..#targets.."/"..commandGenerator:getMaximalTargetPointCount())
      -- prevent further entry if maximal number reached
      addWaypointButton:setEnabled(#targets < commandGenerator:getMaximalTargetPointCount())
    end
  end

  local function addWaypoint()
    log("Add waypoint")
    local cameraPosition = Export.LoGetCameraPosition()
    logPosition(cameraPosition)
    if isValidWaypoint(cameraPosition) == false then
      log("Invalid waypoint, ignoring")
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
    local wp = Position:new{x = x, y = elevation, z = z, longitude = geoCoordinates['longitude'], latitude = geoCoordinates['latitude'] }
    -- saveDump("geoCoordinates", geoCoordinates)
    -- ensure waypoints is created
    if wayPoints == nil then
      wayPoints = {}
    end
    -- ensure targets are created
    if targets == nil then
      targets = {}
    end
    if waypointTargetCheckBox:getState() == false then
      wayPoints[#wayPoints + 1] = wp
      statusStatic:setText("Waypoint added.")
    else
      targets[#targets + 1] = wp
      statusStatic:setText("Target added.")
    end
    updateWayPointUIState()
  end

  local function reset()
    log("Reset")
    hideButton:setEnabled(true)
    addWaypointButton:setEnabled(true)
    resetButton:setEnabled(false)
    transferButton:setEnabled(false)
    statusStatic:setText("")
    waypointTargetCheckBox:setTooltipText("Waypoint entry")
    waypointTargetCheckBox:setState(false)
    if commandGenerator ~= nil then
      waypointCounterStatic:setText("0/"..commandGenerator:getMaximalWaypointCount())
    end
    wayPoints = {}
    targets = {}
  end

  local function schedule_commands(commands)
    -- introduce 100ms delay at start
    local schedule_time = DCS.getModelTime() + 0.100
    log("Expected schedule start: "..schedule_time)
    for k, command in pairs(commands) do
      command:setSchedule(schedule_time)
      log(command:getText())
      -- adjust the schedule_time by delay caused by current command. (causes all remaning to be delayed)
      schedule_time = schedule_time + (command:getDelay() / 1000)
    end
    log("Expected schedule end: "..schedule_time)
    return commands
  end

  local function transfer()
    log("Transfer")
    delayed_depress_commands = {}
    commandGenerator = CommandGeneratorFactory.createGenerator(aircraftModel)
    commands = schedule_commands(commandGenerator:generateCommands(wayPoints, targets))
    statusStatic:setText("Transfer started")
  end

  local function initializeUI()
    -- check if window already exists
    if window ~= nil then
      return
    end
    crosshairWindow = createCrosshairWindow()
    window = createControlWindow(crosshairWindow)
    statusWindow = createStatusWindow(crosshairWindow)

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
    waypointTargetCheckBox:addChangeCallback(
      function(self)
        updateWayPointUIState()
  		  log("Changed: "..tostring(self:getState()))
      end
    )



    log("Adding hotkey callback")
    -- add open/close hotkey
    window:addHotKeyCallback(
        "Ctrl+Shift+space",
        function()
            log("Hotkey pressed!")
            local currentAircraftModel = CommandGeneratorFactory.getCurrentAirframe()
            if CommandGeneratorFactory.isSupported(currentAircraftModel) then
            -- if isMissionActive then
              if isHidden == true then
                  if currentAircraftModel ~= aircraftModel then
                    eventHandlers.onSimulationStart()
                  end
                  show()
              else
                  hide()
              end
            -- end
            end
        end
    )

    log("Hidding the window")
    hide()
    log("Window creation completed")
  end

  eventHandlers = {}

  function eventHandlers.onSimulationStart()
    log("Simulation started")
    isMissionActive = true
    if not window then
        log("Windows is not yet created")
        initializeUI()
    end
    aircraftModel = CommandGeneratorFactory.getCurrentAirframe()
    if aircraftModel ~= nil then
      log("Detected: "..aircraftModel)
      if CommandGeneratorFactory.isSupported(aircraftModel) then
        log("Airframe is supported: "..aircraftModel)
        log("Creating command generator")
        commandGenerator = CommandGeneratorFactory.createGenerator(aircraftModel)
        if commandGenerator ~= nil then
          log("Command generator for was created")
        else
          log("Command generator for was not created")
        end
        reset()
      else
        log("Airframe is not supported: "..aircraftModel)
      end
    end
  end

  function eventHandlers.onSimulationStop()
    log("Simulation stopped")
    isMissionActive = false
    aircraftModel = nil
    commandGenerator = nil
    hide()
  end

  function eventHandlers.onPlayerChangeSlot(id)
    local my_id = net.get_my_player_id()
    if id == my_id then
      log("User has changed slot")
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
    -- ensure we run command checks at most every 10 miliseconds
    local current_time = DCS.getModelTime()
    if( lastTime + minimalInterval <= current_time) then
      -- lastTime = current_time
      if commands ~= nil then
        -- determine what can be depressed
        local last_command_due_for_depress = find_last_due_command_index(delayed_depress_commands, current_time)
        if last_command_due_for_depress > 0 then
          log("Last command due for depress: "..last_command_due_for_depress)
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
          log("Commands found: "..last_scheduled_command)
          for i = 1, last_scheduled_command do
            local command = commands[i]
            log(command:getText())
            Export.GetDevice(command:getDevice()):performClickableAction(command:getCode(), command:getIntensity())
            log("Pressed")
            -- check if the command needs depress
            if command:getDepress() then
              -- check for Delay
              if command:getDelay() == 0 then
                -- if the delay is 0, the command can be immidiatly depressed
                Export.GetDevice(command:getDevice()):performClickableAction(command:getCode(), 0)
                log("Depressed")
              else
                -- Delayed commands can not be depressed now
                command:setSchedule(current_time + (command:getDelay() / 1000))
                delayed_depress_commands[#delayed_depress_commands + 1] = command
                log("Queued for delayed depress")
              end
            end
          end
          -- remove depressed commands (includes both depressed and those that were moved to delayed depress queue)
          for i = 1, last_scheduled_command do
            table.remove(commands, 1)
          end
          -- invalidate commands
          if #commands == 0 then
            log("Commands have been fully executed.")
            statusStatic:setText("Transfer completed")
            commands = nil
          end
        end
      end
    end
  end

  log("Registering event handlers")
  DCS.setUserCallbacks(eventHandlers)
end

local status, err = pcall(loadSharkPlanner)
if not status then
    net.log("[SharkPlanner] load error: " .. tostring(err))
end
