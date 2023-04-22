-- provide sub-packages and modules
local Logging = require("SharkPlanner.Utils.Logging")
local coordinateData = require("SharkPlanner.Base.CoordinateData")
local SkinHelper = require("SharkPlanner.UI.SkinHelper")
local DialogLoader = require("DialogLoader")
local dxgui = require('dxgui')
local Input = require("Input")
local lfs = require("lfs")
local Skin = require("Skin")
local SkinUtils = require("SkinUtils")
local window = nil
local Static = require('Static')
local Button = require('Button')
local math = require('math')

-- Boilercode to load templates for dynamicly created controls
local templateDialog	= DialogLoader.spawnDialogFromFile(lfs.writedir() .. 'Scripts\\SharkPlanner\\UI\\WaypointListWindowTemplates.dlg')
-- record templates in table for later user
local templates = {
  buttonTemplate = templateDialog.buttonTemplate,
  staticCellValidNotSelectedTemplate = templateDialog.staticCellValidNotSelectedTemplate,
  staticCellValidSelected = templateDialog.staticCellValidSelected
}
-- remove tempalte widgets from templatDialog
for k, v in pairs(templates) do
  templateDialog:removeWidget(v)
end
-- kill the template dialog
templateDialog:kill()

-- define Row types
local POINT_TYPES = {
  Waypoint = 1,
  Fixpoint = 2,
  Targetpoint = 3
}


-- Initiate the dialog
local WaypointListWindow = DialogLoader.spawnDialogFromFile(
          lfs.writedir() .. "Scripts\\SharkPlanner\\UI\\WaypointListWindow.dlg"
      )


-- Constructor
function WaypointListWindow:new(o)
  Logging.info("Creating waypoint list window")
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  local x, y, w, h = o.crosshairWindow:getBounds()

  local width, height = self.scrollGrid:getSize()
  o.scrollGrid:setBounds(0, 0, width, h)
  o:setBounds(x + w, y, width, h)
  o.removeButtonSkin = SkinHelper.loadSkin("buttonSkinSharkPlannerAmber")
  return o
end

-- show window
function WaypointListWindow:show()
  self:setVisible(true)
  local count = self:getWidgetCount()
  for i = 1, count do
    local index 		= i - 1
    local widget 		= self:getWidget(index)
    widget:setVisible(true)
  end
end

-- hide window
function WaypointListWindow:hide()
  self:setVisible(false)
  local count = self:getWidgetCount()
  for i = 1, count do
    local index 		= i - 1
    local widget 		= self:getWidget(index)
    widget:setVisible(false)
  end
end

function WaypointListWindow:OnAddWaypoint(eventArgs)
  self:_createPositionRow(eventArgs.wayPointIndex, eventArgs.wayPoint, coordinateData.removeWaypoint)
end

function WaypointListWindow:OnRemoveWaypoint(eventArgs)
  Logging.info("Removing: "..eventArgs.wayPointIndex)
  self.scrollGrid:removeRow(eventArgs.wayPointIndex - 1)
  -- renumber later waypoints
  for i = eventArgs.wayPointIndex, #eventArgs.wayPoints  do
    Logging.info("Removing: "..tostring(i))
    -- renumber button row_number
    self.scrollGrid:getCell(4, i - 1).row_number = i
    -- renumber visible ordinal
    self.scrollGrid:getCell(0, i - 1):setText(tostring(i))
  end
end

function WaypointListWindow:OnAddFixpoint(eventArgs)
  self:_createPositionRow(eventArgs.fixPointIndex, eventArgs.fixPoint, coordinateData.removeFixpoint)
end

function WaypointListWindow:OnRemoveFixpoint(eventArgs)
  Logging.info("Removing: "..eventArgs.fixPointIndex)
  self.scrollGrid:removeRow(eventArgs.fixPointIndex - 1)
  -- renumber later fixpoints
  for i = eventArgs.fixPointIndex, #eventArgs.fixPoints  do
    Logging.info("Removing: "..tostring(i))
    -- renumber button row_number
    self.scrollGrid:getCell(4, i - 1).row_number = i
    -- renumber visible ordinal
    self.scrollGrid:getCell(0, i - 1):setText(tostring(i))
  end
end

function WaypointListWindow:OnAddTargetpoint(eventArgs)
  self:_createPositionRow(eventArgs.targetPointIndex, eventArgs.targetPoint, coordinateData.removeTargetpoint)
end

function WaypointListWindow:OnRemoveTargetpoint(eventArgs)
  Logging.info("Removing: "..eventArgs.targetPointIndex)
  self.scrollGrid:removeRow(eventArgs.targetPointIndex - 1)
  -- renumber later targetpoints
  for i = eventArgs.targetPointIndex, #eventArgs.targetPoints  do
    Logging.info("Removing: "..tostring(i))
    -- renumber button row_number
    self.scrollGrid:getCell(4, i - 1).row_number = i
    -- renumber visible ordinal
    self.scrollGrid:getCell(0, i - 1):setText(tostring(i))
  end
end

function WaypointListWindow:OnReset(eventArgs)
  self.scrollGrid:removeAllRows()
end

function WaypointListWindow:OnEntryModeChanged(eventArgs)
  Logging.info("Entry mode changed!")
  self.scrollGrid:removeAllRows()
  local positions = nil
  local removalFunction = nil
  if eventArgs.entryState == "W" then
    positions = coordinateData.wayPoints
    removalFunction = coordinateData.removeWaypoint
  elseif eventArgs.entryState == "F" then
    positions = coordinateData.fixPoints
    removalFunction = coordinateData.removeFixpoint
  elseif eventArgs.entryState == "T" then
    positions = coordinateData.targetPoints
    removalFunction = coordinateData.removeTargetpoint
  else
    return
  end
  for i = 1, #positions do
    Logging.info(tostring(i))
    self:_createPositionRow(i, positions[i], removalFunction)
  end
end

function WaypointListWindow:_createPositionRow(row_number, position, removalFunction)
  -- add row number
  self.scrollGrid:insertRow(30)
  -- create row number
  local static = Static.new()
  static:setText(tostring(row_number))
  static:setSkin(templates.staticCellValidNotSelectedTemplate:getSkin())
  self.scrollGrid:setCell(0, row_number - 1, static)

  -- add latitude
  static = Static.new()
  static:setText(position:getLatitudeDMSstr())
  static:setSkin(templates.staticCellValidNotSelectedTemplate:getSkin())
  self.scrollGrid:setCell(1, row_number - 1, static)

  -- add longitude
  static = Static.new()
  static:setText(position:getLongitudeDMSstr())
  static:setSkin(templates.staticCellValidNotSelectedTemplate:getSkin())
  self.scrollGrid:setCell(2, row_number - 1, static)

  -- add altitude
  static = Static.new()
  static:setText(""..math.floor(position:getAltitude() + 0.5).."m")
  static:setSkin(templates.staticCellValidNotSelectedTemplate:getSkin())
  
  self.scrollGrid:setCell(3, row_number - 1, static)

  -- add delete button
  local button = Button.new()

  -- button:setSkin(Skin.getSkin("buttonSkinAwacs"))
  button:setSkin(self.removeButtonSkin)
  button:setText("X")
  button:setBounds(2, 2, 26, 26)
  button:setVisible(true)
  -- record the row_number for later use
  button.row_number = row_number
  -- record the position for later use
  button.position = position
  -- record point function
  button.removalFunction = removalFunction
  button:addChangeCallback(
    function(self)
      self.removalFunction(coordinateData, self.row_number)
    end
  )
  self.scrollGrid:setCell(4, row_number - 1, button)
end

return  WaypointListWindow
