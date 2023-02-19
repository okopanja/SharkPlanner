DEBUG_ENABLED=false

local function loadFlightPlanner()
  package.path = package.path .. ";.\\Scripts\\?.lua;.\\Scripts\\UI\\?.lua;"

  local DialogLoader = require("DialogLoader")
  local dxgui = require('dxgui')
  local Input = require("Input")
  local lfs = require("lfs")
  -- package.path = package.path .. ";"..lfs.writedir().."Scripts\\FlightPlanner\\?.lua;"
  local Skin = require("Skin")
  local SkinUtils = require("SkinUtils")
  local Terrain = require('terrain')
  local Tools = require("tools")
  local U = require("me_utilities")
  -- local utils = require("FlightPlanner.utils")
  -- local waypoint = require("FlightPlanner.Waypoint")
  require("FlightPlanner.utils")
  require("FlightPlanner.Position")
  local CommandGeneratorFactory = require("FlightPlanner.CommandGeneratorFactory")

  local window = nil
  local crosshairWindow = nil
  local windowDefaultSkin = nil
  local windowSkinHidden = Skin.windowSkinChatMin()
  local hideButton = nil
  local addWaypointButton = nil
  local resetButton = nil
  local transferButton = nil
  local isHidden = true
  local isMissionActive = false
  local aircraftModel = nil
  local wayPoints = nil
  local commandGenerator = nil
  local commands = nil
  local delayed_depress_commands = nil
  -- local keyboardLocked = true

  local function log(message)
    net.log("[FlightPlanner] "..message)
  end

  function saveDump(dump_name, reference)
    local file = io.open(lfs.writedir() .."\\Scripts\\dumps\\"..dump_name..".lua",'w')
    file:write(dump(dump_name,reference))
    file:close()
  end

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
    crosshairWindow.WaypointCrosshair:setVisible(true)
    crosshairWindow:setVisible(true)

    -- show all widgets
    local count = window:getWidgetCount()
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

    -- hide all widgets!
  	local count = window:getWidgetCount()
  	for i = 1, count do
  		local index 		= i - 1
  		local widget 		= window:getWidget(index)
      widget:setVisible(false)
    end

    window:setHasCursor(false)
    crosshairWindow:setVisible(false)
    -- unlockKeyboardInput()
    isHidden = true
  end

  local function createCrosshairWindow()
    log("Creating crosshair window")
    crosshairWindow = DialogLoader.spawnDialogFromFile(
        lfs.writedir() .. "Scripts\\FlightPlanner\\UI\\CrosshairWindow.dlg"
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

  local function createControlWindow(crosshairWindow)
    log("Creating window")
    x, y, w, h = crosshairWindow:getBounds()
    window = DialogLoader.spawnDialogFromFile(
        lfs.writedir() .. "Scripts\\FlightPlanner\\UI\\Window.dlg"
    )
    log("Setting bounds")
    window:setBounds(x, y - 20, w, 20)
    hideButton = window.HideButton
    addWaypointButton = window.AddWaypointButton
    resetButton = window.ResetButton
    transferButton = window.TransferButton
    waypointCounterStatic = window.WaypointCounter
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
  end

  local function addWaypoint()
    log("Add waypoint")
    hideButton:setEnabled(true)
    addWaypointButton:setEnabled(true)
    resetButton:setEnabled(true)
    transferButton:setEnabled(true)

    local cameraPosition = Export.LoGetCameraPosition()
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
    wayPoints[#wayPoints + 1] = wp
    waypointCounterStatic:setText(""..#wayPoints.."/"..commandGenerator:getMaximalWaypointCount())

    -- prevent further entry
    if #wayPoints == commandGenerator:getMaximalWaypointCount() then
      addWaypointButton:setEnabled(false)
    end
  end

  local function reset()
    log("Reset")
    hideButton:setEnabled(true)
    addWaypointButton:setEnabled(true)
    resetButton:setEnabled(false)
    transferButton:setEnabled(false)
    if commandGenerator ~= nil then
      waypointCounterStatic:setText("0/"..commandGenerator:getMaximalWaypointCount())
    end
    wayPoints = {}
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
    -- hideButton:setEnabled(true)
    -- addWaypointButton:setEnabled(false)
    -- resetButton:setEnabled(false)
    -- transferButton:setEnabled(false)
    -- create list of commands for delayed depress, initially empty
    delayed_depress_commands = {}
    commandGenerator = CommandGeneratorFactory.createGenerator(aircraftModel)
    commands = schedule_commands(commandGenerator:generateCommands(wayPoints))
  end

  local function initializeUI()
    -- check if window already exists
    if window ~= nil then
      return
    end
    crosshairWindow = createCrosshairWindow()
    window = createControlWindow(crosshairWindow)

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
    resetButton:addMouseDownCallback(
      function(self)
        reset()
      end
    )
    transferButton:addMouseDownCallback(
      function(self)
        transfer()
      end
    )


    log("Adding hotkey callback")
    -- add open/close hotkey
    window:addHotKeyCallback(
        "Ctrl+Shift+y",
        function()
            log("Hotkey pressed!")
            if aircraftModel == 'Ka-50_3' then
            -- if isMissionActive then
              if isHidden == true then
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
    local selfData = Export.LoGetSelfData()
    if selfData ~= nil then
      log("selfData is not nil")
      aircraftModel = selfData["Name"]
      log("Detected: "..aircraftModel)
      log("Creating command generator")
      commandGenerator = CommandGeneratorFactory.createGenerator(aircraftModel)
      -- saveDump("commandGenerator", commandGenerator)
      if commandGenerator ~= nil then
        log("Command generator created: "..aircraftModel)
      else
        log("Command generator not available for: "..aircraftModel)
      end
      reset()
    else
      log("selfData is nil")
    end
  end

  -- function eventHandlers.onPlayerChangeSlot(id)
  --   log("Player slot changed")
  --   eventHandlers.onSimulationStart()
  -- end

  function eventHandlers.onSimulationStop()
    isMissionActive = false
    aircraftModel = nil
    commandFactoryGenerator = nil
    commandGenerator = nil
    hide()
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

  local minimalInterval = 0.010
  local lastTime = DCS.getModelTime()

  function eventHandlers.onSimulationFrame()
    -- ensure we run command checks at most every 10 miliseconds
    local current_time = DCS.getModelTime()
    if( lastTime + minimalInterval <= current_time) then
      if commandGenerator == nil then
        eventHandlers.onSimulationStart()
      end
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
        end
      end
    end
  end

  log("Registering event handlers")
  DCS.setUserCallbacks(eventHandlers)
end

local status, err = pcall(loadFlightPlanner)
if not status then
    net.log("[FlightPlanner] load error: " .. tostring(err))
end
