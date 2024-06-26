-- provide sub-packages and modules
local Logging = require("SharkPlanner.Utils.Logging")
local coordinateData = require("SharkPlanner.Base.CoordinateData")
local DialogLoader = require("DialogLoader")
local GameState = require("SharkPlanner.Base.GameState")
local CommandGeneratorFactory = require("SharkPlanner.Base.CommandGeneratorFactory")
local DCSEventHandlers = require("SharkPlanner.Base.DCSEventHandlers")
local Position = require("SharkPlanner.Base.Position")
local SkinHelper = require("SharkPlanner.UI.SkinHelper")
local dxgui = require('dxgui')
local Input = require("Input")
local lfs = require("lfs")
local Skin = require("Skin")
local SkinUtils = require("SkinUtils")
local Utils = require("SharkPlanner.Utils")

local ENTRY_STATES = {
  WAYPOINTS = "W",
  FIXPOINTS = "F",
  TARGET_POINTS = "T"
}

EventTypes = {
  EntryModeChanged = 1
}

local ControlWindow = DialogLoader.spawnDialogFromFile(
    lfs.writedir() .. "Scripts\\SharkPlanner\\UI\\ControlWindow.dlg"
)

ControlWindow.EventTypes = EventTypes
ControlWindow.EntryStates = ENTRY_STATES

