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

function KA50IIICommandGenerator:generateCommands(waypoints)
  commands = {}
  self:preparePVI800Commands(waypoints, commands)
  self:prepareABRISCommands(waypoints, commands)
  return commands
end

-- main function for PVI commands
function KA50IIICommandGenerator:preparePVI800Commands(waypoints, commands)
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
function KA50IIICommandGenerator:prepareABRISCommands(waypoints, commands)
end
-- Utility functions for ABRIS


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
