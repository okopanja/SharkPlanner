-- provide sub-packages and modules
local Logging = require("SharkPlanner.Utils.Logging")
local coordinateData = require("SharkPlanner.Base.CoordinateData")
local DialogLoader = require("DialogLoader")
local GameState = require("SharkPlanner.Base.GameState")
local CommandGeneratorFactory = require("SharkPlanner.Base.CommandGeneratorFactory")
local DCSEventHandlers = require("SharkPlanner.Base.DCSEventHandlers")
local Position = require("SharkPlanner.Base.Position")
local dxgui = require('dxgui')
local Input = require("Input")
local lfs = require("lfs")
local Skin = require("Skin")
local SkinUtils = require("SkinUtils")

local ENTRY_STATES = {
  WAYPOINTS = "W",
  FIXPOINTS = "F",
  TARGET_POINTS = "T"
}

local ControlWindow = DialogLoader.spawnDialogFromFile(
    lfs.writedir() .. "Scripts\\SharkPlanner\\UI\\ControlWindow.dlg"
)

-- Constructor
function ControlWindow:new(o)
    Logging.info("Creating status window")
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    local x, y, w, h = o.crosshairWindow:getBounds()
    Logging.info("Creating window")

    -- calculate actual width
    local totalWidth = 0
  	for i = 1, o:getWidgetCount() do
  		local index 		= i - 1
  		local widget 		= o:getWidget(index)
      local x, y, w, h = widget:getBounds()
      totalWidth = totalWidth + w
    end
    -- calculate offset to make it center aligned
    local offsetX = (w - totalWidth) / 2
    Logging.info("Setting bounds")
    o:setBounds(x + offsetX, y - 30, w, 30)
    o.toggleGroup = {
      self.WaypointToggle,
      self.FixpointToggle,
      self.TargetPointToggle
    }
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
    -- self.updateToggleStates(ENTRY_STATES.WAYPOINTS)

    Logging.info("Getting default skin")
    o.windowDefaultSkin = self:getSkin()
    Logging.info("Getting hidden windwo skin")
    o.windowSkinHidden = Skin.windowSkinChatMin()

    Logging.info("Showing the control window")
    o:show()
    
    -- register UI callbacks
    o.HideButton:addChangeCallback(
      function(button)
        Logging.info("Hidding...")
        o:hide()
      end
    )
    o.HideButton:addMouseUpCallback(
      function(button)
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
        -- transfer()
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
            Logging.info("Game state: "..GameState.getGameState())
            local currentAircraftModel = CommandGeneratorFactory.getCurrentAirframe()
            Logging.info("Current airframe: "..tostring(currentAircraftModel))
            if CommandGeneratorFactory.isSupported(currentAircraftModel) then
              Logging.info("Airframe is supported: "..currentAircraftModel)
              if o:isHidden() then
                  if currentAircraftModel ~= DCSEventHandlers.aircraftModel then
                    DCSEventHandlers:onSimulationStart()
                  end
                  o:show()
              else
                  o:hide()
              end
            else
              Logging.info("Airframe is not supported: "..tostring(currentAircraftModel))
            end
        end
    )
    o.commandGenerator = nil
    return o
end

function ControlWindow:show()
  Logging.info("Showing ControlWindow")
  self:setVisible(true)
  self:setSkin(self.windowDefaultSkin)
  self:setHasCursor(true)

  local count = self:getWidgetCount()
  for i = 1, count do
    local index 		= i - 1
    local widget 		= self:getWidget(index)
    widget:setVisible(true)
  end
  self.is_hidden = false

  self.crosshairWindow:setVisible(true)
  self.statusWindow:show()
  self.waypointListWindow:show()
end

function ControlWindow:hide()
  Logging.info("Hidding ControlWindow")
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
end

