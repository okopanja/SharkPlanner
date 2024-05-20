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
-- Table is needed for quick checks
local Table = require("SharkPlanner.Utils.Table")
local TerrainHelper = require("SharkPlanner.Modules.UH-60L.TerrainHelper")
-- for coordinate conversion you might need math module
require("math")

-- constuct the new class (derive from BaseCommandGenerator)
UH60LCommandGenerator = BaseCommandGenerator:new()

UH60LCommandGenerator.ENTRY_DEVICE_ASN128B = 23

-- Define button IDs for ASN-128B
UH60LCommandGenerator.ASN128B_BUTTONS = {
  SelectMode = 3235,
  SelectDisplay = 3236,
  SelectBtnKybd = 3237,
  SelectBtnLtrLeft = 3238,
  SelectBtnLtrMid = 3239,
  SelectBtnLtrRight = 3240,
  SelectBtnF1 = 3241,
  SelectBtn1 = 3242,
  SelectBtn2 = 3243,
  SelectBtn3 = 3244,
  SelectBtnTgtStr = 3245,
  SelectBtn4 = 3246,
  SelectBtn5 = 3247,
  SelectBtn6 = 3248,
  SelectBtnInc = 3249,
  SelectBtn7 = 3250,
  SelectBtn8 = 3251,
  SelectBtn9 = 3252,
  SelectBtnDec = 3253,
  SelectBtnClr = 3254,
  SelectBtn0 = 3255,
  SelectBtnEnt = 3256,
}

-- since the digits are not in the same order as the button IDs, we need to map them
UH60LCommandGenerator.ASN128B_digits = {
  [0] = UH60LCommandGenerator.ASN128B_BUTTONS.SelectBtn0,
  [1] = UH60LCommandGenerator.ASN128B_BUTTONS.SelectBtn1,
  [2] = UH60LCommandGenerator.ASN128B_BUTTONS.SelectBtn2,
  [3] = UH60LCommandGenerator.ASN128B_BUTTONS.SelectBtn3,
  [4] = UH60LCommandGenerator.ASN128B_BUTTONS.SelectBtn4,
  [5] = UH60LCommandGenerator.ASN128B_BUTTONS.SelectBtn5,
  [6] = UH60LCommandGenerator.ASN128B_BUTTONS.SelectBtn6,
  [7] = UH60LCommandGenerator.ASN128B_BUTTONS.SelectBtn7,
  [8] = UH60LCommandGenerator.ASN128B_BUTTONS.SelectBtn8,
  [9] = UH60LCommandGenerator.ASN128B_BUTTONS.SelectBtn9,
}

