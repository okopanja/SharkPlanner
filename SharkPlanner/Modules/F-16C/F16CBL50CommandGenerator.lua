local Logging = require("SharkPlanner.Utils.Logging")
local BaseCommandGenerator = require("SharkPlanner.Base.BaseCommandGenerator")
local Command = require("SharkPlanner.Base.Command")
local Position = require("SharkPlanner.Base.Position")
local Hemispheres = require("SharkPlanner.Base.Hemispheres")
local Configuration = require("SharkPlanner.Base.Configuration")

local F16CBL50CommandGenerator = BaseCommandGenerator:new{}
local UFC = 17

function F16CBL50CommandGenerator:new(o)
    --o = BaseCommandGenerator:new()
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function F16CBL50CommandGenerator:getAircraftName()
    return "F-16C_50"
end

function F16CBL50CommandGenerator:getMaximalWaypointCount()
    return 20
end

function F16CBL50CommandGenerator:getMaximalFixPointCount()
    return 0
end

function F16CBL50CommandGenerator:getMaximalTargetPointCount()
    return 4
end

-- main function for generating commands
function F16CBL50CommandGenerator:generateCommands(waypoints, fixpoints, targets)
    self.ufcDelay = Configuration:getOption("F-16.UFC.CommandDelay")
    local commands = {}
    -- Enter DEST subpage
    self:ufcEnterDEST(commands)
    -- Enter waypoints
    for i, waypoint in ipairs(waypoints) do
        self:ufcEnterWaypoint(commands, i, waypoint)
    end
    -- Enter target points
    for i, target in ipairs(targets) do
        self:ufcEnterWaypoint(commands, i + 26 - 1, target)
    end    
    -- Return to main menu
    self:ufcDcsRtn(commands, "Exit current DED mode")
    self:ufcDcsRtn(commands, "Exit current DED mode")
    return commands
end

-- Sequences of commands
function F16CBL50CommandGenerator:ufcEnterDEST(commands)
    -- LIST -> DEST enables more consistant entry than STRP
    self:ufcDcsRtn(commands, "Exit current DED mode")
    self:ufcList(commands, "Enter LIST page")
    self:ufcPressDigitButton(commands, 1, "Enter LIST -> DEST subpage")
    self:ufcDcsSeq(commands, "Switch to long/lat coordinates")
end

function F16CBL50CommandGenerator:ufcEnterWaypoint(commands, pos, waypoint)
    -- first we select the waypoint
    local latitude_digits = self:_getWaypointDigits(pos)
    for pos, digit in pairs(latitude_digits) do
        Logging.debug("Waypoint digit: "..digit)
        self:ufcPressDigitButton(commands, digit, "Latitude digit: "..digit)
    end
    self:ufcDcsEntr(commands, "Select steerpoint 1")

    -- enter latitude
    self:ufcDcsDown(commands, "Select latitude")
    -- enter hepisphere
    if waypoint:getLatitudeHemisphere() == Hemispheres.LatHemispheres.NORTH then
        self:ufcPressDigitButton(commands, 2, "Hemisphere: NORTH")
    else
        self:ufcPressDigitButton(commands, 8, "Hemisphere: SOUTH")
    end
    -- enter numeric part

    local latitude_digits = waypoint:getLatitudeAsDMBuffer{precision = 3, minutes_format = "%06.3f"}
    for pos, digit in pairs(latitude_digits) do
        Logging.debug("Latitude digit: "..digit)
        self:ufcPressDigitButton(commands, digit, "Latitude digit: "..digit)
    end
    self:ufcDcsEntr(commands, "Complete latitude entry")

    -- enter longitude
    self:ufcDcsDown(commands, "Select longitude")
    -- enter hepisphere
    if waypoint:getLongitudeHemisphere() == Hemispheres.LongHemispheres.EAST then
        self:ufcPressDigitButton(commands, 6, "Hemisphere: EAST")
    else
        self:ufcPressDigitButton(commands, 4, "Hemisphere: WEST")
    end
    -- enter numeric part
    local longitude_digits = waypoint:getLongitudeAsDMBuffer{precision = 3, minutes_format = "%06.3f"}
    for pos, digit in pairs(longitude_digits) do
        Logging.debug("Longitude digit: "..digit)
        self:ufcPressDigitButton(commands, digit, "Longitude digit: "..digit)
    end
    self:ufcDcsEntr(commands, "Complete longitude entry")
    
    -- enter altitude
    self:ufcDcsDown(commands, "Select altitude")
    local altitude_feet_digits = self:_getAltitudeDigits(waypoint:getAltitudeFeet())

    for pos, digit in pairs(altitude_feet_digits) do
        Logging.debug("Altitude digit: "..digit)
        self:ufcPressDigitButton(commands, digit, "Longitude digit: "..digit)
    end
    self:ufcDcsEntr(commands, "Complete altitude entry")

    -- position cursor on top
    self:ufcDcsUp(commands, "Select waypoint")
    self:ufcDcsUp(commands, "Select latitude")
    self:ufcDcsUp(commands, "Select longitude")
end

