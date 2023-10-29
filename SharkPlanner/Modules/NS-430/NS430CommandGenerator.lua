-- Logging package is extremely important in order to debug issues
local Logging = require("SharkPlanner.Utils.Logging")
-- Your command generators must be derived from class BaseCommandGenerator
local BaseCommandGenerator = require("SharkPlanner.Base.BaseCommandGenerator")
-- Command is a class representing single entry event into the device
local Command = require("SharkPlanner.Base.Command")
-- Position is a class, representing coordinates prepared by UI part of Black Shark. They can be used to represent waypoints, fixpoints, target points, mark points etc.
local Position = require("SharkPlanner.Base.Position")
-- Enumeration for Hemispheres
local Hemispheres = require("SharkPlanner.Base.Hemispheres")
-- Singleton class used to obtain value of configuration option
local Configuration = require("SharkPlanner.Base.Configuration")
-- for coordinate conversion you might need math module
require("math")

-- constuct the new class (derive from BaseCommandGenerator)
NS430CommandGenerator = BaseCommandGenerator:new()

-- Object constructor
function NS430CommandGenerator:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

-- This function will return the name of the aircraft module during runtime
function NS430CommandGenerator:getAircraftName()
  return "NS430"
end

-- Function returns maximal numnber of waypoints available for entry. This is typically static value. Study the documentation of module. 
function NS430CommandGenerator:getMaximalWaypointCount()
  return 0
end

-- Function returns maximal numnber of fix points available for entry. This is typically static value. Study the documentation of module. 
function NS430CommandGenerator:getMaximalFixPointCount()
  return 0
end

-- Function returns maximal numnber of target points available for entry. This is typically static value. Study the documentation of module. 
function NS430CommandGenerator:getMaximalTargetPointCount()
  return 0
end

-- Function generates sequence of commands, which are used by SharkPlanner to perform entry. 
-- Consider this to be the "main" of your module. It will be called each time you click on Transfer button in UI.
-- - waypoints, list of Position objects designated as waypoints
-- - fixpoints, list of Position objects designated as fix points (fix points are normally used for )
-- - targetpoints, list of Position objects designated as target points
function NS430CommandGenerator:generateCommands(waypoints, fixpoints, targets)
  -- define device delay that will be passed later, derived from default_delay
  -- it is recommended to have default delay between 2 commands, e.g. 100ms. 
  -- The delay value depends on the module implementation, and it may even vary from command to command. 
  -- Safe value should be 100ms, but sometimes lower values are used, even 0. 
  -- Many buttons will not reacto properly if this value is lower than 70-75ms
  self.myDevice_default_delay = Configuration.getOption("NS430.MyEntryDevice.CommandDelay")
  -- declare empty list of commands
  local commands = {}
  -- following are high level sequences of commands, each takes commands list and adds additional command to it

  -- normally you need to enter the entry mode, since this may require pushing multiple buttons or dialing dials, it is best to have that in function rather than implement it in this functiopn
  self:myEntryDeviceEnterEntryMode(commands, "Entering main mode")
  -- once you are in the correct mode it's time to enter the waypoints.
  self:myEntryDeviceEnterWapoints(commands, waypoints)
  -- if you enter other types of positions, use another function/function call ;)
  -- once the entry is completed you will want to return to the main mode of the device
  self:myEntryDeviceReturnToMainMode(commands, waypoints)
  -- If you ever wish to have optional commands, you can use the Configuration object to lookup for the option
  if Configuration:getOption("NS430.MyEntryDevice.SelectWaypoint1") then
    -- in this case we specified non a specific delay for this particular command
    local delay = 200
    self:myEntryDevicePressDigitButton(commands, 1, "Selected waypoint: 1", delay)
  end

  return commands
end