UH60LCommandGenerator.ASN128B_letters = {
  ['A'] = { shift = UH60LCommandGenerator.ASN128B_BUTTONS.SelectBtnLtrLeft,  digit = UH60LCommandGenerator.ASN128B_BUTTONS.SelectBtn1 },
  ['B'] = { shift = UH60LCommandGenerator.ASN128B_BUTTONS.SelectBtnLtrMid,   digit = UH60LCommandGenerator.ASN128B_BUTTONS.SelectBtn1 },
  ['C'] = { shift = UH60LCommandGenerator.ASN128B_BUTTONS.SelectBtnLtrRight, digit = UH60LCommandGenerator.ASN128B_BUTTONS.SelectBtn1 },
  ['D'] = { shift = UH60LCommandGenerator.ASN128B_BUTTONS.SelectBtnLtrLeft,  digit = UH60LCommandGenerator.ASN128B_BUTTONS.SelectBtn2 },
  ['E'] = { shift = UH60LCommandGenerator.ASN128B_BUTTONS.SelectBtnLtrMid,   digit = UH60LCommandGenerator.ASN128B_BUTTONS.SelectBtn2 },
  ['F'] = { shift = UH60LCommandGenerator.ASN128B_BUTTONS.SelectBtnLtrRight, digit = UH60LCommandGenerator.ASN128B_BUTTONS.SelectBtn2 },
  ['G'] = { shift = UH60LCommandGenerator.ASN128B_BUTTONS.SelectBtnLtrLeft,  digit = UH60LCommandGenerator.ASN128B_BUTTONS.SelectBtn3 },
  ['H'] = { shift = UH60LCommandGenerator.ASN128B_BUTTONS.SelectBtnLtrMid,   digit = UH60LCommandGenerator.ASN128B_BUTTONS.SelectBtn3 },
  ['I'] = { shift = UH60LCommandGenerator.ASN128B_BUTTONS.SelectBtnLtrRight, digit = UH60LCommandGenerator.ASN128B_BUTTONS.SelectBtn3 },
  ['J'] = { shift = UH60LCommandGenerator.ASN128B_BUTTONS.SelectBtnLtrLeft,  digit = UH60LCommandGenerator.ASN128B_BUTTONS.SelectBtn4 },
  ['K'] = { shift = UH60LCommandGenerator.ASN128B_BUTTONS.SelectBtnLtrMid,   digit = UH60LCommandGenerator.ASN128B_BUTTONS.SelectBtn4 },
  ['L'] = { shift = UH60LCommandGenerator.ASN128B_BUTTONS.SelectBtnLtrRight, digit = UH60LCommandGenerator.ASN128B_BUTTONS.SelectBtn4 },
  ['M'] = { shift = UH60LCommandGenerator.ASN128B_BUTTONS.SelectBtnLtrLeft,  digit = UH60LCommandGenerator.ASN128B_BUTTONS.SelectBtn5 },
  ['N'] = { shift = UH60LCommandGenerator.ASN128B_BUTTONS.SelectBtnLtrMid,   digit = UH60LCommandGenerator.ASN128B_BUTTONS.SelectBtn5 },
  ['O'] = { shift = UH60LCommandGenerator.ASN128B_BUTTONS.SelectBtnLtrRight, digit = UH60LCommandGenerator.ASN128B_BUTTONS.SelectBtn5 },
  ['P'] = { shift = UH60LCommandGenerator.ASN128B_BUTTONS.SelectBtnLtrLeft,  digit = UH60LCommandGenerator.ASN128B_BUTTONS.SelectBtn6 },
  ['Q'] = { shift = UH60LCommandGenerator.ASN128B_BUTTONS.SelectBtnLtrMid,   digit = UH60LCommandGenerator.ASN128B_BUTTONS.SelectBtn6 },
  ['R'] = { shift = UH60LCommandGenerator.ASN128B_BUTTONS.SelectBtnLtrRight, digit = UH60LCommandGenerator.ASN128B_BUTTONS.SelectBtn6 },
  ['S'] = { shift = UH60LCommandGenerator.ASN128B_BUTTONS.SelectBtnLtrLeft,  digit = UH60LCommandGenerator.ASN128B_BUTTONS.SelectBtn7 },
  ['T'] = { shift = UH60LCommandGenerator.ASN128B_BUTTONS.SelectBtnLtrMid,   digit = UH60LCommandGenerator.ASN128B_BUTTONS.SelectBtn7 },
  ['U'] = { shift = UH60LCommandGenerator.ASN128B_BUTTONS.SelectBtnLtrRight, digit = UH60LCommandGenerator.ASN128B_BUTTONS.SelectBtn7 },
  ['V'] = { shift = UH60LCommandGenerator.ASN128B_BUTTONS.SelectBtnLtrLeft,  digit = UH60LCommandGenerator.ASN128B_BUTTONS.SelectBtn8 },
  ['W'] = { shift = UH60LCommandGenerator.ASN128B_BUTTONS.SelectBtnLtrMid,   digit = UH60LCommandGenerator.ASN128B_BUTTONS.SelectBtn8 },
  ['X'] = { shift = UH60LCommandGenerator.ASN128B_BUTTONS.SelectBtnLtrRight, digit = UH60LCommandGenerator.ASN128B_BUTTONS.SelectBtn8 },
  ['Y'] = { shift = UH60LCommandGenerator.ASN128B_BUTTONS.SelectBtnLtrLeft,  digit = UH60LCommandGenerator.ASN128B_BUTTONS.SelectBtn9 },
  ['Z'] = { shift = UH60LCommandGenerator.ASN128B_BUTTONS.SelectBtnLtrMid,   digit = UH60LCommandGenerator.ASN128B_BUTTONS.SelectBtn9 },
  ['*'] = { shift = UH60LCommandGenerator.ASN128B_BUTTONS.SelectBtnLtrRight, digit = UH60LCommandGenerator.ASN128B_BUTTONS.SelectBtn9 },
  [' '] = { shift = UH60LCommandGenerator.ASN128B_BUTTONS.SelectBtnLtrMid,   digit = UH60LCommandGenerator.ASN128B_BUTTONS.SelectBtn0 }, -- unclear if left, mid or right shift
}

