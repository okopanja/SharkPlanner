local Logging = require("SharkPlanner.Utils.Logging")
local BaseCommandGenerator = require("SharkPlanner.Base.BaseCommandGenerator")
local Command = require("SharkPlanner.Base.Command")
local Position = require("SharkPlanner.Base.Position")
local Hemispheres = require("SharkPlanner.Base.Hemispheres")
local Configuration = require("SharkPlanner.Base.Configuration")

local JF17CommandGenerator = BaseCommandGenerator:new{}
local UFCP = 46

-- Easy to us dictionary
JF17CommandGenerator.UFCP_buttons = {
    NUM_1 = 3202,
    PFL = 3202,
    VRC = 3203,
    NUM_2 = 3203,
    NUM_3 = 3204,
    L1 = 3205,
    R1 = 3206,
    OAP = 3207,
    MRK = 3208,
    NUM_4 = 3209,
    DST = 3209,
    NUM_5 = 3210,
    TOT = 3210,
    NUM_6 = 3211,
    TOD = 3211,
    L2 = 3212,
    R2 = 3213,
    P_U = 3214,
    HNS = 3215,
    NUM_7 = 3216,
    FUL = 3216,
    NUM_8 = 3217,
    IFF = 3217,
    NUM_9 = 3218,
    L3 = 3219,
    R3 = 3220,
    A_P = 3221,
    FPM = 3222,
    RTN = 3223,
    NUM_0 = 3224,
    NA_1 =  3225, -- N/A
    L4 = 3226,
    R4 = 3227,
    NA_2 = 3228, -- N/A
    NA_3 = 3229, -- N/A
}

-- JF-17 UFCP buttons are organized into grid, so the digits codes are taken row by row, which in turn results in need to 
-- have lookup table from digit to actual digit code
JF17CommandGenerator.UFCP_digits = {
    [0] = JF17CommandGenerator.UFCP_buttons.NUM_0,
    [1] = JF17CommandGenerator.UFCP_buttons.NUM_1,
    [2] = JF17CommandGenerator.UFCP_buttons.NUM_2,
    [3] = JF17CommandGenerator.UFCP_buttons.NUM_3,
    [4] = JF17CommandGenerator.UFCP_buttons.NUM_4,
    [5] = JF17CommandGenerator.UFCP_buttons.NUM_5,
    [6] = JF17CommandGenerator.UFCP_buttons.NUM_6,
    [7] = JF17CommandGenerator.UFCP_buttons.NUM_7,
    [8] = JF17CommandGenerator.UFCP_buttons.NUM_8,
    [9] = JF17CommandGenerator.UFCP_buttons.NUM_9,
}

function JF17CommandGenerator:new(o)
    --o = BaseCommandGenerator:new()
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function JF17CommandGenerator:getAircraftName()
    return "JF-17"
end

function JF17CommandGenerator:getMaximalWaypointCount()
    return 29
end

function JF17CommandGenerator:getMaximalFixPointCount()
    return 4
end

function JF17CommandGenerator:getMaximalTargetPointCount()
    return 6
end

-- main function for generating commands
function JF17CommandGenerator:generateCommands(waypoints, fixpoints, targets)
    self.ufcpDelay = Configuration:getOption("JF-17.UFCP.CommandDelay")
    local commands = {}
    -- Enter DEST subpage
    self:ufcpEnterDST(commands)
    -- Enter waypoints
    for i, waypoint in ipairs(waypoints) do
        self:ufcpEnterWaypoint(commands, i, waypoint)
    end
    -- -- Enter target points
    -- for i, target in ipairs(targets) do
    --     self:ufcpEnterWaypoint(commands, i + 26 - 1, target)
    -- end
    -- -- exit to main screen
    -- self:ufcpRTN(commands, "Exit to main screen")
    return commands
end

-- sequence commands
function JF17CommandGenerator:ufcpEnterDST(commands)
    self:ufcpRTN(commands, "Exit to main screen")
    self:ufcpDST(commands, "Enter DST")
end