-- Constructor
function ControlWindow:new(o)
    Logging.info("Creating status window")
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    
    Logging.info("Creating window")
    o:updateBounds()

    o.toggleGroup = {
      self.WaypointToggle,
      self.FixpointToggle,
      self.TargetPointToggle
    }

    o.hotKeyCallbacks = {}

    self.WaypointToggle:addChangeCallback(
      function(button)
        o:OnToggleStateChanged(button)
      end
    )
    self.FixpointToggle:addChangeCallback(
      function(button)
        o:OnToggleStateChanged(button)
      end
    )
    self.TargetPointToggle:addChangeCallback(
      function(button)
        o:OnToggleStateChanged(button)
      end
    )
    self.WaypointCounter:addChangeCallback(
      function(button)
        o:OnWayPointCounterChanged(button)
      end
    )
    self.OptionsButton:addChangeCallback(
      function(button)
        o:OnOptionsButtonChanged(button)
      end
    )
    o.OptionsButton:addMouseUpCallback(
      function(button)
        button:setFocused(false)
      end
    )

    Logging.info("Getting default skin")
    o.windowDefaultSkin = self:getSkin()
    Logging.info("Getting hidden windwo skin")
    o.windowSkinHidden = Skin.windowSkinChatMin()

    Logging.info("Showing the control window")
    o:show()
    
    -- register UI callbacks
    o.HideButton:addChangeCallback(
      function(button)
        Logging.info("Hidding: ChangeCallback")
        o:hide()
        o:enableKeyboardCommands()
      end
    )
    o.HideButton:addMouseUpCallback(
      function(button)
        Logging.info("Hidding: MouseUpCallback")
        button:setFocused(false)
      end
    )
    o.AddWaypointButton:addChangeCallback(
      function(button)
        Logging.info("Adding waypoint...")
        o:addWaypoint()
      end
    )
    o.AddWaypointButton:addMouseUpCallback(
      function(button)
        button:setFocused(false)
      end
    )
    o.ResetButton:addChangeCallback(
      function(button)
        Logging.info("Reseting...")
        o:reset()
      end
    )
    o.ResetButton:addMouseUpCallback(
      function(button)    
        button:setFocused(false)
      end
    )
    o.TransferButton:addChangeCallback(
      function(button)
        Logging.info("Transfering...")
        o:transfer()
      end
    )
    o.TransferButton:addMouseUpCallback(
      function(button)
        button:setFocused(false)
      end
    )

    Logging.info("Adding hotkey callback")
    -- add open/close hotkey
    o:addHotKeyCallback(
        "Ctrl+Shift+space",
        function()
            Logging.info("Hotkey pressed!")
            Logging.info("Game state (hotkey pressed): "..GameState.getGameState())
            local currentAircraftModel = CommandGeneratorFactory.getCurrentAirframe()
            Logging.info("Current airframe: "..tostring(currentAircraftModel))
            if CommandGeneratorFactory.isSupported(currentAircraftModel) then
              Logging.info("Airframe is supported: "..currentAircraftModel)
              if o:isHidden() then
                  if currentAircraftModel ~= DCSEventHandlers.aircraftModel then
                    DCSEventHandlers:onSimulationStart()
                  end
                  o:show()
                  self:disableKeyboardCommands(o.AlwaysEnabledKeys)
              else
                  o:hide()
                  self:enableKeyboardCommands()
              end
            else
              Logging.info("Airframe is not supported: "..tostring(currentAircraftModel))
            end
        end
    )

    o.eventHandlers = {
      [EventTypes.EntryModeChanged] = {},
    }
    o.commandGenerator = nil
    o:addEventHandler(ControlWindow.EventTypes.EntryModeChanged, o, o.OnEntryModeChanged)
    -- loading of own skins skins
    local buttonAmberSkin = SkinHelper.loadSkin("buttonSkinSharkPlannerAmber")
    o.HideButton:setSkin(buttonAmberSkin)
    o.AddWaypointButton:setSkin(buttonAmberSkin)
    o.ResetButton:setSkin(buttonAmberSkin)
    o.TransferButton:setSkin(buttonAmberSkin)

    local toggleLongGreenSkin = SkinHelper.loadSkin("toggleSkinSharkPlannerLongGreen")
    o.WaypointCounter:setSkin(toggleLongGreenSkin)
    o.OptionsButton:setSkin(toggleLongGreenSkin)

    local toggleShortGreenSkin = SkinHelper.loadSkin("toggleSkinSharkPlannerShortGreen")
    for i, toggle in pairs(o.toggleGroup) do
      toggle:setSkin(toggleShortGreenSkin)
    end
    -- this piece of code is not supposed to run on user side
    -- it is meant for development purposes. 
    if o.ExperimentButton then
      Logging.info("Exeprimental mode activated")
      o.ExperimentButton:setSkin(buttonAmberSkin)
      o.ExperimentButton:addChangeCallback(
        function(button)
          o:runExperiment()
        end
      )
      o.ExperimentButton:addMouseUpCallback(
        function(button)
            button:setFocused(false)
        end
      )
    end
    local eventTable = Input.getEnvTable()
    o.AlwaysEnabledKeys = {
      eventTable.Events.KEY_F1,
      eventTable.Events.KEY_F2,
      eventTable.Events.KEY_F3,
      eventTable.Events.KEY_F4,
      eventTable.Events.KEY_F5,
      eventTable.Events.KEY_F6,
      eventTable.Events.KEY_F7,
      eventTable.Events.KEY_F8,
      eventTable.Events.KEY_F9,
      eventTable.Events.KEY_F10,
      eventTable.Events.KEY_F11,
      eventTable.Events.KEY_F12,
      eventTable.Events.KEY_F13,
      eventTable.Events.KEY_F14,
      eventTable.Events.KEY_F15,
      eventTable.Events.KEY_ESCAPE,
      eventTable.Events.KEY_NUMPAD0,
      eventTable.Events.KEY_NUMPAD1,
      eventTable.Events.KEY_NUMPAD2,
      eventTable.Events.KEY_NUMPAD3,
      eventTable.Events.KEY_NUMPAD4,
      eventTable.Events.KEY_NUMPAD5,
      eventTable.Events.KEY_NUMPAD6,
      eventTable.Events.KEY_NUMPAD7,
      eventTable.Events.KEY_NUMPAD8,
      eventTable.Events.KEY_NUMPAD9,
      eventTable.Events.KEY_PAUSE,
      eventTable.Events.KEY_LSHIFT,   -- must be disabled for hot key to work, otherwise it looks the state
      eventTable.Events.KEY_LCONTROL, -- must be disabled for hot key to work, otherwise it looks the state
      -- eventTable.Events.KEY_SPACE -- this one does not need to be locked
}
    return o
end
function ControlWindow:unRegisterHotKeyCallbacks()
  for hotKeyString, callback in pairs(self.hotKeyCallbacks) do
    self:removeHotKeyCallback(hotKeyString, callback)
  end
  self.hotKeyCallbacks = {}
