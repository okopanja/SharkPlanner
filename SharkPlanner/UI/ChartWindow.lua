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
local Static = require("Static")

local ChartWindow = DialogLoader.spawnDialogFromFile(
    lfs.writedir() .. "Scripts\\SharkPlanner\\UI\\ChartWindow.dlg"
)


local AggregationModes = {
  MAX = 1,
  MIN = 2,
  AVG = 3,
  SUM = 4
}

ChartWindow.AggregationModes = AggregationModes

-- Constructor
function ChartWindow:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    local x, y, w, h = o.crosshairWindow:getBounds()
    Logging.info("Creating chart window")
    -- o:setBounds(x - ownWidth, y, ownWidth, ownHeight)
    local width = 805
    local height = 200
    o.negativeAsymptote = 20

    Logging.info("Width: "..width)
    Logging.info("Height: ".. height)
    o:setBounds(x, y + h + 26, width,height)
    o:setVisible(true)
    local lineSkin = SkinHelper.loadSkin("graphLine")
    local axisLineSkin = SkinHelper.loadSkin("graphAxisLine")
    local horizontalAxisLineSkin = SkinHelper.loadSkin("graphHorizontalAxisLine")
    local asymptoteLineSkin = SkinHelper.loadSkin("graphAsymptoteLine")
    local thousandLineSkin = SkinHelper.loadSkin("graphThousandLine")
    local thousandLabelSkin = SkinHelper.loadSkin("graphThousandLabel")
    o.waypointLineSkin = SkinHelper.loadSkin("graphWaypointLine")
    o.waypointVerticalLabelSkin = SkinHelper.loadSkin("graphWaypointVerticalLabel")
    o.waypointHorizontalLabelSkin = SkinHelper.loadSkin("graphWaypointHorizontalLabel")
    local seaSkin = SkinHelper.loadSkin("graphSea")
    o.axisLineSkin = axisLineSkin
    -- create maximum asymptote
    local sea = Static.new()
    sea:setSkin(seaSkin)
    sea:setBounds(0, height - o.negativeAsymptote, width, 20)
    sea:setAngle(0)
    sea:setVisible(true)
    o:insertWidget(sea, o:getWidgetCount() + 1)

    o.value_histogram = {}
    for x = 0, width do
      local line = Static.new()
      line:setSkin(lineSkin)
      line:setBounds(x - 1, height - o.negativeAsymptote, 0, 1)
      line:setAngle(90)
      line:setVisible(true)
      o:insertWidget(line, 1)
      o.value_histogram[x] = line
    end
    o:setAggregationMode(AggregationModes.MAX)

    -- create horizontal Axis
    local horizontalAxis = Static.new()
    horizontalAxis:setSkin(horizontalAxisLineSkin)
    horizontalAxis:setBounds(0, height - o.negativeAsymptote, width, o.negativeAsymptote)
    horizontalAxis:setAngle(0)
    horizontalAxis:setText("0m")
    horizontalAxis:setVisible(true)
    o:insertWidget(horizontalAxis, o:getWidgetCount() + 1)
    -- create vertical Axis
    local verticalAxis = Static.new()
    verticalAxis:setSkin(axisLineSkin)
    -- verticalAxis:setBounds(1, 1, height, 1)
    verticalAxis:setBounds(0, 0, 1, height)
    -- verticalAxis:setAngle(90)
    verticalAxis:setVisible(true)
    o:insertWidget(verticalAxis, o:getWidgetCount() + 1)


    o.thousandLines = {}
    for i = 1,20 do
      local thousandLine = Static.new()
      thousandLine:setSkin(thousandLineSkin)
      thousandLine:setBounds(0, height - 10, width, 1)
      thousandLine:setAngle(0)
      thousandLine:setVisible(false)
      o:insertWidget(thousandLine, o:getWidgetCount() + 1)
      o.thousandLines[#o.thousandLines + 1] = thousandLine
    end
    -- create minimum asymptote
    o.minimumAsymptote = Static.new()
    o.minimumAsymptote:setSkin(asymptoteLineSkin)
    o.minimumAsymptote:setBounds(0, height - 10, width, 1)
    o.minimumAsymptote:setAngle(0)
    o.minimumAsymptote:setVisible(false)
    o:insertWidget(o.minimumAsymptote, o:getWidgetCount() + 1)

    -- create maximum asymptote
    o.maximumAsymptote = Static.new()
    o.maximumAsymptote:setSkin(asymptoteLineSkin)
    o.maximumAsymptote:setBounds(0, height - 10, width, 1)
    o.maximumAsymptote:setAngle(0)
    o.maximumAsymptote:setVisible(false)
    o:insertWidget(o.maximumAsymptote, o:getWidgetCount() + 1)

    o.thousandLabels = {}
    for i = 1,20 do
      local thousandLabel = Static.new()
      thousandLabel:setSkin(thousandLabelSkin)
      thousandLabel:setBounds(0, height, width, 1)
      thousandLabel:setAngle(0)
      thousandLabel:setVisible(false)
      thousandLabel:setText(tostring(i * 1000).."m")
      o:insertWidget(thousandLabel, o:getWidgetCount() + 1)
      o.thousandLabels[#o.thousandLabels + 1] = thousandLabel
    end

    o.labelWidth = 70
    o.labelHeight = 20
    o.minimalDistanceX = 33
    o.minimalElevationX = 20
    o.defaultElevationY = 100
    o.populated = false
    o.thousandCount = 9
    return o
end

function ChartWindow:show()
    self:setVisible(true)
    -- show all widgets on status window
    local count = self:getWidgetCount()
  	for i = 1, count do
      local index 		= i - 1
  	  local widget 		= self:getWidget(index)
      widget:setVisible(true)
      widget:setFocused(false)
    end
    local width, height = self:getSize()
    height = height - self.negativeAsymptote
    if self.populated == false then
      self.verticalScalingFactor = height / 9000
    end
    self:showThousandLines( width, height)
  end

function ChartWindow:hide()
    -- hide all widgets on status window
    local count = self:getWidgetCount()
    for i = 1, count do
        local index 		= i - 1
        local widget 		= self:getWidget(index)
    widget:setVisible(false)
    widget:setFocused(false)
  end
  self:setHasCursor(false)
  self:setVisible(false)
end

function ChartWindow:setAggregationMode(mode)
  self.aggregationMode = mode
end

function ChartWindow:determineMinMax(values)
  local minimum = nil
  local maximum = nil
  for pos, value in pairs(values) do
    if minimum == nil then
      minimum = value
    elseif value < minimum then
      minimum = value
    end
    if maximum == nil then
      maximum = value
    elseif value > maximum then
      maximum = value
    end
  end
  return minimum, maximum
end

function ChartWindow:determineSampleValues(values)
  local sampledValues = {}
  -- determine number of valuesPerInterval
  local valuesPerInterval = #values / #self.value_histogram
  local globalMax = values[1]
  local globalMin = values[1]
  -- local localSum = 0
  -- local localCount = 0
  for x = 1, #self.value_histogram + 1 do
    local startIndex = math.min(math.floor ( (x - 1) * valuesPerInterval + 1 + 0.5), #values)
    -- local endIndex = math.min(math.floor ( (x - 1) * valuesPerInterval + 1 + valuesPerInterval + 0.5), #values)
    local endIndex = math.min(math.floor(startIndex + valuesPerInterval - 1 + 0.5), #values)
    if endIndex < startIndex then endIndex = startIndex end
    -- Logging.info("valuesPerInterval: "..valuesPerInterval)
    -- Logging.info("Start index: "..startIndex)
    -- Logging.info("End index: "..endIndex)
    assert(startIndex <= endIndex, "Start index: "..startIndex.." End index: ".. endIndex)
    assert(startIndex <= #values, "Start index: "..startIndex.." #values: ".. #values)
    assert(endIndex <= #values, "End index: "..endIndex.." #values: ".. #values)
    local sum = 0
    local count = endIndex - startIndex + 1
    local min = values[startIndex]
    local max = values[startIndex]
    for vx = startIndex, endIndex do
      sum = sum + values[vx]
      if min > values[vx] then min = values[vx] end
      if max < values[vx] then max = values[vx] end
    end
    local avg = sum / count
    if self.aggregationMode == AggregationModes.MAX then
      sampledValues[#sampledValues + 1] = max
    elseif self.aggregationMode == AggregationModes.MIN then
      sampledValues[#sampledValues + 1] = min
    elseif self.aggregationMode == AggregationModes.AVG then
      sampledValues[#sampledValues + 1] = avg
    elseif self.aggregationMode == AggregationModes.SUM then
      sampledValues[#sampledValues + 1] = sum
    end
    if globalMax < max then
      globalMax = max
    end
    if globalMin > min then
      globalMin = min
    end
  end
  return sampledValues, globalMin, globalMax
end

function ChartWindow:setValues(elevationProfile)
  local values = elevationProfile.elevations
  if values == nil then return end
  -- determine number of horizontal Intervals
  local width, height = self:getSize()
  Logging.info("Width: "..#self.value_histogram)
  Logging.info("Initial values count: "..#values)
  local minimum, maximum = self:determineMinMax(values)
  local trim = self.negativeAsymptote
  height = height - trim
  self:setAggregationMode(AggregationModes.MAX)
  local sampledValues = self:determineSampleValues(values)
  Logging.info("Sampled values count: "..#sampledValues)
  self.thousandCount = math.ceil(maximum / 1000)
  local nextThousand = self.thousandCount * 1000
  self.verticalScalingFactor = (height - trim) / nextThousand
  Logging.info("Next thousaned is: "..nextThousand)
  -- plot graph
  for i, line in ipairs(self.value_histogram) do
    local value = math.floor(sampledValues[i + 1] * self.verticalScalingFactor)
    line:setSize(value, 1)
  end
  -- set asymptotes
  self.maximumAsymptote:setBounds(0, height - math.floor(maximum * self.verticalScalingFactor + 0.5), width, self.negativeAsymptote)
  self.maximumAsymptote:setVisible(true)
  self.maximumAsymptote:setText(string.format("%.0f", maximum).."m")
  self.minimumAsymptote:setBounds(0, height - math.floor(minimum * self.verticalScalingFactor + 0.5), width, self.negativeAsymptote)
  self.minimumAsymptote:setText(string.format("%.0f", minimum).."m")
  if minimum ~= 0 then
    self.minimumAsymptote:setVisible(true)
  else
    self.minimumAsymptote:setVisible(false)
  end
  -- show thousand lines
  self:showThousandLines(width, height)
  self:resetWaypoints()
  self:createWaypoints(width, height, elevationProfile)
end

function ChartWindow:showThousandLines(width, height)
  -- height = height - self.negativeAsymptote
  for i = 1, #self.thousandLines do
    if i > self.thousandCount then
      self.thousandLines[i]:setVisible(false)
      self.thousandLabels[i]:setVisible(false)
    else
      self.thousandLines[i]:setBounds(0, height - math.floor(i * 1000 * self.verticalScalingFactor), width, self.negativeAsymptote)
      self.thousandLines[i]:setVisible(true)
      self.thousandLabels[i]:setBounds(0, height - math.floor(i * 1000 * self.verticalScalingFactor), width, self.negativeAsymptote)
      self.thousandLabels[i]:setVisible(true)
    end
  end
end

function ChartWindow:resetWaypoints()
  if self.waypointLines then
    for k, v in pairs(self.waypointLines) do
      self:removeWidget(v)
      v:destroy()
    end
  end
  if self.waypointDistanceLabels then
    for k, v in pairs(self.waypointDistanceLabels) do
      self:removeWidget(v)
      v:destroy()
    end
  end
  if self.waypointElevationLabels then
    for k, v in pairs(self.waypointElevationLabels) do
      self:removeWidget(v)
      v:destroy()
    end
  end
  self.waypointLines = {}
  self.waypointDistanceLabels = {}
  self.waypointElevationLabels = {}
end

function ChartWindow:createWaypoints(width, height, elevationProfile)
  -- set waypoints
  local horizontalScale = width / elevationProfile.totalDistance
  Logging.info("Width: "..width)
  Logging.info("Total distance: "..elevationProfile.totalDistance)
  Logging.info("Scale: "..horizontalScale)
  local cumulativeDistance = 0
  local lastDistanceX = 0
  local lastElevationX = 0
  local elevationY = self.defaultElevationY
  for i = 1, #elevationProfile.waypointDistances do
    cumulativeDistance = cumulativeDistance + elevationProfile.waypointDistances[i]
    self:createWaypointLine(i, cumulativeDistance, horizontalScale, height)
    lastDistanceX = self:createWaypointDistanceLabel(cumulativeDistance, horizontalScale, height, lastDistanceX)
    lastElevationX = self:createWaypointElevationLabel(i, elevationProfile, elevationY, cumulativeDistance, horizontalScale, lastElevationX)
  end
end

function ChartWindow:createWaypointLine(i, cumulativeDistance, horizontalScale, height)
  local waypoint = Static.new()
  waypoint:setSkin(self.waypointLineSkin)
  waypoint:setBounds(cumulativeDistance * horizontalScale - self.labelWidth, 0, self.labelWidth, height + self.labelHeight)
  waypoint:setText(tostring(i))
  waypoint:setVisible(true)
  self:insertWidget(waypoint, self:getWidgetCount() + 1)
  self.waypointLines[#self.waypointLines + 1] = waypoint
end

function ChartWindow:createWaypointDistanceLabel(cumulativeDistance, horizontalScale, height, lastDistanceX)
  local waypointDistance = Static.new()
  waypointDistance:setSkin(self.waypointHorizontalLabelSkin)
  local distanceX = cumulativeDistance * horizontalScale - self.labelWidth
  waypointDistance:setBounds(distanceX, height - 2, self.labelWidth, self.labelHeight)
  local distanceText = string.format("%.0fkm", cumulativeDistance / 1000)
  -- if i == #elevationProfile.waypointDistances then
  --   distanceText = distanceText.."km"
  -- end
  waypointDistance:setText(distanceText)
  waypointDistance:setAngle(0)
  if distanceX - lastDistanceX >= self.minimalDistanceX then
    waypointDistance:setVisible(true)
  else
    waypointDistance:setVisible(false)
  end
  self:insertWidget(waypointDistance, self:getWidgetCount() + 1)
  self.waypointDistanceLabels[#self.waypointDistanceLabels + 1] = waypointDistance
  return distanceX
end

function ChartWindow:createWaypointElevationLabel(i, elevationProfile, elevationY, cumulativeDistance, horizontalScale, lastElevationX)
  local waypointHeight = Static.new()
  waypointHeight:setSkin(self.waypointVerticalLabelSkin)
  local elevationX = cumulativeDistance * horizontalScale - self.labelHeight
  if (elevationX - lastElevationX >= self.minimalElevationX) or (elevationX < self.minimalElevationX) then
    -- set normal elevation height
    elevationY = self.defaultElevationY
  else
    -- if not enough space, alternate between high and low
    if elevationY == self.defaultElevationY then
      -- increase Y
      elevationY = elevationY + self.labelWidth / 1.2
    else
      -- decrease Y
      elevationY = self.defaultElevationY
    end
  end
  lastElevationX = elevationX
  waypointHeight:setBounds(
    elevationX,
    elevationY,
    self.labelWidth,
    self.labelHeight
  )
  waypointHeight:setText(string.format("%.0fm", elevationProfile.allPoints[i + 1]:getY()))
  waypointHeight:setAngle(90)
  waypointHeight:setVisible(true)
  self:insertWidget(waypointHeight, self:getWidgetCount() + 1)
  self.waypointElevationLabels[#self.waypointElevationLabels + 1] = waypointHeight

  return elevationX
end

function ChartWindow:reset()
  self.populated = false
  local width, height = self:getSize()
  self.verticalScalingFactor = (height - self.negativeAsymptote) / 9000
  height = height - self.negativeAsymptote
  self.thousandCount = 9
  self:showThousandLines(width, height)
  self:resetWaypoints()
  -- set values to zero
  for x, v in pairs(self.value_histogram) do
    v:setBounds(x - 1, height, 0, 1)
  end
  -- hide minimum and maximum asymptote
  self.minimumAsymptote:setVisible(false)
  self.maximumAsymptote:setVisible(false)
end

function ChartWindow:OnAddWaypoint(eventArgs)
  self.populated = true
  self:setValues(eventArgs.elevationProfile)
end

function ChartWindow:OnRemoveWaypoint(eventArgs)
  if eventArgs.elevationProfile then
    self:setValues(eventArgs.elevationProfile)
  else
    self:reset()
  end
end

function ChartWindow:OnReset(eventArgs)
  self:reset()
end

function ChartWindow:OnFlightPlanLoaded(eventArgs)
end

function ChartWindow:OnFlightPlanSaved(eventArgs)
end

return ChartWindow