function JF17CommandGenerator:ufcpEnterWaypoint(commands, i, waypoint)
    -- first we select waypoint number
    self:ufcpR1(commands, "Enter waypoint number entry")
    local waypointDigits = self:_getWaypointDigits(i)
    for i, v in ipairs(waypointDigits) do
        Logging.debug("Waypoint digit: "..v)
        self:ufcpPressDigitButton(commands, v, "Enter digit: "..v)
    end
    self:ufcpR1(commands, "Exit waypoint number entry")
    
    -- enter latitude
    -- enter numeric part
    self:ufcpL2(commands, "Enter waypoint latitude numeric entry")
    local latitude_digits = self:_getLatitudeDigits(waypoint:getLatitudeDMSDec())
    for pos, digit in pairs(latitude_digits) do
        Logging.debug("Latitude digit: "..digit)
        self:ufcpPressDigitButton(commands, digit, "Latitude digit: "..digit)
    end
    self:ufcpL2(commands, "Exit waypoint latitude numeric entry")
    -- enter hemisphere
    if waypoint:getLatitudeHemisphere() == Hemispheres.LatHemispheres.NORTH then
        -- assumption: once for North, 2 times for south
        self:ufcpR2(commands, "North")
    else
        self:ufcpR2(commands, "North")
        self:ufcpR2(commands, "South")
    end
    -- completed latitude

    -- enter longitude
    self:ufcpL3(commands, "Enter waypoint latitude numeric entry")
    local longitude_digits = self:_getLongitudeDigits(waypoint:getLongitudeDMSDec())
    for pos, digit in pairs(longitude_digits) do
        Logging.debug("Longitude digit: "..digit)
        self:ufcpPressDigitButton(commands, digit, "Longitude digit: "..digit)
    end
    self:ufcpL3(commands, "Exit waypoint longitude numeric entry")
    -- enter hemisphere
    if waypoint:getLatitudeHemisphere() == Hemispheres.LatHemispheres.EAST then
        -- assumption: once for East, 2 times for West
        self:ufcpR3(commands, "East")
    else
        self:ufcpR3(commands, "East")
        self:ufcpR3(commands, "West")
    end

    -- enter altitude
    self:ufcpL4(commands, "Enter waypoint altitude entry")
    local altitude_digits = self:_getAltitudeDigits(waypoint:getAltitudeFeet())
    for pos, digit in pairs(altitude_digits) do
        Logging.debug("Altitude digit: "..digit)
        self:ufcpPressDigitButton(commands, digit, "Altitude digit: "..digit)
    end
    self:ufcpL4(commands, "Exit waypoint altitude entry")
end