end

function ControlWindow:registerHotKeyCallbacks()
  self:unRegisterHotKeyCallbacks()
  self.hotKeyCallbacks["space"] =
    function()
      if not self:isHidden() and self.AddWaypointButton:getEnabled() then
        self:addWaypoint()
      end
    end
  self.hotKeyCallbacks["Shift+delete"] =
    function()
        if not self:isHidden() and self.ResetButton:getEnabled() then
          self:reset()
        end
    end
  self.hotKeyCallbacks["delete"] =
    function()
      if not self:isHidden() and self.TransferButton:getEnabled() then
        self:removeLastPoint()
      end
    end
  self.hotKeyCallbacks["return"] =
    function()
        Logging.info("Pressed return")
        if not self:isHidden() and self.TransferButton:getEnabled() then
          self:transfer()
        end
    end
  self.hotKeyCallbacks["Shift+return"] =
    function()
        Logging.info("Pressed shift+return")
        if not self:isHidden() and self.ExperimentButton:getEnabled() then
          self:runExperiment()
        end
    end
  for hotKeyString, callback in pairs(self.hotKeyCallbacks) do
    self:addHotKeyCallback(hotKeyString, callback)
  end
end

function ControlWindow:updateBounds()
      local x, y, w, h = self.crosshairWindow:getBounds()
      -- calculate actual width
      local totalWidth = 0
      for i = 1, self:getWidgetCount() do
        local index 		= i - 1
        local widget 		= self:getWidget(index)
        local x, y, w, h = widget:getBounds()
        if not ((widget == self.ExperimentButton) and (lfs.attributes(lfs.writedir()..[[Scripts\SharkPlanner\experiment.lua]]) == nil)) then
          totalWidth = totalWidth + w
        end
      end
      -- calculate offset to make it center aligned
      local offsetX = (w - totalWidth) / 2
      Logging.info("Setting bounds")
      self:setBounds(x + offsetX, y - 26, w, 26)
end

function ControlWindow:show()
  Logging.info("Showing ControlWindow")
  self:setVisible(true)
  self:setSkin(self.windowDefaultSkin)
  self:setHasCursor(true)
  local experiment_enabled = lfs.attributes(lfs.writedir()..[[Scripts\SharkPlanner\experiment.lua]]) ~= nil
  self:updateBounds()
  local count = self:getWidgetCount()
  for i = 1, count do
    local index 		= i - 1
    local widget 		= self:getWidget(index)
    if widget == self.ExperimentButton then
      widget:setVisible(experiment_enabled)
    else
      widget:setVisible(true)
    end
  end

  self.is_hidden = false

  self.crosshairWindow:setVisible(true)
  self.statusWindow:show()
  if self.WaypointCounter:getState() then
    self.waypointListWindow:show()
    self.chartWindow:show()
  end
  if self.OptionsButton:getState() then
    self.optionsWindow:show()
  end
  self:updateUIState()
  self:registerHotKeyCallbacks()
end

function ControlWindow:hide()
  Logging.info("Hidding ControlWindow")
  self:unRegisterHotKeyCallbacks()
  self:setSkin(self.windowSkinHidden)
  self.is_hidden = true
  -- do not: window:setVisible(false) it will remove the window from event loop
  -- window:setVisible(false) -- do not do this!!!

  -- hide all widgets on control window
  local count = self:getWidgetCount()
  for i = 1, count do
    local index 		= i - 1
    local widget 		= self:getWidget(index)
    widget:setVisible(false)
    widget:setFocused(false)
  end
  self:setHasCursor(false)
  self.crosshairWindow:setVisible(false)
  self.statusWindow:hide()
  self.waypointListWindow:hide()
  self.chartWindow:hide()
  self.optionsWindow:hide()
  self.transferStatusWindow:hide()
end

function ControlWindow:isHidden()
  return self.is_hidden
end

