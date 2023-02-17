require("FlightPlanner.BaseCommandGenerator")
require("FlightPlanner.Command")
require("math")

-- require("net")


local default_delay = 100 -- default delay in ms

-- classes to be used to handle rotations in different ABRIS ranges
ABRISZoomRange = {}

KA50IIICommandGenerator = {}
KA50IIICommandGenerator._ranges = {}
KA50IIICommandGenerator._zoomLevel = 10

function KA50IIICommandGenerator:new()
  o = BaseCommandGenerator:new()
  setmetatable(o, self)
  self.__index = self
  self._ranges[#self._ranges + 1] = ABRISZoomRange.new{level = #self._ranges + 1, range =    150}
  self._ranges[#self._ranges + 1] = ABRISZoomRange.new{level = #self._ranges + 1, range =    200}
  self._ranges[#self._ranges + 1] = ABRISZoomRange.new{level = #self._ranges + 1, range =    250}
  self._ranges[#self._ranges + 1] = ABRISZoomRange.new{level = #self._ranges + 1, range =    300}
  self._ranges[#self._ranges + 1] = ABRISZoomRange.new{level = #self._ranges + 1, range =    500}
  self._ranges[#self._ranges + 1] = ABRISZoomRange.new{level = #self._ranges + 1, range =    600}
  self._ranges[#self._ranges + 1] = ABRISZoomRange.new{level = #self._ranges + 1, range =    750}
  self._ranges[#self._ranges + 1] = ABRISZoomRange.new{level = #self._ranges + 1, range =   1000}
  self._ranges[#self._ranges + 1] = ABRISZoomRange.new{level = #self._ranges + 1, range =   1250}
  self._ranges[#self._ranges + 1] = ABRISZoomRange.new{level = #self._ranges + 1, range =   1500}
  self._ranges[#self._ranges + 1] = ABRISZoomRange.new{level = #self._ranges + 1, range =   2000}
  self._ranges[#self._ranges + 1] = ABRISZoomRange.new{level = #self._ranges + 1, range =   2500}
  self._ranges[#self._ranges + 1] = ABRISZoomRange.new{level = #self._ranges + 1, range =   3000}
  self._ranges[#self._ranges + 1] = ABRISZoomRange.new{level = #self._ranges + 1, range =   4000}
  self._ranges[#self._ranges + 1] = ABRISZoomRange.new{level = #self._ranges + 1, range =   5000}
  self._ranges[#self._ranges + 1] = ABRISZoomRange.new{level = #self._ranges + 1, range =   6000}
  self._ranges[#self._ranges + 1] = ABRISZoomRange.new{level = #self._ranges + 1, range =   7500}
  self._ranges[#self._ranges + 1] = ABRISZoomRange.new{level = #self._ranges + 1, range =  10000}
  self._ranges[#self._ranges + 1] = ABRISZoomRange.new{level = #self._ranges + 1, range =  12500}
  self._ranges[#self._ranges + 1] = ABRISZoomRange.new{level = #self._ranges + 1, range =  15000}
  self._ranges[#self._ranges + 1] = ABRISZoomRange.new{level = #self._ranges + 1, range =  20000}
  self._ranges[#self._ranges + 1] = ABRISZoomRange.new{level = #self._ranges + 1, range =  25000}
  self._ranges[#self._ranges + 1] = ABRISZoomRange.new{level = #self._ranges + 1, range =  30000}
  self._ranges[#self._ranges + 1] = ABRISZoomRange.new{level = #self._ranges + 1, range =  40000}
  self._ranges[#self._ranges + 1] = ABRISZoomRange.new{level = #self._ranges + 1, range =  50000}
  self._ranges[#self._ranges + 1] = ABRISZoomRange.new{level = #self._ranges + 1, range = 100000}
  return o
end

function KA50IIICommandGenerator:getMaximalWaypointCount()
  return 6
end

function KA50IIICommandGenerator:getMaximalTargetPointsCount()
  return 10
end

function KA50IIICommandGenerator:generateCommands(waypoints, selfX, selfZ)
  commands = {}
  self:preparePVI800Commands(commands, waypoints)
  self:prepareABRISCommands(commands, waypoints, selfX, selfZ)
  return commands
end

-- main function for PVI commands
function KA50IIICommandGenerator:preparePVI800Commands(commands, waypoints)
  -- entry of waypoints positions
  self:pvi800SwitchToEntryMode(commands)
  self:pvi800PressWaypointBtn(commands)
  for digit, waypoint in pairs(waypoints) do
    -- select waypoint number
    self:pvi800PressDigitBtn(commands, digit, "Waypoint: "..digit)
    -- enter lat hemisphere
    self:pvi800PressDigitBtn(commands, waypoint:getLatitudeHemisphere(), "Latitude Hemisphere")
    -- enter latitude
    local latitude_digits = self:_getLatitudeDigits(waypoint:getLatitudeDMDec())
    for pos, digit in pairs(latitude_digits) do
      self:pvi800PressDigitBtn(commands, digit, "Latitude digit: "..digit)
    end
    -- enter long hemisphere
    self:pvi800PressDigitBtn(commands, waypoint:getLongitudeHemisphere(), "Longitude Hemisphere")
    -- enter longitude
    local longitude_digits = self:_getLongitudeDigits(waypoint:getLongitudeDMDec())
    for pos, digit in pairs(longitude_digits) do
      self:pvi800PressDigitBtn(commands, digit, "Latitude digit: "..digit)
    end
    -- complete navpoint entry
    self:pvi800PressEnterBtn(commands)
  end
  self:pvi800SwitchToOperMode(commands)
  -- enter route consisting of previosly entered waypoints
  for digit, waypoint in pairs(waypoints) do
    self:pvi800PressDigitBtn(commands, digit, "Waypoint: "..digit)
    self:pvi800PressEnterBtn(commands)
  end
  -- self:pvi800PressDigitBtn(commands, 1, "Activate waypoint 1")
  self:pvi800PressDigitBtn(commands, 1, "Activate waypoint 1")
  self:pvi800PressWaypointBtn(commands)
  if #waypoints < 6 then
    self:pvi800PressWaypointBtn(commands)
  end
  self:pvi800PressDigitBtn(commands, 1, "Activate waypoint 1")
end

-- utility functions for PVI-800
function KA50IIICommandGenerator:pvi800SwitchToEntryMode(commands)
  commands[#commands + 1] = Command:new():setName("PVI-800: switch to Entry mode"):setDevice(20):setCode(3026):setDelay(default_delay):setIntensity(0.2):setDepress(false)
end

function KA50IIICommandGenerator:pvi800SwitchToOperMode(commands)
  commands[#commands + 1] = Command:new():setName("PVI-800: switch to Oper mode"):setDevice(20):setCode(3026):setDelay(default_delay):setIntensity(0.3):setDepress(false)
end

function KA50IIICommandGenerator:pvi800PressWaypointBtn(commands)
  commands[#commands + 1] = Command:new():setName("PVI-800: press Waypoint button"):setDevice(20):setCode(3011):setDelay(default_delay):setIntensity(1):setDepress(true)
end

function KA50IIICommandGenerator:pvi800PressEnterBtn(commands)
  commands[#commands + 1] = Command:new():setName("PVI-800: press Enter button"):setDevice(20):setCode(3018):setDelay(default_delay):setIntensity(1):setDepress(true)
end

function KA50IIICommandGenerator:pvi800PressDigitBtn(commands, digit, comment)
  -- ignore out of [0-9] bounds
  if digit < 0 or digit > 9 then
    return
  end
  -- ignore non integer numbers
  if digit ~= math.floor(digit) then
    return
  end
  commands[#commands + 1] = Command:new():setName("PVI-800: press digit "..digit):setComment(comment):setDevice(20):setCode(3001 + digit):setDelay(default_delay):setIntensity(1):setDepress(true)
end

-- Main function for ABRIS
function KA50IIICommandGenerator:prepareABRISCommands(commands, waypoints, selfX, selfZ)
  -- Place ABRIS into MENU mode, no matter in which mode it is currently in
  self:abrisCycleToMenuMode(commands)
  -- Workaround ABRIS/SNS drift (this occurs only on the first usage, but for simplicity we will repeat it every time)
  self:abrisWorkaroundInitialSNSDrift(commands, selfX, selfZ)
  -- Make sure there is no route loaded
  self:abrisUnloadRoute(commands)
  -- Start entering
  self:abrisStartRouteEntry(commands)
  -- Enter waypoints
  self:abrisEnterRouteWaypoints(commands, selfX, selfZ, coords)
  -- Complete and store route
  self:abrisCompleteRouteEntry(commands)
end

function KA50IIICommandGenerator:abrisCycleToMenuMode(commands)
  local cycleNumber = self:_determineNumberOfModePresses()
  for i = 1,cycleNumber do
    self:abrisPressButton5(commands, "Cycle mode")
  end
end

function KA50IIICommandGenerator:abrisWorkaroundInitialSNSDrift(commands, selfX, selfZ)
end

function KA50IIICommandGenerator:abrisUnloadRoute(commands)
  -- ABRIS: plan mode
  self:abrisPressButton3(commands, "Plan mode")
  -- ABRIS: activate select menu
  self:abrisPressButton1(commands, "Activate select menu")
  -- ABRIS: select menu move down 2 entries (this will be split into 4 increments of 0.4)
  for i = 1,4 do
    self:abrisRotate(commands, 0.4, "Rotate menu: "..i.."/4")
  end
  -- ABRIS: activate unload option
  self:abrisPressButton1(commands, "Activate unload option")
  -- ABRIS: activate select menu again
  self:abrisPressButton1(commands, "Activate select menu again")
  -- ABRIS: move menu back 2 entries
  for i = 1,4 do
    self:abrisRotate(commands, -0.4, "Rotate menu: "..i.."/4")
  end
  -- ABRIS: now switch to menu mode again
  self:abrisPressButton5(commands, "Switch to main menu")
end

function KA50IIICommandGenerator:abrisStartRouteEntry(commands)
  -- ABRIS: plan mode
  self:abrisPressButton3(commands, "Plan mode")
  -- ABRIS: activate EDIT menu
  self:abrisPressButton2(commands, "activate EDIT menu")
  -- ABRIS: zoom in to maximum to make sure we start with known zoom level 0
  self:abrisFullZoom(commands)
end

function KA50IIICommandGenerator:abrisEnterRouteWaypoints(commands, selfX, selfZ, positions)
end

function KA50IIICommandGenerator:abrisCompleteRouteEntry(commands)
end
-- Utility functions for ABRIS
function KA50IIICommandGenerator:abrisPressButton1(commands, comment)
  commands[#commands + 1] = Command:new():setName("ABRIS: press button 1"):setComment(comment):setDevice(9):setCode(3001):setDelay(default_delay):setIntensity(1):setDepress(true)
end

function KA50IIICommandGenerator:abrisPressButton2(commands, comment)
  commands[#commands + 1] = Command:new():setName("ABRIS: press button 2"):setComment(comment):setDevice(9):setCode(3002):setDelay(default_delay):setIntensity(1):setDepress(true)
end

function KA50IIICommandGenerator:abrisPressButton3(commands, comment)
  commands[#commands + 1] = Command:new():setName("ABRIS: press button 3"):setComment(comment):setDevice(9):setCode(3003):setDelay(default_delay):setIntensity(1):setDepress(true)
end

function KA50IIICommandGenerator:abrisPressButton4(commands, comment)
  commands[#commands + 1] = Command:new():setName("ABRIS: press button 4"):setComment(comment):setDevice(9):setCode(3004):setDelay(default_delay):setIntensity(1):setDepress(true)
end

function KA50IIICommandGenerator:abrisPressButton5(commands, comment)
  commands[#commands + 1] = Command:new():setName("ABRIS: press button 5"):setComment(comment):setDevice(9):setCode(3005):setDelay(default_delay):setIntensity(1):setDepress(true)
end

function KA50IIICommandGenerator:abrisRotate(commands, intensity, comment)
  commands[#commands + 1] = Command:new():setName("ABRIS: rotate"):setComment(comment):setDevice(9):setCode(3006):setDelay(0):setIntensity(intensity):setDepress(false)
end

function KA50IIICommandGenerator:abrisFullZoom(commands)
  self:abrisZoomIn(commands, #self._ranges)
end

function KA50IIICommandGenerator:abrisZoomIn(commands, relativeZoomLevel)
  if relativeZoomLevel < 0 then
    return
  end
  for i = 1, relativeZoomLevel do
    self:abrisPressButton3(commands, 1, "ZoomIn")
  end
  self._zoomLevel = self._zoomLevel - relativeZoomLevel
end

function KA50IIICommandGenerator:abrisZoomOut(commands, relativeZoomLevel)
end

function KA50IIICommandGenerator:_determineNumberOfModePresses()
  local mode = Export.GetDevice(9):get_mode()
  mode = tostring(mode.master)..tostring(mode.level_2)..tostring(mode.level_3)..tostring(mode.level_4)
  if mode == "0000" then
    return 0
  elseif mode == "9000" then
    return 1
  elseif self:starts_with(mode,"5") then
    return 4
  elseif mode == "5000" then
    return 4
  elseif mode == "5500" then
    return 3
  elseif mode == "5100" then
    return 2
  elseif mode == "5400" then
    return 5
  elseif mode == "5310" then
    return 5
  elseif mode == "5200" then
    return 5
  elseif mode == "5430" then
    return 5
  elseif mode == "5240" then
    return 5
  end
  -- net.log("ABRIS Mode: "..mode)
  return 5
end

-- Coordinates utility functions
function KA50IIICommandGenerator:_getLatitudeDigits(latitude)
  local buffer = string.format("%02.0f", latitude.degrees)..string.format("%04.1f", latitude.minutes)
  -- net.log("Latitude buffer: "..buffer)
  local result = {}
  for i = 1, #buffer do
    local temp = string.sub(buffer, i, i)
    if temp ~= '.' and temp then
      result[#result + 1] = tonumber(temp)
    end
  end
  return result
end

function KA50IIICommandGenerator:_getLongitudeDigits(longitude)
  local buffer = string.format("%03.0f", longitude.degrees)..string.format("%04.1f", longitude.minutes)
  -- net.log("Longitude buffer: "..buffer)
  local result = {}
  for i = 1, #buffer do
    local temp = string.sub(buffer, i, i)
    if temp ~= '.' then
      result[#result + 1] = tonumber(temp)
    end
  end
  return result
end

function KA50IIICommandGenerator:starts_with(str, start)
   return str:sub(1, #start) == start
end


function ABRISZoomRange:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self

  self.ROTATION_TO_SCREEN_FACTOR = 1.23456
  self.HORIZONTAL_ROTATIONS = 10
  self.VERTICAL_ROTATIONS = 8
  self.vertical = self.range * self.VERTICAL_ROTATIONS / self.ROTATION_TO_SCREEN_FACTOR
  self.horizontal = self.range * self.HORIZONTAL_ROTATIONS / self.ROTATION_TO_SCREEN_FACTOR

  return o
end

function ABRISZoomRange:getLevel()
  return self.level
end

function ABRISZoomRange:toRotationsX(deltaX)
  return self.VERTICAL_ROTATIONS * deltaX / self.vertical
end

function ABRISZoomRange:toRotationsZ(deltaZ)
  return self.HORIZONTAL_ROTATIONS * deltaZ / self.horizontal
end