function ControlWindow:isHidden()
  return self.is_hidden
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
  -- disable if too many
  if #eventArg.wayPoints >= self.commandGenerator:getMaximalWaypointCount() then
    self.AddWaypointButton:setEnabled(false)
  end
  -- display count if in proper entry state
  if self:getEntryState() == ENTRY_STATES.WAYPOINTS then
    self.WaypointCounter:setText(""..#self.coordinateData.wayPoints.."/"..self.commandGenerator:getMaximalWaypointCount())
  end
  self.TransferButton:setEnabled(true)
  self.ResetButton:setEnabled(true)
end

function ControlWindow:OnRemoveWaypoint(eventArg)
  if #eventArg.wayPoints < self.commandGenerator:getMaximalWaypointCount() then
    self.AddWaypointButton:setEnabled(true)
  end
  -- display count if in proper entry state
  if self:getEntryState() == ENTRY_STATES.WAYPOINTS then
    self.WaypointCounter:setText(""..#self.coordinateData.wayPoints.."/"..self.commandGenerator:getMaximalWaypointCount())
  end
end

function ControlWindow:OnAddFixPoint(eventArg)
  if #eventArg.fixPoints >= self.commandGenerator:getMaximalFixPointCount() then
    self.AddWaypointButton:setEnabled(false)
  end
  -- display count if in proper entry state
  if self:getEntryState() == ENTRY_STATES.FIXPOINTS then
    self.WaypointCounter:setText(""..#self.coordinateData.fixPoints.."/"..self.commandGenerator:getMaximalFixPointCount())
  end
  self.TransferButton:setEnabled(true)
  self.ResetButton:setEnabled(true)
end

function ControlWindow:OnRemoveFixPoint(eventArg)
  if #eventArg.fixPoints < self.commandGenerator:getMaximalFixPointCount() then
    self.AddWaypointButton:setEnabled(true)
  end
  -- display count if in proper entry state
  if self:getEntryState() == ENTRY_STATES.FIXPOINTS then
    self.WaypointCounter:setText(""..#self.coordinateData.fixPoints.."/"..self.commandGenerator:getMaximalFixPointCount())
  end
end

function ControlWindow:OnAddTargetPoint(eventArg)
  if #eventArg.targetPoints >= self.commandGenerator:getMaximalTargetPointCount() then
    self.AddWaypointButton:setEnabled(false)
  end
  -- display count if in proper entry state
  if self:getEntryState() == ENTRY_STATES.TARGET_POINTS then
    self.WaypointCounter:setText(""..#self.coordinateData.targetPoints.."/"..self.commandGenerator:getMaximalTargetPointCount())
  end
  self.TransferButton:setEnabled(true)
  self.ResetButton:setEnabled(true)
end

function ControlWindow:OnRemoveTargetPoint(eventArg)
  if #eventArg.targetPoints < self.commandGenerator:getMaximalTargetPointCount() then
    self.AddWaypointButton:setEnabled(true)
  end
  -- display count if in proper entry state
  if self:getEntryState() == ENTRY_STATES.TARGET_POINTS then
    self.WaypointCounter:setText(""..#self.coordinateData.targetPoints.."/"..self.commandGenerator:getMaximalTargetPointCount())
  end
end

function ControlWindow:OnReset(eventArgs)
  Logging.info("Reset: setting controls")
  self:updateToggleStates(ENTRY_STATES.WAYPOINTS)
  self.HideButton:setEnabled(true)
  self.AddWaypointButton:setEnabled(true)
  self.ResetButton:setEnabled(false)
  self.TransferButton:setEnabled(false)
  -- display count if in proper entry state
  if self:getEntryState() == ENTRY_STATES.WAYPOINTS then
    self.WaypointCounter:setText(""..#self.coordinateData.wayPoints.."/"..self.commandGenerator:getMaximalWaypointCount())
  end
end

function ControlWindow:OnPlayerEnteredSupportedVehicle(eventArg)
  self.commandGenerator = eventArg.commandGenerator
  self:updateToggleStates(ENTRY_STATES.WAYPOINTS)
  self.WaypointCounter:setText(""..#self.coordinateData.wayPoints.."/"..self.commandGenerator:getMaximalWaypointCount())
  self.ResetButton:setEnabled(false)
  self.TransferButton:setEnabled(false)
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
  -- updateWayPointUIState()
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
end

return ControlWindow