UH60LCommandGenerator.SelectDisplayPositions = {
  WIND_UTC_DATA = { name = 'WING-UTC DATA', value =  0.0 },
  XTX_TKC_KEY =   { name = 'XTX/TKC KEY',   value = 0.01 },
  GS_TK_NAV_M =   { name = 'GS/TK NAV M',   value = 0.02 },
  PP =            { name = 'PP',            value = 0.03 },
  DEST_BRG_TIME = { name = 'DEST/BRG TIME', value = 0.04 },
  WP_TGT =        { name = 'WP TGT',        value = 0.05 },
  DATUM_ROUTE =   { name = 'DATUM ROUTE',   value = 0.06 },
}

UH60LCommandGenerator.SelectModePositions = {  
  -- OFF =           { name = 'OFF',       value =  0.0 }, -- disabled to prevent confusing users
  LAMP_TEST =     { name = 'LAMP TEST', value = 0.01 },
  TEST =          { name = 'TEST',      value = 0.02 },
  MGRS =          { name = 'MGRS',      value = 0.03 },
  LAT_LONG =      { name = 'LAT/LONG',  value = 0.04 },
  GPS_LDG =       { name = 'GPS LDG',   value = 0.05 },
}


-- Object constructor
function UH60LCommandGenerator:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

-- This function will return the name of the aircraft module during runtime
function UH60LCommandGenerator:getAircraftName()
  return "UH-60L"
end

-- Function returns maximal numnber of waypoints available for entry. This is typically static value. Study the documentation of module. 
function UH60LCommandGenerator:getMaximalWaypointCount()
  return 69
end

-- Function returns maximal numnber of fix points available for entry. This is typically static value. Study the documentation of module. 
function UH60LCommandGenerator:getMaximalFixPointCount()
  return 0
end

-- Function returns maximal numnber of target points available for entry. This is typically static value. Study the documentation of module. 
function UH60LCommandGenerator:getMaximalTargetPointCount()
  return 0
end

-- Function generates sequence of commands, which are used by SharkPlanner to perform entry. 
-- Consider this to be the "main" of your module. It will be called each time you click on Transfer button in UI.
-- - waypoints, list of Position objects designated as waypoints
-- - fixpoints, list of Position objects designated as fix points (fix points are normally used for )
-- - targetpoints, list of Position objects designated as target points
function UH60LCommandGenerator:generateCommands(waypoints, fixpoints, targets)
  -- define device delay that will be passed later, derived from default_delay
  -- it is recommended to have default delay between 2 commands, e.g. 100ms. 
  -- The delay value depends on the module implementation, and it may even vary from command to command. 
  -- Safe value should be 100ms, but sometimes lower values are used, even 0. 
  -- Many buttons will not reacto properly if this value is lower than 70-75ms

  self.asn128B_default_delay = Configuration:getOption("UH-60L.ASN-128B.CommandDelay")
  -- declare empty list of commands
  local commands = {}
  -- following are high level sequences of commands, each takes commands list and adds additional command to it
  -- normally you need to enter the entry mode, since this may require pushing multiple buttons or dialing dials, it is best to have that in function rather than implement it in this function
  

  self:asn128BSelectDisplay(commands, "Enter WP/TGT display", self.SelectDisplayPositions.WP_TGT.value)
  self:asn128BSelectMode(commands, "Enter LAT/LONG mode", self.SelectModePositions.LAT_LONG.value)
  -- once you are in the correct mode it's time to enter the waypoints.
  self:asn128BEnterWaypoints(commands, waypoints)
  -- if you enter other types of positions, use another function/function call ;)
  -- once the entry is completed you will want to return to the main mode of the device
  self:asn128BSelectDisplay(commands, "Return to desired display", self:_lookupValue(self.SelectDisplayPositions, Configuration:getOption("UH-60L.ASN-128B.SelectDisplay")))
  self:asn128BSelectMode(commands, "Enter desired mode", self:_lookupValue(self.SelectModePositions, Configuration:getOption("UH-60L.ASN-128B.SelectMode")))
  -- -- If you ever wish to have optional commands, you can use the Configuration object to lookup for the option
  -- if Configuration:getOption("UH-60L.ASN-128B.SelectWaypoint1") then
  --   -- in this case we specified non a specific delay for this particular command
  --   local delay = 200
  --   self:asn128BPressDigitButton(commands, 1, "Selected waypoint: 1", delay)
  -- end

  return commands
end

