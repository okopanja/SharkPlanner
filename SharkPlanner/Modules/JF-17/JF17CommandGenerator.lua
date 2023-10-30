local Logging = require("SharkPlanner.Utils.Logging")
local BaseCommandGenerator = require("SharkPlanner.Base.BaseCommandGenerator")
local Command = require("SharkPlanner.Base.Command")
local Position = require("SharkPlanner.Base.Position")
local Hemispheres = require("SharkPlanner.Base.Hemispheres")
local Configuration = require("SharkPlanner.Base.Configuration")

local JF17CommandGenerator = BaseCommandGenerator:new{}
-- UFCP is the front keyboard
local UFCP = 46
-- Easy to us dictionary of commands
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

-- MFCD represents all MFCD in module
local MFCD = 47
JF17CommandGenerator.MFCD_buttons = {
    Center_MFCD_Brt_MINUS = 3301,
    Center_MFCD_Brt_PLUS = 3300,
    Center_MFCD_Cont_MINUS = 3299,
    Center_MFCD_Cont_PLUS = 3298,
    Center_MFCD_D1 = 3293,
    Center_MFCD_D2 = 3294,
    Center_MFCD_D3 = 3295,
    Center_MFCD_D4 = 3296,
    Center_MFCD_D5 = 3297,
    Center_MFCD_L1 = 3277,
    Center_MFCD_L2 = 3278,
    Center_MFCD_L3 = 3279,
    Center_MFCD_L4 = 3280,
    Center_MFCD_L5 = 3281,
    Center_MFCD_L6 = 3282,
    Center_MFCD_L7 = 3283,
    Center_MFCD_L8 = 3284,
    Center_MFCD_Power = 3276,
    Center_MFCD_R1 = 3285,
    Center_MFCD_R2 = 3286,
    Center_MFCD_R3 = 3287,
    Center_MFCD_R4 = 3288,
    Center_MFCD_R5 = 3289,
    Center_MFCD_R6 = 3290,
    Center_MFCD_R7 = 3291,
    Center_MFCD_R8 = 3292,
    Center_MFCD_Sym_MINUS = 3270,
    Center_MFCD_Sym_PLUS = 3269,
    Center_MFCD_U1 = 3271,
    Center_MFCD_U2 = 3272,
    Center_MFCD_U3 = 3273,
    Center_MFCD_U4 = 3274,
    Center_MFCD_U5 = 3275,
    Left_MFCD_Brt_MINUS = 3268,
    Left_MFCD_Brt_PLUS = 3267,
    Left_MFCD_Cont_MINUS = 3261,
    Left_MFCD_Cont_PLUS = 3260,
    Left_MFCD_D1 = 3262,
    Left_MFCD_D2 = 3263,
    Left_MFCD_D3 = 3264,
    Left_MFCD_D4 = 3265,
    Left_MFCD_D5 = 3266,
    Left_MFCD_L1 = 3244,
    Left_MFCD_L2 = 3245,
    Left_MFCD_L3 = 3246,
    Left_MFCD_L4 = 3247,
    Left_MFCD_L5 = 3248,
    Left_MFCD_L6 = 3249,
    Left_MFCD_L7 = 3250,
    Left_MFCD_L8 = 3251,
    Left_MFCD_Power = 3243,
    Left_MFCD_R1 = 3252,
    Left_MFCD_R2 = 3253,
    Left_MFCD_R3 = 3254,
    Left_MFCD_R4 = 3255,
    Left_MFCD_R5 = 3256,
    Left_MFCD_R6 = 3257,
    Left_MFCD_R7 = 3258,
    Left_MFCD_R8 = 3259,
    Left_MFCD_Sym_MINUS = 3237,
    Left_MFCD_Sym_PLUS = 3236,
    Left_MFCD_U1 = 3238,
    Left_MFCD_U2 = 3239,
    Left_MFCD_U3 = 3240,
    Left_MFCD_U4 = 3241,
    Left_MFCD_U5 = 3242,
    Right_MFCD_Brt_MINUS = 3334,
    Right_MFCD_Brt_PLUS = 3333,
    Right_MFCD_Cont_MINUS = 3332,
    Right_MFCD_Cont_PLUS = 3331,
    Right_MFCD_D1 = 3326,
    Right_MFCD_D2 = 3327,
    Right_MFCD_D3 = 3328,
    Right_MFCD_D4 = 3329,
    Right_MFCD_D5 = 3330,
    Right_MFCD_L1 = 3310,
    Right_MFCD_L2 = 3311,
    Right_MFCD_L3 = 3312,
    Right_MFCD_L4 = 3313,
    Right_MFCD_L5 = 3314,
    Right_MFCD_L6 = 3315,
    Right_MFCD_L7 = 3316,
    Right_MFCD_L8 = 3317,
    Right_MFCD_Power = 3309,
    Right_MFCD_R1 = 3318,
    Right_MFCD_R2 = 3319,
    Right_MFCD_R3 = 3320,
    Right_MFCD_R4 = 3321,
    Right_MFCD_R5 = 3322,
    Right_MFCD_R6 = 3323,
    Right_MFCD_R7 = 3324,
    Right_MFCD_R8 = 3325,
    Right_MFCD_Sym_MINUS = 3303,
    Right_MFCD_Sym_PLUS = 3302,
    Right_MFCD_U1 = 3304,
    Right_MFCD_U2 = 3305,
    Right_MFCD_U3 = 3306,
    Right_MFCD_U4 = 3307,
    Right_MFCD_U5 = 3308,
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
    return 6
end

function JF17CommandGenerator:getMaximalTargetPointCount()
    return 4
end

-- main function for generating commands
function JF17CommandGenerator:generateCommands(waypoints, fixpoints, targets)
    self.ufcpDelay = Configuration:getOption("JF-17.UFCP.CommandDelay")
    self.mfcdDelay = Configuration:getOption("JF-17.MFCD.CommandDelay")
    local commands = {}
    -- Enter DEST subpage
    self:ufcpEnterDST(commands)
    
    -- enter waypoints
    self:enterWaypoints(commands, waypoints, 1)
    -- clear unused waypoints
    self:clearWaypoints(commands, #waypoints + 1, self:getMaximalWaypointCount())

    -- enter missile steer points
    local missile_offset = 30
    self:enterWaypoints(commands, fixpoints, missile_offset)
    -- clear unused missile steer points
    self:clearWaypoints(commands, missile_offset + #fixpoints + 1, missile_offset + self:getMaximalFixPointCount() - #fixpoints + 1)

    -- enter missile/bomb target points
    local target_offset = 36
    self:enterWaypoints(commands, targets, target_offset)
    -- clear unused missile steer points
    self:clearWaypoints(commands, target_offset + #targets + 1, target_offset + self:getMaximalTargetPointCount() - #targets + 1)

    -- select Waypoint 1 in FPL
    self:enterWaypointNumber(commands, 1)
    self:ufcpRTN(commands, "Exit to main screen")
    
    -- select Waypoint 1 in main mode
    self:enterWaypointNumber(commands, 1)
    return commands
end

-- sequence commands
function JF17CommandGenerator:ufcpEnterDST(commands)
    self:ufcpRTN(commands, "Exit to main screen")
    self:ufcpDST(commands, "Enter DST")
end

function JF17CommandGenerator:enterWaypoints(commands, waypoints, start)
    -- Enter waypoints
    for i, waypoint in ipairs(waypoints) do
        self:ufcpEnterWaypoint(commands, i + start - 1, waypoint)
    end
end

function JF17CommandGenerator:clearWaypoints(commands, start_point, end_point)
    self:enterWaypointNumber(commands, start_point)
    -- self:mfcdU5(commands, "Clear waypoint: "..start_point, 0)
    for i = start_point, end_point do
        self:mfcdU5(commands, "Clear waypoint: "..i)
        self:mfcdL2(commands, "Step next")
    end
end

function JF17CommandGenerator:ufcpEnterWaypoint(commands, waypoint_number, waypoint)
    -- first we select waypoint number
    self:enterWaypointNumber(commands, waypoint_number)

    -- clear waypoint => we wish to make sure that hemispheres and altitude sign are clear with this.
    -- For 100% proper functioning depends on:
    -- https://forum.dcs.world/topic/335543-upfc-entry-dst-clr-does-not-fully-clear-waypoint
    -- https://forum.dcs.world/topic/335539-ufcp-coordinate-entry-unable-the-toggle-westereastern-hemisphere
    self:mfcdU5(commands, "Clear waypoint")

    -- enter latitude
    self:enterLatitude(commands, waypoint)

    -- enter longitude
    self:enterLongitude(commands, waypoint)

    -- enter altitude
    self:enterAltitude(commands, waypoint)
end

-- sequence functions
function JF17CommandGenerator:enterWaypointNumber(commands, i)
    self:ufcpR1(commands, "Enter waypoint number entry")
    local waypointDigits = self:_getWaypointDigits(i)
    for i, v in ipairs(waypointDigits) do
        Logging.debug("Waypoint digit: "..v)
        self:ufcpPressDigitButton(commands, v, "Enter digit: "..v)
    end
    self:ufcpR1(commands, "Exit waypoint number entry")
end

function JF17CommandGenerator:enterLatitude(commands, waypoint)
    -- enter numeric part
    self:ufcpL2(commands, "Enter waypoint latitude numeric entry")
    local latitude_digits = waypoint:getLatitudeAsDMSBuffer{precision = 1, seconds_format = "%04.1f"}
    for pos, digit in pairs(latitude_digits) do
        Logging.debug("Latitude digit: "..digit)
        self:ufcpPressDigitButton(commands, digit, "Latitude digit: "..digit)
    end
    self:ufcpL2(commands, "Exit waypoint latitude numeric entry")
    -- enter hemisphere
    if waypoint:getLatitudeHemisphere() == Hemispheres.LatHemispheres.SOUTH then
        self:ufcpR2(commands, "South")
    end
end

function JF17CommandGenerator:enterLongitude(commands, waypoint)
    -- enter numeric part
    self:ufcpL3(commands, "Enter waypoint latitude numeric entry")
    local longitude_digits = waypoint:getLongitudeAsDMSBuffer{precision = 1, seconds_format = "%04.1f"}
    for pos, digit in pairs(longitude_digits) do
        Logging.debug("Longitude digit: "..digit)
        self:ufcpPressDigitButton(commands, digit, "Longitude digit: "..digit)
    end
    self:ufcpL3(commands, "Exit waypoint longitude numeric entry")
    -- enter hemisphere
    if waypoint:getLatitudeHemisphere() == Hemispheres.LatHemispheres.WEST then
        self:ufcpR3(commands, "West")
    end
end

function JF17CommandGenerator:enterAltitude(commands, waypoint)
    self:ufcpR4(commands, "Enter waypoint altitude entry")
    local altitude_digits = self:_getAltitudeDigits(waypoint:getAltitudeFeet())
    for pos, digit in pairs(altitude_digits) do
        Logging.debug("Altitude digit: "..digit)
        self:ufcpPressDigitButton(commands, digit, "Altitude digit: "..digit)
    end
    self:ufcpR4(commands, "Exit waypoint altitude entry")
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
end

function JF17CommandGenerator:mfcdL2(commands, comment, delay)
    commands[#commands + 1] = Command:new():setName("MFCD: L2"):setComment(comment):setDevice(MFCD):setCode(JF17CommandGenerator.MFCD_buttons.Left_MFCD_L2):setDelay(delay or self.ufcpDelay):setIntensity(1):setDepress(true)
end

function JF17CommandGenerator:mfcdL3(commands, comment, delay)
    commands[#commands + 1] = Command:new():setName("MFCD: L3"):setComment(comment):setDevice(MFCD):setCode(JF17CommandGenerator.MFCD_buttons.Left_MFCD_L3):setDelay(delay or self.ufcpDelay):setIntensity(1):setDepress(true)
end

function JF17CommandGenerator:mfcdU5(commands, comment, delay)
    commands[#commands + 1] = Command:new():setName("MFCD: U5"):setComment(comment):setDevice(MFCD):setCode(JF17CommandGenerator.MFCD_buttons.Left_MFCD_U5):setDelay(delay or self.mfcdDelay):setIntensity(1):setDepress(true)
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

function JF17CommandGenerator:_getAltitudeDigits(altitude)
    local buffer = string.format("%05.0f", altitude)
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