-- keyboard commands
function JF17CommandGenerator:ufcpRTN(commands, comment, delay)
    commands[#commands + 1] = Command:new():setName("UFCP: RTN"):setComment(comment):setDevice(UFCP):setCode(JF17CommandGenerator.UFCP_buttons.RTN):setDelay(delay or self.ufcpDelay):setIntensity(1):setDepress(true)
end

function JF17CommandGenerator:ufcpDST(commands, comment, delay)
    commands[#commands + 1] = Command:new():setName("UFCP: DST"):setComment(comment):setDevice(UFCP):setCode(JF17CommandGenerator.UFCP_buttons.DST):setDelay(delay or self.ufcpDelay):setIntensity(1):setDepress(true)
end

function JF17CommandGenerator:ufcpR1(commands, comment, delay)
    commands[#commands + 1] = Command:new():setName("UFCP: R1"):setComment(comment):setDevice(UFCP):setCode(JF17CommandGenerator.UFCP_buttons.R1):setDelay(delay or self.ufcpDelay):setIntensity(1):setDepress(true)
end

function JF17CommandGenerator:ufcpR2(commands, comment, delay)
    commands[#commands + 1] = Command:new():setName("UFCP: R2"):setComment(comment):setDevice(UFCP):setCode(JF17CommandGenerator.UFCP_buttons.R2):setDelay(delay or self.ufcpDelay):setIntensity(1):setDepress(true)
end

function JF17CommandGenerator:ufcpR3(commands, comment, delay)
    commands[#commands + 1] = Command:new():setName("UFCP: R3"):setComment(comment):setDevice(UFCP):setCode(JF17CommandGenerator.UFCP_buttons.R3):setDelay(delay or self.ufcpDelay):setIntensity(1):setDepress(true)
end

function JF17CommandGenerator:ufcpR4(commands, comment, delay)
    commands[#commands + 1] = Command:new():setName("UFCP: R4"):setComment(comment):setDevice(UFCP):setCode(JF17CommandGenerator.UFCP_buttons.R4):setDelay(delay or self.ufcpDelay):setIntensity(1):setDepress(true)
end

function JF17CommandGenerator:ufcpL1(commands, comment, delay)
    commands[#commands + 1] = Command:new():setName("UFCP: L1"):setComment(comment):setDevice(UFCP):setCode(JF17CommandGenerator.UFCP_buttons.L1):setDelay(delay or self.ufcpDelay):setIntensity(1):setDepress(true)
end

function JF17CommandGenerator:ufcpL2(commands, comment, delay)
    commands[#commands + 1] = Command:new():setName("UFCP: L2"):setComment(comment):setDevice(UFCP):setCode(JF17CommandGenerator.UFCP_buttons.L2):setDelay(delay or self.ufcpDelay):setIntensity(1):setDepress(true)
end

function JF17CommandGenerator:ufcpL3(commands, comment, delay)
    commands[#commands + 1] = Command:new():setName("UFCP: L3"):setComment(comment):setDevice(UFCP):setCode(JF17CommandGenerator.UFCP_buttons.L3):setDelay(delay or self.ufcpDelay):setIntensity(1):setDepress(true)
end

function JF17CommandGenerator:ufcpL4(commands, comment, delay)
    commands[#commands + 1] = Command:new():setName("UFCP: L4"):setComment(comment):setDevice(UFCP):setCode(JF17CommandGenerator.UFCP_buttons.L4):setDelay(delay or self.ufcpDelay):setIntensity(1):setDepress(true)
end

function JF17CommandGenerator:ufcpPressDigitButton(commands, digit, comment, delay)
    commands[#commands + 1] = Command:new():setName("UFCP: press numeric "..digit):setComment(comment):setDevice(UFCP):setCode(self.UFCP_digits[digit]):setDelay(delay or self.ufcpDelay):setIntensity(1):setDepress(true)
    -- commands[#commands + 1] = Command:new():setName("UFCP: NOP"):setComment(comment):setDevice(nil):setCode(nil):setDelay(delay):setIntensity(nil):setDepress(true)
end

-- Waypoint utility functions
function JF17CommandGenerator:_getWaypointDigits(waypointNumber)
    local buffer = string.format("%02d", waypointNumber)
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

function JF17CommandGenerator:_getLatitudeDigits(latitude)
    local buffer = string.format("%02.0f", latitude.degrees)..string.format("%02.0f", latitude.minutes)..string.format("%04.1f", latitude.seconds)
    Logging.debug("Latitude buffer: "..buffer)
    local result = {}
    for i = 1, #buffer do
      local temp = string.sub(buffer, i, i)
      if temp ~= '.' and temp then
        result[#result + 1] = tonumber(temp)
      end
    end
    for i = 0, 7 - #buffer do
        result[#result + 1] = 0
    end
    return result
end

function JF17CommandGenerator:_getLongitudeDigits(longitude)
    local buffer = string.format("%03.0f", longitude.degrees)..string.format("%02.0f", longitude.minutes)..string.format("%04.1f", longitude.minutes)

    Logging.debug("Longitude buffer: "..buffer)
    local result = {}
    for i = 1, #buffer do
        local temp = string.sub(buffer, i, i)
        if temp ~= '.' then
        result[#result + 1] = tonumber(temp)
        end
    end
    for i = 0, 8 - #buffer do
        result[#result + 1] = 0
    end
    return result
end

function JF17CommandGenerator:_getAltitudeDigits(altitude)
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


return JF17CommandGenerator