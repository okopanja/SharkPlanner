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
local inspect = require("SharkPlanner.inspect")

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
    local width = 400
    local height = 200
    o:setBounds(0, 0, width,height)
    o:setVisible(true)
    local lineSkin = SkinHelper.loadSkin("graphSkinSharkPlannerLine")
    self.value_histogram = {}
    for x = 0, width - 1 do
      local line = Static.new()
      line:setSkin(lineSkin)
      line:setBounds(x, height - 1, 0, 1)
      line:setAngle(90)
      line:setVisible(true)
      o:insertWidget(line, 1)
      self.value_histogram[x] = line
      end
      o:setAggregationMode(AggregationModes.MAX)
    return o
end

function ChartWindow:show()
    self:setVisible(true)
    -- show all widgets on status window
    local count = self:getWidgetCount()
  	for i = 1, count do
      local index 		= i - 1
  	  local widget 		= self:getWidget(index)
    end
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
  local sample
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
  -- determine number of horizontal Intervals
  local horizontalIntervals, verticalIntervals = self:getSize()
  local sampledValues = {}
  -- determine number of valuesPerInterval
  local valuesPerInterval = #values / horizontalIntervals

  local localMax = nil
  local localMin = nil
  local localSum = 0
  local localCount = 0
  for x = 1, #values do
    -- Logging.info("X: "..x)
    -- initialize local max and minimum
    if localMax == nil then localMax = values[x] end
    if localMin == nil then localMin = values[x] end
    localCount = localCount + 1
    localSum = localSum + values[x]
    -- update minimum and maximum
    if values[x] > localMax then localMax = values[x] end
    if values[x] < localMin then localMin = values[x] end
    -- check if it is time to store values
    if localCount  > valuesPerInterval then
      local localAvg = localSum / localCount
      if self.aggregationMode == AggregationModes.MAX then
        sampledValues[#sampledValues + 1] = localMax
      elseif self.aggregationMode == AggregationModes.MIN then
        sampledValues[#sampledValues + 1] = localMin
      elseif self.aggregationMode == AggregationModes.AVG then
        sampledValues[#sampledValues + 1] = localAvg
      elseif self.aggregationMode == AggregationModes.SUM then
        sampledValues[#sampledValues + 1] = localSum
      end
      -- reset local values
      localCount = 0
      localSum = 0
      localMin = nil
      localMax = nil
    end
  end
  return sampledValues
end

function ChartWindow:determineSampleValues2(values)
  local sampledValues = {}
  -- determine number of valuesPerInterval
  local valuesPerInterval = #values / #self.value_histogram
  local localMax = nil
  local localMin = nil
  local localSum = 0
  local localCount = 0
  for x = 1, #self.value_histogram + 1 do
    local startIndex = math.min(math.floor ( (x - 1) * valuesPerInterval + 1 + 0.5), #values)
    -- local endIndex = math.min(math.floor ( (x - 1) * valuesPerInterval + 1 + valuesPerInterval + 0.5), #values)
    local endIndex = math.min(math.floor(startIndex + valuesPerInterval - 1 + 0.5), #values)
    if endIndex < startIndex then endIndex = startIndex end
    Logging.info("valuesPerInterval: "..valuesPerInterval)
    Logging.info("Start index: "..startIndex)
    Logging.info("End index: "..endIndex)
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
  end
  return sampledValues
end

function ChartWindow:setValues(values)
  -- determine number of horizontal Intervals
  local width, height = self:getSize()

  Logging.info("Initial values count: "..#values)
  Logging.info("Initial values: "..inspect(values))
  local minimum, maximum = self:determineMinMax(values)
  self:setAggregationMode(AggregationModes.AVG)
  local sampledValues = self:determineSampleValues2(values)
  Logging.info("Sampled values count: "..#sampledValues)
  Logging.info("Sampled values"..inspect(sampledValues))
  local scalingFactor = height / maximum
  for i, line in ipairs(self.value_histogram) do
    local value = math.floor(sampledValues[i + 1] * scalingFactor)
    line:setSize(value, 1)
  end
end

return ChartWindow