function ControlWindow:disableKeyboardCommands(alwaysEnabledKeys)
  Logging.debug("Getting keyboardEvents")
  local keyboardEvents	= Input.getDeviceKeys(Input.getKeyboardDeviceName())
  local lockedKeyboardEvents = {}
  Logging.debug("Filtering out always enabled keys")
  for i, v in ipairs(keyboardEvents) do
    if Utils.Table.is_in_values(alwaysEnabledKeys, v) == false then
      Logging.debug("Included: "..v)
      lockedKeyboardEvents[#lockedKeyboardEvents + 1] = v
    else
      Logging.debug("Excluded: "..v)
    end
  end
	DCS.lockKeyboardInput(lockedKeyboardEvents)
end

function ControlWindow:enableKeyboardCommands()
  DCS.unlockKeyboardInput(false)
end

function ControlWindow:addWaypoint()
  local cameraPosition = Export.LoGetCameraPosition()
  self:logPosition(cameraPosition)
  if self:isValidWaypoint(cameraPosition) == false then
    Logging.info("Invalid waypoint, ignoring")
    return
  end
  local x = cameraPosition['p']['x']
  local z = cameraPosition['p']['z']
  local elevation = Export.LoGetAltitude(x, z)
  local geoCoordinates = Export.LoLoCoordinatesToGeoCoordinates(x, z)
  for k, v in pairs(geoCoordinates) do
    Logging.info("geoCoordinates k: "..tostring(k).." v: "..tostring(v))
  end
  local position = Position:new{x = x, y = elevation, z = z, longitude = geoCoordinates['longitude'], latitude = geoCoordinates['latitude'] }
  local entryState = self:getEntryState()
  if entryState == ENTRY_STATES.WAYPOINTS then
    self.coordinateData:addWaypoint(position)
  elseif entryState == ENTRY_STATES.FIXPOINTS then
    self.coordinateData:addFixpoint(position)
  elseif entryState == ENTRY_STATES.TARGET_POINTS then
    self.coordinateData:addTargetpoint(position)
  else
    Logging.info("Unknown Entry State.")
  end
end

function ControlWindow:reset()
  self.coordinateData:reset()
end

function ControlWindow:removeLastPoint()
  local entryState = self:getEntryState()
  if entryState == ENTRY_STATES.WAYPOINTS then
    self.coordinateData:removeWaypoint(#self.coordinateData.wayPoints)
    Logging.debug("Removed last waypoint")
  elseif entryState == ENTRY_STATES.FIXPOINTS then
    self.coordinateData:removeFixpoint(#self.coordinateData.fixPoints)
    Logging.debug("Removed last fixpoint")
  elseif entryState == ENTRY_STATES.TARGET_POINTS then
    self.coordinateData:removeTargetpoint(#self.coordinateData.targetPoints)
    Logging.debug("Removed last target point")
  else
    Logging.error("Unknown Entry State.")
  end
end

function ControlWindow:runExperiment()
  self:updateUIState()
  Logging.info("Unloading old expirimental code")
  package["SharkPlanner.experiment"] = nil
  package.loaded["SharkPlanner.experiment"] = nil
  _G["SharkPlanner.experiment"] = nil
  Logging.info("Loading new expirimental code")
  local context = {
    coordinateData = self.coordinateData,
    statusWindow = self.statusWindow,
    crosshairWindow = self.crosshairWindow,
    optionsWindow = self.optionsWindow,
    controlWindow = self
  }
  local status, experiment  = pcall(require("SharkPlanner.experiment"), context)
  if status then
    Logging.info("Experimental code finished!")
  else
    Logging.error("Loading of experiment.lua has failed due to: "..experiment)
  end
end

function ControlWindow:transfer()
  DCSEventHandlers.transfer(self.commandGenerator:generateCommands(coordinateData.wayPoints, coordinateData.fixPoints, coordinateData.targetPoints))
  self:updateUIState()
end

function ControlWindow:getEntryState()
  if self.WaypointToggle:getState() then
    return ENTRY_STATES.WAYPOINTS
  end
  if self.FixpointToggle:getState() then
    return ENTRY_STATES.FIXPOINTS
  end
  if self.TargetPointToggle:getState() then
    return ENTRY_STATES.TARGET_POINTS
  end
  return nil
end

function ControlWindow:OnAddWaypoint(eventArg)
  self:updateUIState()
end

function ControlWindow:OnRemoveWaypoint(eventArg)
  self:updateUIState()
end

function ControlWindow:OnAddFixPoint(eventArg)
  self:updateUIState()
end

function ControlWindow:OnRemoveFixPoint(eventArg)
  self:updateUIState()
end

function ControlWindow:OnAddTargetPoint(eventArg)
  self:updateUIState()
end

function ControlWindow:OnRemoveTargetPoint(eventArg)
  self:updateUIState()
end

function ControlWindow:OnReset(eventArgs)
  self:updateUIState()
end

function ControlWindow:OnLocalCoordinatesRecalculated(eventArgs)
  if eventArgs.overallResult then
    self:updateToggleStates(ENTRY_STATES.WAYPOINTS)
  end
end

function ControlWindow:OnPlayerEnteredSupportedVehicle(eventArgs)
  self.commandGenerator = eventArgs.commandGenerator
  self:updateToggleStates(ENTRY_STATES.WAYPOINTS)
  self:updateUIState()
end

function ControlWindow:OnSimulationStarted(eventArgs)
end

function ControlWindow:OnPlayerChangeSlot(eventArgs)
  self:hide()
end

function ControlWindow:OnSimulationStopped(eventArgs)
  self:hide()
end

function ControlWindow:OnTransferFinished(eventArgs)
  self:updateUIState()
end

function ControlWindow:OnToggleStateChanged(button)
  Logging.info("Changed: "..button:getText().." to "..tostring(button:getState()))
  -- if state is changed true, we need to lower others
  if button:getState() then
    for k, v in pairs(self.toggleGroup) do
      if button == v then
      else
        v:setState(false)
      end
    end
  else
    -- if set to false: we need to check the others
    local overall_status = false
    for k, v in pairs(self.toggleGroup) do
      overall_status = overall_status or v:getState()
    end
    -- if none of the buttons is selected make sure that current is selected again
    if overall_status == false then
      button:setState(true)
    end
  end
  -- unfocus!
  button:setFocused(false)

  self:updateWaypointCounter()
  self:updateUIState()
  
  local eventArgs = {
    entryState = self:getEntryState()
  }
  self:dispatchEvent(EventTypes.EntryModeChanged, eventArgs)
end

function ControlWindow:OnEntryModeChanged(eventArgs)
  if eventArgs.entryState == ENTRY_STATES.WAYPOINTS then
    Logging.info("Updated tooltip: waypoint")
    self.AddWaypointButton:setTooltipText("Add waypoint")
  elseif self:getEntryState() == ENTRY_STATES.FIXPOINTS then
    Logging.info("Updated tooltip: fix point")
    self.AddWaypointButton:setTooltipText("Add fix point")
  elseif self:getEntryState() == ENTRY_STATES.TARGET_POINTS then
    Logging.info("Updated tooltip: target point")
    self.AddWaypointButton:setTooltipText("Add target point")
  end
end


function ControlWindow:OnWayPointCounterChanged(button)
  if button:getState() then
    self.waypointListWindow:show()
    self.chartWindow:show()
  else
    self.waypointListWindow:hide()
    self.chartWindow:hide()
  end
  button:setFocused(false)
end

function ControlWindow:OnOptionsButtonChanged(button)
  if button:getState() then
    self.optionsWindow:show()
  else
    self.optionsWindow:hide()
    self:updateWaypointCounter()
  end
  button:setFocused(false)
end



function ControlWindow:logPosition(w)
  Logging.info( "cameraPosition: {\n"..
    "x={x="..w['x']['x']..", y="..w['x']['y']..", z="..w['x']['z'].."}\n"..
    "y={x="..w['y']['x']..", y="..w['y']['y']..", z="..w['y']['z'].."}\n"..
    "z={x="..w['z']['x']..", z="..w['z']['y']..", z="..w['z']['z'].."}\n"..
    "p={x="..w['p']['x']..", y="..w['p']['y']..", z="..w['p']['z'].."}\n}"
  )
end

function ControlWindow:isValidWaypoint(w)
  return w['x']['x'] == 0 and w['x']['y'] == -1 and w['x']['z'] == 0 and w['y']['x'] == 1 and w['y']['y'] == 0 and w['y']['z'] == 0 and w['z']['x'] == 0 and w['z']['y'] == 0 and w['z']['z'] == 1
end

function ControlWindow:updateToggleStates(state)
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

  self.WaypointToggle:setState(waypointState)
  self.FixpointToggle:setState(fixpointState)
  self.TargetPointToggle:setState(targetPointState)
  local eventArgs = {
    entryState = self:getEntryState()
  }
  self:dispatchEvent(EventTypes.EntryModeChanged, eventArgs)
end

function ControlWindow:updateWaypointCounter()
  if self:getEntryState() == ENTRY_STATES.WAYPOINTS then
    self.WaypointCounter:setText(""..#self.coordinateData.wayPoints.."/"..self.commandGenerator:getMaximalWaypointCount())
  end
  if self:getEntryState() == ENTRY_STATES.FIXPOINTS then
    self.WaypointCounter:setText(""..#self.coordinateData.fixPoints.."/"..self.commandGenerator:getMaximalFixPointCount())
  end
  if self:getEntryState() == ENTRY_STATES.TARGET_POINTS then
    self.WaypointCounter:setText(""..#self.coordinateData.targetPoints.."/"..self.commandGenerator:getMaximalTargetPointCount())
  end
end

function ControlWindow:updateUIState()
  self.ResetButton:setEnabled((#coordinateData.wayPoints > 0 or #coordinateData.fixPoints > 0 or #coordinateData.targetPoints > 0) and DCSEventHandlers.transferIsInactive())
  self.TransferButton:setEnabled((#coordinateData.wayPoints > 0 or #coordinateData.fixPoints > 0 or #coordinateData.targetPoints > 0) and DCSEventHandlers.transferIsInactive() and self.commandGenerator:getAircraftName() ~= "Combined Arms")
  -- this thing is needed to ensure that transferButton does not capture the mouse. 
  -- This appears to be a glitch in dxgui, where disabled and then enabled components reacts to mouse down events for all controls.
  self.TransferButton:releaseMouse()
  if self.commandGenerator == nil then return end
  local entryState = self:getEntryState()
  if entryState == ENTRY_STATES.WAYPOINTS then
    self.WaypointCounter:setText(""..#coordinateData.wayPoints.."/"..self.commandGenerator:getMaximalWaypointCount())
    -- prevent further entry if maximal number reached
    self.AddWaypointButton:setEnabled((#coordinateData.wayPoints < self.commandGenerator:getMaximalWaypointCount()) and DCSEventHandlers.transferIsInactive())
  elseif entryState == ENTRY_STATES.FIXPOINTS then
    self.WaypointCounter:setText(""..#coordinateData.fixPoints.."/"..self.commandGenerator:getMaximalFixPointCount())
    -- prevent further entry if maximal number reached
    self.AddWaypointButton:setEnabled((#coordinateData.fixPoints < self.commandGenerator:getMaximalFixPointCount()) and DCSEventHandlers.transferIsInactive())
  elseif entryState == ENTRY_STATES.TARGET_POINTS then
    self.WaypointCounter:setText(""..#coordinateData.targetPoints.."/"..self.commandGenerator:getMaximalTargetPointCount())
    -- prevent further entry if maximal number reached
    self.AddWaypointButton:setEnabled((#coordinateData.targetPoints < self.commandGenerator:getMaximalTargetPointCount()) and DCSEventHandlers.transferIsInactive())
  end
end

function ControlWindow:addEventHandler(eventType, object, eventHandler)
  self.eventHandlers[eventType][#self.eventHandlers[eventType] + 1] = { object = object, eventHandler = eventHandler }
end

-- the dispatchEvent for now executes directly the event handlers
function ControlWindow:dispatchEvent(eventType, eventArg)
  for k, eventHandlerInfo in pairs(self.eventHandlers[eventType]) do
      eventHandlerInfo.eventHandler(eventHandlerInfo.object, eventArg)
  end
end


return ControlWindow