-- Example sequence for entry mode
function NS430CommandGenerator:myEntryDeviceEnterEntryMode(commands, comment, intensity)
  -- in this case we call just a single command

  -- in this long line the following is done:
  -- - Command object is created with new()
  -- - Name of command is set, along with comment useful to figure out what is going on in log file
  -- - Device - id of device
  -- - Code - code of the command, e.g. each buttton/rocker/dial/trigger has unique ID within the device
  -- - Delay - declares delay, in this case if delay is nil, it will use default_delay value, but you need to decide on delay.  Typically dials require delay of 0, for buttons use default_delay (or simply ommit declaration), if you wish to use default_delay, just leave this out. Other command will not be pressed until delay expires
  -- - Intensity, for buttons use 1, for dials intensity depends on device. Simply put: trial and error. Good values to consider for dials is 0.2, 0.4, but it can also be 5
  -- - Depress, if this is true, the button will be pressed and remain pressed until delay expires. At that point SharkPlanner will issue explicit depress command. 
  local delay = 0
  local intensity = 0.2
  commands[#commands + 1] = Command:new():setName("MyDevice: rotate to entry mode"):setComment(comment):setDevice(22):setCode(3003):setDelay(delay or self.myDevice_default_delay):setIntensity(intensity):setDepress(false)
end

function NS430CommandGenerator:myEntryDeviceReturnToMainMode(commands, comment, intensity)
  local delay = 0  
  local intensity = -0.2 -- for opposite direction clearly equal negative value if we are using dials
  commands[#commands + 1] = Command:new():setName("MyDevice: rotate to entry mode"):setComment(comment):setDevice(22):setCode(3003):setDelay(delay or self.myDevice_default_delay):setIntensity(intensity):setDepress(false)
end


-- Example sequence which enters waypoints
function NS430CommandGenerator:myEntryDeviceEnterWapoints(commands, waypoints)
  -- in most cases this simply iterates through all waypoints 
  for position, waypoint in ipairs(waypoints) do
    -- typically you need to pass existing commands, position (e.g. 1, 2, 3, 4, 5...), waypoint (as Position object you got from UI)
    self:myEntryDeviceEnterWaypoint(commands, position, waypoint)
  end
end

-- Example sequence for entering single waypoint, this is typically the most complex function.
function NS430CommandGenerator:myEntryDeviceEnterWaypoint(commands, position, waypoint)
  -- the actual sequence depends from device to device, so use this as a general rule of thumb
  -- first step: select the waypoint
  self:myEntryDevicePressDigitButton(commands, position, "Select waypoint: "..position)
  -- enter hemisphere. Normally keyboard entry assumes that 2 is NORTH, 8 is SOUTH, 4 is WEST, and 6 is EAST. 
  -- Look at your numeric keyboard if you ever need to get reminder which value is needed.
  if waypoint:getLatitudeHemisphere() == Hemispheres.LatHemispheres.NORTH then
    -- we will use command which allows us to enter specific digit in this case 2 for NORTH
    self:myEntryDevicePressDigitButton(commands, 2, "Hemisphere: NORTH")
  else
    -- we will use command which allows us to enter specific digit in this case 8 for SOUTH
    self:myEntryDevicePressDigitButton(commands, 8, "Hemisphere: SOUTH")
  end
  -- enter numeric part. In this case we have to numeric values from waypoint. Function getLatitudeDMDec, returns the Latitude in Degree and Minutes, where minutes have fractional part.
  -- Adjust this to the needed format with your own _getLatitudeDigits function (module specific - e.g. you may need minutes in specific precision).
  local latitude_digits = self:_getLatitudeDigits(waypoint:getLatitudeDMDec())
  -- now that we have actual digits we enter it one by one
  for pos, digit in pairs(latitude_digits) do
    self:myEntryDevicePressDigitButton(commands, digit, "Latitude digit: "..digit)
  end

  if waypoint:getLongitudeHemisphere() == Hemispheres.LongHemispheres.EAST then
    -- we will use command which allows us to enter specific digit in this case 6 for WEST
    self:myEntryDevicePressDigitButton(commands, 6, "Hemisphere: EAST")
  else
    -- we will use command which allows us to enter specific digit in this case 4 for EAST
    self:myEntryDevicePressDigitButton(commands, 4, "Hemisphere: WEST")
  end
  -- enter numeric part. In this case we get numeric values from waypoint (e.g. function getLatitudeDMDec, gives the Latitude in Degree and Minutes, where minutes have fractional part)  adjust this to the needed format with _getLatitudeDigits function (module specific - e.g. you may need minutes in specific precision)
  local longitude_digits = self:_getLongitudeDigits(waypoint:getLongitudeDMDec())
  -- now that we have actual digits we enter it one my one
  for pos, digit in pairs(latitude_digits) do
    self:myEntryDevicePressDigitButton(commands, digit, "Latitude digit: "..digit)
  end

  -- similar process is done for altitude if the device supports this
  -- ...
end

-- an example of digit entry sequence where device id is 22 and starting digit 0 is 3009 followed by 3010, 3011, 3012...
function NS430CommandGenerator:myEntryDevicePressDigitButton(commands, digit, comment, delay)
  commands[#commands + 1] = Command:new():setName("My Device: press numeric"):setComment(comment):setDevice(22):setCode(3009 + digit):setDelay(delay or self.myDevice_default_delay):setIntensity(1):setDepress(true)
  -- NOP stands for no operation. It's a very special command, with values set as device=nil and code = nil. 
  -- Very often the entry may require additional pause. E.g. this can happen if the module needs time for key press to register as an impulse of certain width. 
  -- Those familiar with digital electronics will relate this behavior to edge-triggered/level-triggered. 
  -- :) Trial and error if the entry behaves oddly or unrealiable, introduce the NOP command
  commands[#commands + 1] = Command:new():setName("NOP"):setComment(comment):setDevice(nil):setCode(nil):setDelay(delay or self.myDevice_default_delay):setIntensity(nil):setDepress(true)
end

-- Coordinates utility functions
function NS430CommandGenerator:_getLatitudeDigits(latitude)
  -- some clarification
  -- degree will be shown as 2 digit with 0 padded and no fractional part. E.g. 45 degrees, 02 degrees. 
  -- minutes will be shown as 2 digit zero padded + "." + single digit fractional part. E.g. 45.1, 01.1, 01.0. The format values need to be adjusted according to the format. Note in some cases even seconds are in use, so pleas modify the code
  -- important notice: this is not 100% reliable. E.g. minutes 59.7 may get rounded to 60.0, if this is the case it should be dropped to 0 and degree should be incremented by one. I am stil thinking about better solution. :(
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

function NS430CommandGenerator:_getLongitudeDigits(longitude)
  -- some clarification
  -- degree will be shown as 3 digit with 0 padded and no fractional part. E.g. 045 degrees, 002 degrees, 010 degrees
  -- minutes will be shown as 2 digit zero padded + "." + single digit fractional part. E.g. 45.1, 01.1, 01.0. The format values need to be adjusted according to the format. Note in some cases even seconds are in use, so pleas modify the code
  -- important notice: this is not 100% reliable. E.g. minutes 59.7 may get rounded to 60.0, if this is the case it should be dropped to 0 and degree should be incremented by one. I am stil thinking about better solution. :(
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

-- generator class must always returned!
return NS430CommandGenerator