-- Select Display
function UH60LCommandGenerator:asn128BSelectDisplay(commands, comment, intensity, delay)
  -- in this case we call just a single command

  -- in this long line the following is done:
  -- - Command object is created with new()
  -- - Name of command is set, along with comment useful to figure out what is going on in log file
  -- - Device - id of device
  -- - Code - code of the command, e.g. each buttton/rocker/dial/trigger has unique ID within the device
  -- - Delay - declares delay, in this case if delay is nil, it will use default_delay value, but you need to decide on delay.  Typically dials require delay of 0, for buttons use default_delay (or simply ommit declaration), if you wish to use default_delay, just leave this out. Other command will not be pressed until delay expires
  -- - Intensity, for buttons use 1, for dials intensity depends on device. Simply put: trial and error. Good values to consider for dials is 0.2, 0.4, but it can also be 5
  -- - Depress, if this is true, the button will be pressed and remain pressed until delay expires. At that point SharkPlanner will issue explicit depress command. 
  commands[#commands + 1] = Command:new():setName("ASN-128B: rotate to entry mode"):setComment(comment):setDevice(self.ENTRY_DEVICE_ASN128B):setCode(self.ASN128B_BUTTONS.SelectDisplay):setDelay(delay or self.asn128B_default_delay):setIntensity(intensity):setDepress(false)
end

-- Select Mode
function UH60LCommandGenerator:asn128BSelectMode(commands, comment, intensity, delay)
  -- in this case we call just a single command

  -- in this long line the following is done:
  -- - Command object is created with new()
  -- - Name of command is set, along with comment useful to figure out what is going on in log file
  -- - Device - id of device
  -- - Code - code of the command, e.g. each buttton/rocker/dial/trigger has unique ID within the device
  -- - Delay - declares delay, in this case if delay is nil, it will use default_delay value, but you need to decide on delay.  Typically dials require delay of 0, for buttons use default_delay (or simply ommit declaration), if you wish to use default_delay, just leave this out. Other command will not be pressed until delay expires
  -- - Intensity, for buttons use 1, for dials intensity depends on device. Simply put: trial and error. Good values to consider for dials is 0.2, 0.4, but it can also be 5
  -- - Depress, if this is true, the button will be pressed and remain pressed until delay expires. At that point SharkPlanner will issue explicit depress command. 
  commands[#commands + 1] = Command:new():setName("ASN-128B: rotate to entry mode"):setComment(comment):setDevice(self.ENTRY_DEVICE_ASN128B):setCode(self.ASN128B_BUTTONS.SelectMode):setDelay(delay or self.asn128B_default_delay):setIntensity(intensity):setDepress(false)
end


-- Example sequence which enters waypoints
function UH60LCommandGenerator:asn128BEnterWaypoints(commands, waypoints)
  -- in most cases this simply iterates through all waypoints 
  for position, waypoint in ipairs(waypoints) do
    -- typically you need to pass existing commands, position (e.g. 1, 2, 3, 4, 5...), waypoint (as Position object you got from UI)
    self:asn128BEnterWaypoint(commands, position, waypoint)    
  end
  -- cycle back the waypoints
  for position = 1, #waypoints do
    self:asn128BPressButton(commands, self.ASN128B_BUTTONS.SelectBtnDec, "Cycle waypoint to: "..position)
  end
end

-- Example sequence for entering single waypoint, this is typically the most complex function.
function UH60LCommandGenerator:asn128BEnterWaypoint(commands, position, waypoint)
  -- the actual sequence depends from device to device, so use this as a general rule of thumb
  -- first step: select the waypoint
  -- local waypointDigits = self:_getWaypointDigits(position)
  -- for _, digit in ipairs(waypointDigits) do
  --   self:asn128BPressDigitButton(commands, digit, "Select waypoint: "..position)
  -- end
  self:asn128BPressButton(commands, self.ASN128B_BUTTONS.SelectBtnInc, "Cycle waypoint to: "..position)
  self:asn128BPressButton(commands, self.ASN128B_BUTTONS.SelectBtnKybd, "keyboard entry mode: waypoint name")
  -- TODO: not implemented, SharkPlanner does not support named coordinates yet
  local theatreID = DCS.getTheatreID()
  local nearestTown, distance = TerrainHelper:lookupNearestTown(theatreID, waypoint)
  if nearestTown ~= nil then
    Logging.info("Found: "..nearestTown.display_name.." at distance: "..distance)
    self:asn128BEnterText(commands, nearestTown.display_name, "Enter waypoint name: "..nearestTown.display_name)
  else
    Logging.info("No town found near waypoint")
  end
  -- switch to latitude
  self:asn128BPressButton(commands, self.ASN128B_BUTTONS.SelectBtnKybd, "keyboard entry mode: latitude")
  -- enter hemisphere. Normally keyboard entry assumes that 2 is NORTH, 8 is SOUTH, 4 is WEST, and 6 is EAST. 
  if waypoint:getLatitudeHemisphere() == Hemispheres.LatHemispheres.NORTH then
    self:asn128BEnterText(commands, "N", "Hemisphere: NORTH")
  else
    self:asn128BEnterText(commands, "S", "Hemisphere: SOUTH")
  end
  -- Enter numeric part of latitude. 
  local latitude_digits = waypoint:getLatitudeAsDMBuffer{precision = 2, minutes_format = "%05.2f"}
  for pos, digit in pairs(latitude_digits) do
    self:asn128BPressDigitButton(commands, digit, "Latitude digit: "..digit)
  end

  -- switch to longitude entry
  self:asn128BPressButton(commands, self.ASN128B_BUTTONS.SelectBtnKybd, "keyboard entry mode: longitude")
  if waypoint:getLongitudeHemisphere() == Hemispheres.LongHemispheres.EAST then
    self:asn128BEnterText(commands, "E", "Hemisphere: EAST")
  else
    self:asn128BEnterText(commands, "W", "Hemisphere: WEST")
  end

  -- Enter numeric part of longitude
  local longitude_digits = waypoint:getLongitudeAsDMBuffer{precision = 1, minutes_format = "%04.1f"}
  -- now that we have actual digits we enter it one my one
  for pos, digit in pairs(longitude_digits) do
    self:asn128BPressDigitButton(commands, digit, "Latitude digit: "..digit)
  end

  self:asn128BPressButton(commands, self.ASN128B_BUTTONS.SelectBtnEnt, "keyboard entry mode: enter")
end

function UH60LCommandGenerator:asn128BPressButton(commands, key, comment, delay)
  commands[#commands + 1] = Command:new():setName("ASN-128B: press button"):setComment(comment):setDevice(self.ENTRY_DEVICE_ASN128B):setCode(key):setDelay(delay or self.asn128B_default_delay):setIntensity(1):setDepress(true)
end

-- an example of digit entry sequence where device id is MY_ENTRY_DEVICE_ID and starting digit 0 is 3009 followed by 3010, 3011, 3012...
function UH60LCommandGenerator:asn128BPressDigitButton(commands, digit, comment, delay)
  commands[#commands + 1] = Command:new():setName("ASN-128B: press numeric"):setComment(comment):setDevice(self.ENTRY_DEVICE_ASN128B):setCode(self.ASN128B_digits[digit]):setDelay(delay or self.asn128B_default_delay):setIntensity(1):setDepress(true)
end

function UH60LCommandGenerator:asn128BEnterText(commands, text, comment, delay)
  local letters = self:_encodeText(text)
  for _, letter in ipairs(letters) do
    self:asn128BPressLetterButton(commands, letter, comment, delay)
  end
end

function UH60LCommandGenerator:asn128BPressLetterButton(commands, letter, comment, delay)
  commands[#commands + 1] = Command:new():setName("ASN-128B: press shift"):setComment(comment):setDevice(self.ENTRY_DEVICE_ASN128B):setCode(letter.shift):setDelay(delay or self.asn128B_default_delay):setIntensity(1):setDepress(true)
  commands[#commands + 1] = Command:new():setName("ASN-128B: press numeric"):setComment(comment):setDevice(self.ENTRY_DEVICE_ASN128B):setCode(letter.digit):setDelay(delay or self.asn128B_default_delay):setIntensity(1):setDepress(true)
end

-- Coordinates utility functions
function UH60LCommandGenerator:_getLatitudeDigits(latitude)
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

function UH60LCommandGenerator:_getLongitudeDigits(longitude)
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

function UH60LCommandGenerator:_getWaypointDigits(position)
  local buffer = string.format("%02d", position)
  local result = {}
  for i = 1, #buffer do
    local temp = string.sub(buffer, i, i)
    result[#result + 1] = tonumber(temp)
  end
  return result
end

function UH60LCommandGenerator:_encodeText(text)
  local result = {}
  for i = 1, #text do
    local temp = string.sub(text:upper(), i, i)
    if Table.is_in_keys(self.ASN128B_letters, temp) then
      local letter = self.ASN128B_letters[temp]
      result[#result + 1] = letter
    elseif Table.is_in_values({"0", "1", "2", "3", "4", "5", "6", "7", "8", "9"}, temp) then
      result[#result + 1] = self.ASN128B_digits[tonumber(temp)]
    end
  end
  return result
end

function UH60LCommandGenerator:_lookupValue(table, required_name)
  for name, info in pairs(table) do
    if info.name == required_name then  
      return info.value
    end
  end
  return nil
end

-- generator class must always returned!
return UH60LCommandGenerator
