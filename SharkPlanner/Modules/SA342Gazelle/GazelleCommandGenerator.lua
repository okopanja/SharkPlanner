local Logging = require("SharkPlanner.Utils.Logging")
local BaseCommandGenerator = require("SharkPlanner.Base.BaseCommandGenerator")
local Command = require("SharkPlanner.Base.Command")
local Position = require("SharkPlanner.Base.Position")
local Hemispheres = require("SharkPlanner.Base.Hemispheres")
local Configuration = require("SharkPlanner.Base.Configuration")
require("math")

local default_delay = 75 -- default delay in ms


GazelleCommandGenerator = BaseCommandGenerator:new()

function GazelleCommandGenerator:new(o)
  --o = BaseCommandGenerator:new()
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function GazelleCommandGenerator:getAircraftName()
  return "SA-342 Gazelle"
end

function GazelleCommandGenerator:getMaximalWaypointCount()
  return 9
end

function GazelleCommandGenerator:getMaximalFixPointCount()
  return 0
end

function GazelleCommandGenerator:getMaximalTargetPointCount()
  return 0
end

function GazelleCommandGenerator:generateCommands(waypoints, fixpoints, targets)
  local delay = default_delay
  local commands = {}

  self:nadirPlaceIntoBUTmode(commands)
  self:nadirEnterWapoints(commands, waypoints)

  if Configuration:getOption("SA-342 Gazelle.NADIR.EnableSelectWaypoint1") then
    self:nadirPressDigitButton(commands, 1, "Selected waypoint: 1", delay)
  end
  return commands
end

function GazelleCommandGenerator:nadirPlaceIntoBUTmode(commands)
  self:nadirParameterRotate(commands, 5, "Rotate to BUT mode")
end

function GazelleCommandGenerator:nadirEnterWapoints(commands, waypoints)
  for position, waypoint in pairs(waypoints) do
    self:NadirEnterWaypoint(commands, position, waypoint)
  end
end

function GazelleCommandGenerator:NadirEnterWaypoint(commands, position, waypoint)
  local delay = default_delay
  -- select waypoint
  self:nadirPressDigitButton(commands, position, "Select waypoint: "..position, delay)
  -- start latitude entry
  self:nadirPressButtonENT(commands, "Enter latitude", delay)
  -- we need to clear entry first
  for i = 1, 7 do
    self:nadirPressButtonEFF(commands, "clear digit", delay)
  end
  -- enter hepisphere
  if waypoint:getLatitudeHemisphere() == Hemispheres.LatHemispheres.NORTH then
    self:nadirPressDigitButton(commands, 2, "Hemisphere: NORTH", delay)
  else
    self:nadirPressDigitButton(commands, 8, "Hemisphere: SOUTH", delay)
  end
  -- enter numeric part
  local latitude_digits = self:_getLatitudeDigits(waypoint:getLatitudeDMDec())
  for pos, digit in pairs(latitude_digits) do
    self:nadirPressDigitButton(commands, digit, "Latitude digit: "..digit, delay)
  end
  -- switch to longitude entry
  self:nadirPressButtonDOWN(commands, "Enter longitude", delay)
  -- we need to clear entry first
  for i = 1, 7 do
    self:nadirPressButtonEFF(commands, "clear digit", delay)
  end
  -- enter hepisphere
  if waypoint:getLongitudeHemisphere() == Hemispheres.LongHemispheres.EAST then
    self:nadirPressDigitButton(commands, 6, "Hemisphere: EAST", delay)
  else
    self:nadirPressDigitButton(commands, 4, "Hemisphere: WEST", delay)
  end
  -- enter numeric part
  local longitude_digits = self:_getLongitudeDigits(waypoint:getLongitudeDMDec())
  for pos, digit in pairs(longitude_digits) do
    self:nadirPressDigitButton(commands, digit, "Longitude digit: "..digit, delay)
  end
  -- Complete waypoint entryt
  self:nadirPressButtonENT(commands, "Complete entry", delay)
end

function GazelleCommandGenerator:nadirPressButtonENT(commands, comment, delay)
  commands[#commands + 1] = Command:new():setName("NADIR: press ENT"):setComment(comment):setDevice(22):setCode(3004):setDelay(delay):setIntensity(1):setDepress(true)
end

function GazelleCommandGenerator:nadirPressButtonDOWN(commands, comment, delay)
  commands[#commands + 1] = Command:new():setName("NADIR: press ENT"):setComment(comment):setDevice(22):setCode(3008):setDelay(delay):setIntensity(1):setDepress(true)
end

function GazelleCommandGenerator:nadirPressButtonEFF(commands, comment, delay)
  commands[#commands + 1] = Command:new():setName("NADIR: press EFF"):setComment(comment):setDevice(22):setCode(3023):setDelay(delay):setIntensity(1):setDepress(true)
  commands[#commands + 1] = Command:new():setName("NOP"):setComment(comment):setDevice(nil):setCode(nil):setDelay(delay):setIntensity(nil):setDepress(false)
end

function GazelleCommandGenerator:nadirPressDigitButton(commands, digit, comment, delay)
  commands[#commands + 1] = Command:new():setName("NADIR: press numeric"):setComment(comment):setDevice(22):setCode(3009 + digit):setDelay(delay):setIntensity(1):setDepress(true)
  commands[#commands + 1] = Command:new():setName("NOP"):setComment(comment):setDevice(nil):setCode(nil):setDelay(delay):setIntensity(nil):setDepress(true)
end

function GazelleCommandGenerator:nadirParameterRotate(commands, intensity, comment)
  commands[#commands + 1] = Command:new():setName("NADIR: rotate"):setComment(comment):setDevice(22):setCode(3003):setDelay(0):setIntensity(intensity):setDepress(false)
end

-- Coordinates utility functions
function GazelleCommandGenerator:_getLatitudeDigits(latitude)
  local buffer = string.format("%02.0f", latitude.degrees)..string.format("%04.1f", latitude.minutes)
  -- Logging.info("Latitude buffer: "..buffer)
  local result = {}
  for i = 1, #buffer do
    local temp = string.sub(buffer, i, i)
    if temp ~= '.' and temp then
      result[#result + 1] = tonumber(temp)
    end
  end
  return result
end

function GazelleCommandGenerator:_getLongitudeDigits(longitude)
  local buffer = string.format("%03.0f", longitude.degrees)..string.format("%04.1f", longitude.minutes)
  -- Logging.info("Longitude buffer: "..buffer)
  local result = {}
  for i = 1, #buffer do
    local temp = string.sub(buffer, i, i)
    if temp ~= '.' then
      result[#result + 1] = tonumber(temp)
    end
  end
  return result
end

return GazelleCommandGenerator
