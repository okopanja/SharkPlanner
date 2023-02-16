require("FlightPlanner.BaseCommandGenerator")
require("FlightPlanner.Command")
require("math")

-- require("net")


local default_delay = 100 -- default delay in ms

KA50IIICommandGenerator = BaseCommandGenerator:new()

function KA50IIICommandGenerator:getMaximalWaypointCount()
  return 6
end

function BaseCommandGenerator:getMaximalTargetPointsCount()
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
  for i=1,cycleNumber do
    self:abrisPressButton5(commands)
  end
end

function KA50IIICommandGenerator:abrisWorkaroundInitialSNSDrift(commands, selfX, selfZ)
end

function KA50IIICommandGenerator:abrisUnloadRoute(commands)
end

function KA50IIICommandGenerator:abrisStartRouteEntry(commands)
end

function KA50IIICommandGenerator:abrisEnterRouteWaypoints(commands, selfX, selfZ, positions)
end

function KA50IIICommandGenerator:abrisCompleteRouteEntry(commands)
end
-- Utility functions for ABRIS

function KA50IIICommandGenerator:abrisPressButton1(commands)
  commands[#commands + 1] = Command:new():setName("ABRIS: press button 1"):setDevice(9):setCode(3001):setDelay(default_delay):setIntensity(1):setDepress(true)
end

function KA50IIICommandGenerator:abrisPressButton2(commands)
  commands[#commands + 1] = Command:new():setName("ABRIS: press button 2"):setDevice(9):setCode(3002):setDelay(default_delay):setIntensity(1):setDepress(true)
end

function KA50IIICommandGenerator:abrisPressButton3(commands)
  commands[#commands + 1] = Command:new():setName("ABRIS: press button 3"):setDevice(9):setCode(3003):setDelay(default_delay):setIntensity(1):setDepress(true)
end

function KA50IIICommandGenerator:abrisPressButton4(commands)
  commands[#commands + 1] = Command:new():setName("ABRIS: press button 4"):setDevice(9):setCode(3004):setDelay(default_delay):setIntensity(1):setDepress(true)
end

function KA50IIICommandGenerator:abrisPressButton5(commands)
  commands[#commands + 1] = Command:new():setName("ABRIS: press button 5"):setDevice(9):setCode(3005):setDelay(default_delay):setIntensity(1):setDepress(true)
end

function KA50IIICommandGenerator:_determineNumberOfModePresses()
  local mode = Export.GetDevice(9):get_mode()
  result = 0
  net.log("Mode: "..mode.master)
  return result
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
