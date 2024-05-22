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
local SpinBox = require('SpinBox')
local VertLayout = require("VertLayout")
local Button = require('Button')
local Panel = require('Panel')
local LayoutFactory = require("LayoutFactory")
local Utils = require("SharkPlanner.Utils")
local math = require('math')
local FileDialog = require("SharkPlanner.UI.FileDialogWorkaround")
local ControlWindow = require("SharkPlanner.UI.ControlWindow")
local MouseCursor = require("SharkPlanner.UI.MouseCursor")

-- Boilercode to load templates for dynamicly created controls
local templateDialog	= DialogLoader.spawnDialogFromFile(lfs.writedir() .. 'Scripts\\SharkPlanner\\UI\\WaypointListWindowTemplates.dlg')
-- record templates in table for later user
local templates = {
  buttonTemplate = templateDialog.buttonTemplate,
  staticCellValidNotSelectedTemplate = templateDialog.staticCellValidNotSelectedTemplate,
  staticCellValidSelected = templateDialog.staticCellValidSelected,
  editBoxTemplate = templateDialog.staticCellValidSelected2,
  -- spinBox = templateDialog.spinBox
  spinBox = SkinHelper.setMinSize(Utils.Table.clone(SkinHelper.loadSkin("spinBox")), 80, 26),
  deltaElevation = SkinHelper.setMinSize(Utils.Table.clone(templateDialog.staticCellValidNotSelectedTemplate:getSkin()),80,17)
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

local DRAG_COLUMN = 0

-- Initiate the dialog
local DeadReckoningWindow = DialogLoader.spawnDialogFromFile(
          lfs.writedir() .. "Scripts\\SharkPlanner\\UI\\DeadReckoningWindow.dlg"
      )


-- Constructor
function DeadReckoningWindow:new(o)
  Logging.info("Creating waypoint list window")
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  local x, y, w, h = o.crosshairWindow:getBounds()

  local width, height = self.scrollGrid:getSize()
  o.scrollGrid.isDragged = false
  o.scrollGrid.dragStartX = -1
  o.scrollGrid.dragStartY = -1
  o.scrollGrid:addMouseLeaveCallback(
    function(self, x, y, button)
      Logging.debug("Mouse LEAVE: ".."X: "..tostring(x).." Y: "..tostring(y))
      if self.isDragged then
        self.isDragged = false
        self.dragStartX = -1
        self.dragStartY = -1
        self:getRoot():popMouseCursor()
      end
      self:getRoot():popMouseCursor()
    end
  )
  o.scrollGrid:addMouseEnterCallback(
    function(self, x, y, button)
      if self.isDragged then
        Logging.debug("Mouse ENTER: ".."X: "..tostring(x).." Y: "..tostring(y))
      end
    end
  )
  o.scrollGrid:addMouseMoveCallback(
    function(self, x, y, button)
      Logging.debug("Mouse MOVE: ".."X: "..tostring(x).." Y: "..tostring(y))
      local startColumn, startRow = self:getMouseCursorColumnRow(x, y)
      Logging.debug("startRow: "..tostring(startRow).." startColumn: "..tostring(startColumn) )
      if button == 0 and self.isDragged == false then
        local startColumn, startRow = self:getMouseCursorColumnRow(x, y)
        if startColumn == DRAG_COLUMN and startRow >= 0 then
          if self:getRoot():getMouseCursor() ~= MouseCursor.FINGER_POINT_UP then
            self:getRoot():pushMouseCursor(MouseCursor.FINGER_POINT_UP)
          end
        else
          self:getRoot():popMouseCursor()
        end
      end
      if self.isDragged then
      end
    end
  )
  o.scrollGrid:addMouseDownCallback(
    function(self, x, y, button)
      if button == 1 then
        Logging.debug("Mouse DOWN: ".."X: "..tostring(x).." Y: "..tostring(y))
        local startColumn, startRow = self:getMouseCursorColumnRow(x, y)
        Logging.debug("startRow: "..tostring(startRow).." startColumn: "..tostring(startColumn) )
        if startColumn == DRAG_COLUMN then
          self.dragStartX = x
          self.dragStartY = y
          self.isDragged = true
          self:getRoot():pushMouseCursor(MouseCursor.HAND_UP)
        end
        -- self:captureMouse()
      end
    end
  )
  o.scrollGrid:addMouseUpCallback(
    function(self, x, y, button)
      if button == 1 then
        Logging.debug("Mouse UP: ".."X: "..tostring(x).." Y: "..tostring(y))
        local startColumn, startRow = self:getMouseCursorColumnRow(self.dragStartX, self.dragStartY)
        Logging.debug("startRow: "..tostring(startRow).." startColumn: "..tostring(startColumn) )
        local endColumn, endRow = self:getMouseCursorColumnRow(x, y)
        Logging.debug("endRow: "..tostring(endRow).." endColumn: "..tostring(endColumn) )
        if self.isDragged then
          Logging.debug("Drag ended")
          self.isDragged = false
          self.dragStartX = -1
          self.dragStartY = -1
          if endColumn ~= DRAG_COLUMN then
            self:getRoot():popMouseCursor()
          end
          if startRow ~= endRow then
            if o.entryMode == ControlWindow.EntryStates.WAYPOINTS then
              coordinateData:moveWaypoint(startRow + 1, endRow + 1)
            elseif  o.entryMode == ControlWindow.EntryStates.FIXPOINTS then
              coordinateData:moveFixpoint(startRow + 1, endRow + 1)
            elseif  o.entryMode == ControlWindow.EntryStates.TARGET_POINTS then
              coordinateData:moveTargetpoint(startRow + 1, endRow + 1)
            else
            end
          end
        end
      end
      self:getRoot():popMouseCursor()
    end
  )

  local headerCellCallback = function(self, x, y, button)
    Logging.debug("Mouse MOVE(header cell): ".."X: "..tostring(x).." Y: "..tostring(y))
    local startColumn, startRow = self:getRoot().scrollGrid:getMouseCursorColumnRow(x, y)
    Logging.debug("startRow: "..tostring(startRow).." startColumn: "..tostring(startColumn) )
    if self.isDragged then
      self:getRoot().scrollGrid.isDragged = false
      self:getRoot().scrollGrid.dragStartX = -1
      self:getRoot().scrollGrid.dragStartY = -1
      self:getRoot():popMouseCursor()
    end
    self:getRoot():popMouseCursor()
  end

  o.scrollGrid.gridHeaderCellNo:addMouseMoveCallback(headerCellCallback)
  o.scrollGrid.gridHeaderCellCoordinates:addMouseMoveCallback(headerCellCallback)
  o.scrollGrid.gridHeaderCellElevation:addMouseMoveCallback(headerCellCallback)
  o.scrollGrid.gridHeaderCellElevation:addMouseMoveCallback(headerCellCallback)
  o.scrollGrid.gridHeaderCellDistance:addMouseMoveCallback(headerCellCallback)
  o.scrollGrid.gridHeaderCellDelete:addMouseMoveCallback(headerCellCallback)

  o.scrollGrid:setSize(width, h + 27)
  local cellHeaderSkin = SkinHelper.loadSkin("gridHeaderSharkPlannerCellHeader")
  o.scrollGrid.gridHeaderCellNo:setSkin(cellHeaderSkin)
  o.scrollGrid.gridHeaderCellCoordinates:setSkin(cellHeaderSkin)
  o.scrollGrid.gridHeaderCellAltitude:setSkin(cellHeaderSkin)
  o.scrollGrid.gridHeaderCellElevation:setSkin(cellHeaderSkin)
  o.scrollGrid.gridHeaderCellDistance:setSkin(cellHeaderSkin)
  o.scrollGrid.gridHeaderCellDelete:setSkin(cellHeaderSkin)

  o.scrollGrid:addSelectRowCallback(o.OnPositionSelected)
  o.scrollGrid:addMouseDownCallback(
    function (cell, x, y, button)
      self:OnMouseDown(self, x, y, button)
    end
  )  
  o.entryMode = ControlWindow.EntryStates.WAYPOINTS
  o:setBounds(x + w, y - 26, width, h + 26 + 27)
  o.removeButtonSkin = SkinHelper.loadSkin("buttonSkinSharkPlannerAmber")
  local buttonAmberSkin = SkinHelper.loadSkin("buttonSkinSharkPlannerAmber")
  o.filePath = nil
  o.LoadButton:setSkin(buttonAmberSkin)
  o.LoadButton:addChangeCallback(
    function(button)
      self:loadPositions()
    end
  )
  o.LoadButton:addMouseUpCallback(
    function(button)
      button:setFocused(false)
    end
  )
  o.SaveButton:setSkin(buttonAmberSkin)
  o.SaveButton:addChangeCallback(
    function(button)
      if o.filePath == nil then
        self:savePositionsAs()
      else
        self:savePositions(o.filePath)
      end
    end
  )
  o.SaveButton:addMouseUpCallback(
    function(button)
      button:setFocused(false)
    end
  )
  o.SaveAsButton:setSkin(buttonAmberSkin)
  o.SaveAsButton:addChangeCallback(
    function(button)
      self:savePositionsAs()
    end
  )
  o.SaveAsButton:addMouseUpCallback(
    function(button)
      button:setFocused(false)
    end
  )
  o.FileNameStatic:setSkin(SkinHelper.loadSkin("staticSharkPlannerStatusRectangular"))
  return o
end

-- show window
function DeadReckoningWindow:show()
  self:setVisible(true)
  local count = self:getWidgetCount()
  for i = 1, count do
    local index 		= i - 1
    local widget 		= self:getWidget(index)
    widget:setVisible(true)
  end
end

-- hide window
function DeadReckoningWindow:hide()
  self:setVisible(false)
  local count = self:getWidgetCount()
  for i = 1, count do
    local index 		= i - 1
    local widget 		= self:getWidget(index)
    widget:setVisible(false)
  end
end

function DeadReckoningWindow:loadPositions()
  Logging.info("Loading positions")
  FileDialog.reset()
  local filePath = FileDialog.open(lfs.writedir(), {{'Flight Paths'	, '(*.json)'}}, "Load Flight Plan", "*.json", "")
  if filePath ~= nil then
    Logging.info("Selected load path: "..filePath)
    coordinateData:load(filePath)
  end
end

function DeadReckoningWindow:savePositions(filePath)
  if filePath ~= nil then
    Logging.info("Saving positions")
    Logging.info("Existing save path: "..filePath)
    coordinateData:save(filePath)
  end
end

function DeadReckoningWindow:savePositionsAs()
  Logging.info("Saving positions As")
  local filePath = self.filePath
  if filePath == nil then filePath = "" end
  --   function save(path, filters, caption, a_typeFile, a_preName)

  FileDialog.reset()
  filePath = FileDialog.save(self.filePath or lfs.writedir(), {{'Flight Paths'	, '(*.json)'}}, "Save Flight Plan As", "json")
  if filePath ~= nil then
    Logging.info("Selected save path: "..filePath)
    coordinateData:save(filePath)
  end
end

function DeadReckoningWindow:OnAddWaypoint(eventArgs)
  if self.entryMode == ControlWindow.EntryStates.WAYPOINTS then
    self:_createPositionRow(eventArgs.wayPointIndex, eventArgs.wayPoint, coordinateData.removeWaypoint)
    self:_calculateDistances(eventArgs.wayPoints)
  end
end

function DeadReckoningWindow:OnFlightPlanLoaded(eventArgs)
  self.filePath = eventArgs.filePath
  self.FileNameStatic:setText(Utils.String.basename(eventArgs.filePath))
end

function DeadReckoningWindow:OnFlightPlanSaved(eventArgs)
  self.filePath = eventArgs.filePath
  self.FileNameStatic:setText(Utils.String.basename(eventArgs.filePath))
end

function DeadReckoningWindow:OnMouseDown(self, x, y, button)
  Logging.debug("Mouse down, x: "..x.." y: "..y.." button "..tostring(button))
  if button == 1 then
    local column, row = self.scrollGrid:getMouseCursorColumnRow(x, y)
    local oldRow = self.scrollGrid:getSelectedRow()
    self.scrollGrid:selectRow(row)
    self:OnPositionSelected(row, oldRow)
  end
end

function DeadReckoningWindow:OnMouseDoubleDown(self, x, y, button)
  Logging.debug("Mouse down, x: "..x.." y: "..y.." button "..tostring(button))
end

function DeadReckoningWindow:OnPositionSelected(currSelectedRow, prevSelectedRow)
  Logging.debug("Selected row: "..tostring(currSelectedRow).." prior selection was: "..tostring(prevSelectedRow))
  local positions = nil
  if self.entryMode == ControlWindow.EntryStates.WAYPOINTS then
    positions = coordinateData.wayPoints
  elseif self.entryMode == ControlWindow.EntryStates.FIXPOINTS then
    positions = coordinateData.fixPoints
  elseif self.entryMode == ControlWindow.EntryStates.TARGET_POINTS then
    positions = coordinateData.targetPoints
  else
    return
  end
  local position = positions[currSelectedRow + 1]
  local cameraPosition = Export.LoGetCameraPosition()
  
  cameraPosition['p']['x'] = position:getX()
  cameraPosition['p']['z'] = position:getZ()

  Export.LoSetCameraPosition(cameraPosition)
end

function DeadReckoningWindow:OnRemoveWaypoint(eventArgs)
  Logging.info("Removing: "..eventArgs.wayPointIndex)
  self.scrollGrid:removeRow(eventArgs.wayPointIndex - 1)
  -- renumber later waypoints
  for i = eventArgs.wayPointIndex, #eventArgs.wayPoints  do
    Logging.info("Renumbering: "..tostring(i))
    -- renumber button row_number
    self.scrollGrid:getCell(5, i - 1):getWidget(0).row_number = i
    -- renumber visible ordinal
    self.scrollGrid:getCell(0, i - 1):setText(tostring(i))
  end
  self:_calculateDistances(eventArgs.wayPoints)
end

function DeadReckoningWindow:OnAddFixpoint(eventArgs)
  if self.entryMode == ControlWindow.EntryStates.FIXPOINTS then
    self:_createPositionRow(eventArgs.fixPointIndex, eventArgs.fixPoint, coordinateData.removeFixpoint)
    self:_calculateDistances(eventArgs.fixPoints)
  end
end

function DeadReckoningWindow:OnRemoveFixpoint(eventArgs)
  Logging.info("Removing: "..eventArgs.fixPointIndex)
  self.scrollGrid:removeRow(eventArgs.fixPointIndex - 1)
  -- renumber later fixpoints
  for i = eventArgs.fixPointIndex, #eventArgs.fixPoints  do
    Logging.info("Renumbering: "..tostring(i))
    -- renumber button row_number
    self.scrollGrid:getCell(5, i - 1):getWidget(0).row_number = i
    -- renumber visible ordinal
    self.scrollGrid:getCell(0, i - 1):setText(tostring(i))
  end
  self:_calculateDistances(eventArgs.fixPoints)
end

function DeadReckoningWindow:OnAddTargetpoint(eventArgs)
  if self.entryMode == ControlWindow.EntryStates.TARGET_POINTS then
    self:_createPositionRow(eventArgs.targetPointIndex, eventArgs.targetPoint, coordinateData.removeTargetpoint)
    self:_calculateDistances(eventArgs.targetPoints)
  end
end

function DeadReckoningWindow:OnRemoveTargetpoint(eventArgs)
  Logging.info("Removing: "..eventArgs.targetPointIndex)
  self.scrollGrid:removeRow(eventArgs.targetPointIndex - 1)
  -- renumber later targetpoints
  for i = eventArgs.targetPointIndex, #eventArgs.targetPoints  do
    Logging.info("Renumbering: "..tostring(i))
    -- renumber button row_number
    self.scrollGrid:getCell(5, i - 1):getWidget(0).row_number = i
    -- renumber visible ordinal
    self.scrollGrid:getCell(0, i - 1):setText(tostring(i))
  end
  self:_calculateDistances(eventArgs.targetPoints)
end

function DeadReckoningWindow:OnMoveWayPoint(eventArgs)
  self:fillPositions(eventArgs.wayPoints, coordinateData.removeWaypoint)
end

function DeadReckoningWindow:OnMoveFixPoint(eventArgs)
  self:fillPositions(eventArgs.fixPoints, coordinateData.removeFixpoint)
end

function DeadReckoningWindow:OnMoveTargetPoint(eventArgs)
  self:fillPositions(eventArgs.targetPoints, coordinateData.targetFixpoint)
end

function DeadReckoningWindow:OnReset(eventArgs)
  self.scrollGrid:removeAllRows()
  self.filePath = nil
  self.FileNameStatic:setText("")
end

function DeadReckoningWindow:fillPositions(positions, removalFunction)
  self.scrollGrid:removeAllRows()
  -- self.entryMode = entryMode
  for i = 1, #positions do
    Logging.debug(tostring(i))
    self:_createPositionRow(i, positions[i], removalFunction)
  end
  self:_calculateDistances(positions)
end

function DeadReckoningWindow:OnEntryModeChanged(eventArgs)
  Logging.info("Entry mode changed!")
  self.scrollGrid:removeAllRows()
  local positions = nil
  local removalFunction = nil
  self.entryMode = eventArgs.entryState
  if eventArgs.entryState == ControlWindow.EntryStates.WAYPOINTS then
    positions = coordinateData.wayPoints
    removalFunction = coordinateData.removeWaypoint
  elseif eventArgs.entryState == ControlWindow.EntryStates.FIXPOINTS then
    positions = coordinateData.fixPoints
    removalFunction = coordinateData.removeFixpoint
  elseif eventArgs.entryState == ControlWindow.EntryStates.TARGET_POINTS then
    positions = coordinateData.targetPoints
    removalFunction = coordinateData.removeTargetpoint
  else
    return
  end
  for i = 1, #positions do
    Logging.debug(tostring(i))
    self:_createPositionRow(i, positions[i], removalFunction)
  end
  self:_calculateDistances(positions)
end

function DeadReckoningWindow:_createPositionRow(row_number, position, removalFunction)
  -- add row number
  self.scrollGrid:insertRow(40)
  -- create row number
  local static = Static.new()
  static:setText(tostring(row_number))
  static:setSkin(templates.staticCellValidNotSelectedTemplate:getSkin())
  static:addMouseDownCallback(
    function (cell, x, y, button)
      self:OnMouseDown(self, x, y, button)
    end
  )
  static.parent = self.scrollGrid
  static:addMouseDoubleDownCallback(self.OnMouseDoubleDown)

  self.scrollGrid:setCell(0, row_number - 1, static)

  -- add Geographical coordindates
  static = Static.new()
  static:setText(position:getLatitudeDMSstr().."\n"..position:getLongitudeDMSstr())
  static:setSkin(templates.staticCellValidNotSelectedTemplate:getSkin())
  static:addMouseDownCallback(
    function (cell, x, y, button)
      self:OnMouseDown(self, x, y, button)
    end
  )
  self.scrollGrid:setCell(1, row_number - 1, static)

  -- add altitude
  static = Static.new()
  static:setText("")
  static:setSkin(templates.staticCellValidNotSelectedTemplate:getSkin())
  static:addMouseDownCallback(
    function (cell, x, y, button)
      self:OnMouseDown(self, x, y, button)
    end
  )
  self.scrollGrid:setCell(2, row_number - 1, static)

  local elevationPanel = Panel.new()
  local elevationPanelLayout = LayoutFactory.createLayout("vert", VertLayout.newLayout())

  elevationPanelLayout:setGap(0)
  elevationPanelLayout:setVertAlign(
    {
      ["offset"] = 0,
      ["type"] = "middle",
    }
  )
  elevationPanelLayout:setHorzAlign(
    {
      ["offset"] = 0,
      ["type"] = "middle",
    }
  )
  elevationPanel:setLayout(elevationPanelLayout)
  elevationPanel:setVisible(true)
  local deltaElevation = Static.new()
  deltaElevation:setVisible(true)
  deltaElevation:setText('0m')
  deltaElevation:setSize(80,26)
  deltaElevation:setSkin(templates.deltaElevation)

  local elevation = SpinBox.new()
  elevation:setVisible(true)
  elevation:setRange(position:getAltitude(),20000)
  elevation:setStep(1000)
  elevation:setButtonsVisible(true)
  elevation:setSize(80,26)
  elevation:setSkin(templates.spinBox)
  elevation.position = position
  elevation:addChangeCallback(
    function(elevation)
      elevation.position:setElevation(elevation:getValue())
      local deltaH = elevation.position:getElevation() - elevation.position:getAltitude()
      deltaElevation:setText(
        string.format("%s", math.floor(deltaH + 0.5)).." m"
      )
    end
  )

  elevationPanel:insertWidget(deltaElevation)
  elevationPanel:insertWidget(elevation)
  elevationPanel.deltaElevation = deltaElevation
  elevationPanel.elevation = elevation
  self.scrollGrid:setCell(3, row_number - 1, elevationPanel)

  -- add distance
  static = Static.new()
  static:setText("")
  static:setSkin(templates.staticCellValidNotSelectedTemplate:getSkin())
  static:addMouseDownCallback(
    function (cell, x, y, button)
      self:OnMouseDown(self, x, y, button)
    end
  )
  self.scrollGrid:setCell(4, row_number - 1, static)

  local panel = Panel.new()
  panel:setVisible(true)
  panel:addMouseDownCallback(
    function (cell, x, y, button)
      self:OnMouseDown(self, x, y, button)
    end
  )

  -- add delete button
  local button = Button.new()

  -- button:setSkin(Skin.getSkin("buttonSkinAwacs"))
  button:setSkin(self.removeButtonSkin)
  button:setText("X")
  button:setBounds(2, 7, 26, 26)
  button:setVisible(true)
  -- record the row_number for later use
  button.row_number = row_number
  -- record the position for later use
  button.position = position
  -- record point function
  button.removalFunction = removalFunction
  button:addChangeCallback(
    function(self)
      button.removalFunction(coordinateData, button.row_number)
    end
  )
  panel:insertWidget(button, 1)
  self.scrollGrid:setCell(5, row_number - 1, panel)
end

function DeadReckoningWindow:_calculateDistances(positions)
  local totalDistance = 0
  local priorPosition = coordinateData.planningPosition
  if priorPosition == nil and #positions > 0 then
    priorPosition = positions[1]
  end
  for i, position in ipairs(positions) do
    local distance = 0
    local deltaX = math.abs(position:getX() - priorPosition:getX())
    local deltaY = math.abs(position:getZ() - priorPosition:getZ())
    local deltaH = position:getAltitude() - priorPosition:getAltitude()
    distance = math.sqrt(math.pow(deltaX, 2) + math.pow(deltaY, 2))
    totalDistance = totalDistance + distance
    self.scrollGrid:getCell(4, i - 1):setText(
      string.format("%.2f", distance / 1000) .." km".."\n"..
      string.format("%.2f", totalDistance / 1000) .." km"
    )
    self.scrollGrid:getCell(2, i - 1):setText(
      string.format("%s", math.floor(deltaH + 0.5)).." m".."\n"..
      string.format("%s", math.floor(position:getAltitude() + 0.5)) .." m"
    )
    local elevationCell = self.scrollGrid:getCell(3, i - 1)
    elevationCell.elevation:setValue(math.floor(position:getElevation() + 0.5))
    priorPosition = position
  end
end

return  DeadReckoningWindow