-- Base commands: all commands tha result in single action
-- DED commands
function F16CBL50CommandGenerator:ufcDcsDedInc(commands, comment, delay)
    commands[#commands + 1] = Command:new():setName("UFC: DED -> INC"):setComment(comment):setDevice(UFC):setCode(3030):setDelay(delay or self.ufcDelay):setIntensity(1):setDepress(true)
end

function F16CBL50CommandGenerator:ufcDcsDedDec(commands, comment, delay)
    commands[#commands + 1] = Command:new():setName("UFC: DED -> DEC"):setComment(comment):setDevice(UFC):setCode(3031):setDelay(delay or self.ufcDelay):setIntensity(1):setDepress(true)
end

-- keyboard commands
function F16CBL50CommandGenerator:ufcPressDigitButton(commands, digit, comment, delay)
    commands[#commands + 1] = Command:new():setName("UFC: press numeric"):setComment(comment):setDevice(UFC):setCode(3002 + digit):setDelay(delay or self.ufcDelay):setIntensity(1):setDepress(true)
    -- commands[#commands + 1] = Command:new():setName("UFC: NOP"):setComment(comment):setDevice(nil):setCode(nil):setDelay(delay):setIntensity(nil):setDepress(true)
end

function F16CBL50CommandGenerator:ufcDcsEntr(commands, comment, delay)
    commands[#commands + 1] = Command:new():setName("UFC: DCS -> ENTR"):setComment(comment):setDevice(UFC):setCode(3016):setDelay(delay or self.ufcDelay):setIntensity(1):setDepress(true)
end

function F16CBL50CommandGenerator:ufcDcsRcl(commands, comment, delay)
    commands[#commands + 1] = Command:new():setName("UFC: DCS -> RCL"):setComment(comment):setDevice(UFC):setCode(3017):setDelay(delay or self.ufcDelay):setIntensity(1):setDepress(true)
end

-- rocker commands
function F16CBL50CommandGenerator:ufcDcsRtn(commands, comment, delay)
    commands[#commands + 1] = Command:new():setName("UFC: DCS -> RTN"):setComment(comment):setDevice(UFC):setCode(3032):setDelay(delay or self.ufcDelay):setIntensity(-1):setDepress(true)
    commands[#commands + 1] = Command:new():setName("UFC: NOP"):setComment(comment):setDevice(nil):setCode(nil):setDelay((delay or self.ufcDelay) / 4):setIntensity(nil):setDepress(false)
end

function F16CBL50CommandGenerator:ufcDcsUp(commands, comment, delay)
    commands[#commands + 1] = Command:new():setName("UFC: DCS -> UP"):setComment(comment):setDevice(UFC):setCode(3034):setDelay(delay or self.ufcDelay):setIntensity(1):setDepress(true)
    commands[#commands + 1] = Command:new():setName("UFC: NOP"):setComment(comment):setDevice(nil):setCode(nil):setDelay((delay or self.ufcDelay) / 1):setIntensity(nil):setDepress(false)
end

function F16CBL50CommandGenerator:ufcDcsDown(commands, comment, delay)
    commands[#commands + 1] = Command:new():setName("UFC: DCS -> DOWN"):setComment(comment):setDevice(UFC):setCode(3035):setDelay(delay or self.ufcDelay):setIntensity(-1):setDepress(true)
    commands[#commands + 1] = Command:new():setName("UFC: NOP"):setComment(comment):setDevice(nil):setCode(nil):setDelay((delay or self.ufcDelay) / 4):setIntensity(nil):setDepress(false)
end

function F16CBL50CommandGenerator:ufcDcsSeq(commands, comment, delay)
    commands[#commands + 1] = Command:new():setName("UFC: DCS -> SEQ"):setComment(comment):setDevice(UFC):setCode(3033):setDelay(delay or self.ufcDelay):setIntensity(1):setDepress(true)
    commands[#commands + 1] = Command:new():setName("UFC: NOP"):setComment(comment):setDevice(nil):setCode(nil):setDelay((delay or self.ufcDelay) / 4):setIntensity(nil):setDepress(false)
end

-- override commands

function F16CBL50CommandGenerator:ufcCom1(commands, comment, delay)
    commands[#commands + 1] = Command:new():setName("UFC: COM1"):setComment(comment):setDevice(UFC):setCode(3012):setDelay(delay or self.ufcDelay):setIntensity(1):setDepress(true)
end

function F16CBL50CommandGenerator:ufcCom2(commands, comment, delay)
    commands[#commands + 1] = Command:new():setName("UFC: COM2"):setComment(comment):setDevice(UFC):setCode(3013):setDelay(delay or self.ufcDelay):setIntensity(1):setDepress(true)
end

function F16CBL50CommandGenerator:ufcIff(commands, comment, delay)
    commands[#commands + 1] = Command:new():setName("UFC: IFF"):setComment(comment):setDevice(UFC):setCode(3014):setDelay(delay or self.ufcDelay):setIntensity(1):setDepress(true)
end

function F16CBL50CommandGenerator:ufcList(commands, comment, delay)
    commands[#commands + 1] = Command:new():setName("UFC: LIST"):setComment(comment):setDevice(UFC):setCode(3015):setDelay(delay or self.ufcDelay):setIntensity(1):setDepress(true)
end

function F16CBL50CommandGenerator:ufcAA(commands, comment, delay)
    commands[#commands + 1] = Command:new():setName("UFC: A-A"):setComment(comment):setDevice(UFC):setCode(3018):setDelay(delay or self.ufcDelay):setIntensity(1):setDepress(true)
end

function F16CBL50CommandGenerator:ufcAG(commands, comment, delay)
    commands[#commands + 1] = Command:new():setName("UFC: A-G"):setComment(comment):setDevice(UFC):setCode(3019):setDelay(delay or self.ufcDelay):setIntensity(1):setDepress(true)
end

function F16CBL50CommandGenerator:_getWaypointDigits(waypoint)
    local buffer = string.format("%0.0f", waypoint)
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

function F16CBL50CommandGenerator:_getAltitudeDigits(altitude)
    local buffer = string.format("%5.0f", altitude)
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

return F16CBL50CommandGenerator