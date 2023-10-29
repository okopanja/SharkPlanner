local latitude = 43.358880080789
local longitude = 44.055429646183
local Geometry = require("SharkPlanner.Mathematics.Geometry")
local tests = {}
Geometry.enable_debug()
-- print("Hello world")
-- local dms = Geometry.degAngleToDMSAngle(43.358880080789, 0, 0)
-- assert(dms.degrees == 43)
-- assert(dms.minutes == 21)
-- print(inspect(dms))
-- local dms = Geometry.degAngleToDMSAngle(43.358880080789, 0, 1)
-- print(inspect(dms))
-- local dms = Geometry.degAngleToDMSAngle(43.5, 0, 0)
-- print(inspect(dms))

-- local dms = Geometry.degAngleToDMSAngle(3.001, 0, 1)
-- print(inspect(dms))
-- local dms = Geometry.degAngleToDMSAngle(3.50, 0, 3)
-- print(inspect(dms))
-- local dms = Geometry.degAngleToDMSAngle(3.51, 0, 3)
-- print(inspect(dms))
-- local dms = Geometry.degAngleToDMSAngle(3.51, 0, 1)
-- print(inspect(dms))

local function test_degAngleToDMSAngle_degree_with_precission_0()
    local dms = Geometry.degAngleToDMSAngle(43.358880080789, 0)
    assert(dms.degrees == 43)
    assert(dms.minutes == 0)
    assert(dms.seconds == 0)
    assert(dms.sign == 1)

    local dms = Geometry.degAngleToDMSAngle(44.055429646183, 0)
    assert(dms.degrees == 44)
    assert(dms.minutes == 0)
    assert(dms.seconds == 0)
    assert(dms.sign == 1)

    local dms = Geometry.degAngleToDMSAngle(44.655429646183, 0)
    assert(dms.degrees == 45)
    assert(dms.minutes == 0)
    assert(dms.seconds == 0)
    assert(dms.sign == 1)
end
tests["test_degAngleToDMSAngle_degree_with_precission_0"] = test_degAngleToDMSAngle_degree_with_precission_0

local function test_degAngleToDMSAngle_degree_with_precission_1()
    local dms = Geometry.degAngleToDMSAngle(43.358880080789, 1)
    assert(dms.degrees == 43.4)
    assert(dms.minutes == 0)
    assert(dms.seconds == 0)
    assert(dms.sign == 1)

    local dms = Geometry.degAngleToDMSAngle(44.055429646183, 1)
    assert(dms.degrees == 44.1)
    assert(dms.minutes == 0)
    assert(dms.seconds == 0)
    assert(dms.sign == 1)

    local dms = Geometry.degAngleToDMSAngle(44.655429646183, 1)
    assert(dms.degrees == 44.7)
    assert(dms.minutes == 0)
    assert(dms.seconds == 0)
    assert(dms.sign == 1)
end
tests["test_degAngleToDMSAngle_degree_with_precission_1"] = test_degAngleToDMSAngle_degree_with_precission_1

local function test_degAngleToDMSAngle_degree_with_precission_2()
    local dms = Geometry.degAngleToDMSAngle(43.358880080789, 2)
    assert(dms.degrees == 43.36)
    assert(dms.minutes == 0)
    assert(dms.seconds == 0)
    assert(dms.sign == 1)

    local dms = Geometry.degAngleToDMSAngle(44.055429646183, 2)
    assert(dms.degrees == 44.06)
    assert(dms.minutes == 0)
    assert(dms.seconds == 0)
    assert(dms.sign == 1)

    local dms = Geometry.degAngleToDMSAngle(44.655429646183, 2)
    assert(dms.degrees == 44.66)
    assert(dms.minutes == 0)
    assert(dms.seconds == 0)
    assert(dms.sign == 1)
end
tests["test_degAngleToDMSAngle_degree_with_precission_2"] = test_degAngleToDMSAngle_degree_with_precission_2

local function test_degAngleToDMSAngle_degree_minute_with_precission_0()
    local dms = Geometry.degAngleToDMSAngle(43.358880080789, 0, 0)
    assert(dms.degrees == 43)
    assert(dms.minutes == 22)
    assert(dms.seconds == 0)
    assert(dms.sign == 1)

    local dms = Geometry.degAngleToDMSAngle(44.055429646183, 0, 0)
    assert(dms.degrees == 44)
    assert(dms.minutes == 3)
    assert(dms.seconds == 0)
    assert(dms.sign == 1)

    local dms = Geometry.degAngleToDMSAngle(44.655429646183, 0, 0)
    assert(dms.degrees == 44)
    assert(dms.minutes == 39)
    assert(dms.seconds == 0)
    assert(dms.sign == 1)
end
tests["test_degAngleToDMSAngle_degree_minute_with_precission_0"] = test_degAngleToDMSAngle_degree_minute_with_precission_0

local function test_degAngleToDMSAngle_degree_minute_with_precission_1()
    local dms = Geometry.degAngleToDMSAngle(43.358880080789, 0, 1)
    assert(dms.degrees == 43)
    assert(dms.minutes == 21.5)
    assert(dms.seconds == 0)
    assert(dms.sign == 1)

    local dms = Geometry.degAngleToDMSAngle(44.055429646183, 0, 1)
    assert(dms.degrees == 44)
    assert(dms.minutes == 3.3)
    assert(dms.seconds == 0)
    assert(dms.sign == 1)

    local dms = Geometry.degAngleToDMSAngle(44.655429646183, 0, 1)
    assert(dms.degrees == 44)
    assert(dms.minutes == 39.3)
    assert(dms.seconds == 0)
    assert(dms.sign == 1)
end
tests["test_degAngleToDMSAngle_degree_minute_with_precission_1"] = test_degAngleToDMSAngle_degree_minute_with_precission_1

local function test_degAngleToDMSAngle_degree_minute_with_precission_2()
    local dms = Geometry.degAngleToDMSAngle(43.358880080789, 0, 2)
    assert(dms.degrees == 43)
    assert(dms.minutes == 21.53)
    assert(dms.seconds == 0)
    assert(dms.sign == 1)

    local dms = Geometry.degAngleToDMSAngle(44.055429646183, 0, 2)
    assert(dms.degrees == 44)
    assert(dms.minutes == 3.33)
    assert(dms.seconds == 0)
    assert(dms.sign == 1)

    local dms = Geometry.degAngleToDMSAngle(44.655429646183, 0, 2)
    assert(dms.degrees == 44)
    assert(dms.minutes == 39.33)
    assert(dms.seconds == 0)
    assert(dms.sign == 1)
end
tests["test_degAngleToDMSAngle_degree_minute_with_precission_2"] = test_degAngleToDMSAngle_degree_minute_with_precission_2

local function test_degAngleToDMSAngle_degree_minute_with_precission_3()
    local dms = Geometry.degAngleToDMSAngle(43.358880080789, 0, 3)
    assert(dms.degrees == 43)
    assert(dms.minutes == 21.533)
    assert(dms.seconds == 0)
    assert(dms.sign == 1)

    local dms = Geometry.degAngleToDMSAngle(44.055429646183, 0, 3)
    assert(dms.degrees == 44)
    assert(dms.minutes == 3.326)
    assert(dms.seconds == 0)
    assert(dms.sign == 1)

    local dms = Geometry.degAngleToDMSAngle(44.655429646183, 0, 3)
    assert(dms.degrees == 44)
    assert(dms.minutes == 39.326)
    assert(dms.seconds == 0)
    assert(dms.sign == 1)
end
tests["test_degAngleToDMSAngle_degree_minute_with_precission_3"] = test_degAngleToDMSAngle_degree_minute_with_precission_3

local function test_degAngleToDMSAngle_degree_minute_seconds_with_precission_0()
    local dms = Geometry.degAngleToDMSAngle(43.358880080789, 0, 0, 0)
    assert(dms.degrees == 43)
    assert(dms.minutes == 21)
    assert(dms.seconds == 32)
    assert(dms.sign == 1)

    local dms = Geometry.degAngleToDMSAngle(44.055429646183, 0, 0, 0)
    assert(dms.degrees == 44)
    assert(dms.minutes == 3)
    assert(dms.seconds == 20)
    assert(dms.sign == 1)

    local dms = Geometry.degAngleToDMSAngle(44.655429646183, 0, 0, 0)
    assert(dms.degrees == 44)
    assert(dms.minutes == 39)
    assert(dms.seconds == 20)
    assert(dms.sign == 1)
end
tests["test_degAngleToDMSAngle_degree_minute_seconds_with_precission_0"] = test_degAngleToDMSAngle_degree_minute_seconds_with_precission_0

local function test_degAngleToDMSAngle_degree_minute_seconds_with_precission_1()
    local dms = Geometry.degAngleToDMSAngle(43.358880080789, 0, 0, 1)
    assert(dms.degrees == 43)
    assert(dms.minutes == 21)
    assert(dms.seconds == 32)
    assert(dms.sign == 1)

    local dms = Geometry.degAngleToDMSAngle(44.055429646183, 0, 0, 1)
    assert(dms.degrees == 44)
    assert(dms.minutes == 3)
    assert(dms.seconds == 19.5)
    assert(dms.sign == 1)

    local dms = Geometry.degAngleToDMSAngle(44.655429646183, 0, 0, 1)
    assert(dms.degrees == 44)
    assert(dms.minutes == 39)
    assert(dms.seconds == 19.5)
    assert(dms.sign == 1)
end
tests["test_degAngleToDMSAngle_degree_minute_seconds_with_precission_1"] = test_degAngleToDMSAngle_degree_minute_seconds_with_precission_1

local function test_degAngleToDMSAngle_degree_minute_seconds_with_precission_2()
    local dms = Geometry.degAngleToDMSAngle(43.358880080789, 0, 0, 2)
    assert(dms.degrees == 43)
    assert(dms.minutes == 21)
    assert(dms.seconds == 31.97)
    assert(dms.sign == 1)

    local dms = Geometry.degAngleToDMSAngle(44.055429646183, 0, 0, 2)
    assert(dms.degrees == 44)
    assert(dms.minutes == 3)
    assert(dms.seconds == 19.55)
    assert(dms.sign == 1)

    local dms = Geometry.degAngleToDMSAngle(44.655429646183, 0, 0, 2)
    assert(dms.degrees == 44)
    assert(dms.minutes == 39)
    assert(dms.seconds == 19.55)
    assert(dms.sign == 1)
end
tests["test_degAngleToDMSAngle_degree_minute_seconds_with_precission_2"] = test_degAngleToDMSAngle_degree_minute_seconds_with_precission_2

local function test_degAngleToDMSAngle_degree_minute_seconds_with_precission_3()
    local dms = Geometry.degAngleToDMSAngle(43.358880080789, 0, 0, 3)
    assert(dms.degrees == 43)
    assert(dms.minutes == 21)
    assert(dms.seconds == 31.968)
    assert(dms.sign == 1)

    local dms = Geometry.degAngleToDMSAngle(44.055429646183, 0, 0, 3)
    assert(dms.degrees == 44)
    assert(dms.minutes == 3)
    assert(dms.seconds == 19.547)
    assert(dms.sign == 1)

    local dms = Geometry.degAngleToDMSAngle(44.655429646183, 0, 0, 3)
    assert(dms.degrees == 44)
    assert(dms.minutes == 39)
    assert(dms.seconds == 19.547)
    assert(dms.sign == 1)
end
tests["test_degAngleToDMSAngle_degree_minute_seconds_with_precission_3"] = test_degAngleToDMSAngle_degree_minute_seconds_with_precission_3

local function test_degAngleToDMSAngle_degree_minute_seconds_with_precission_0_round_back_second_minutes_degrees()
    local dms = Geometry.degAngleToDMSAngle(0.999880080789, 0, 0, 0)
    assert(dms.degrees == 1)
    assert(dms.minutes == 0)
    assert(dms.seconds == 0)
    assert(dms.sign == 1)

    local dms = Geometry.degAngleToDMSAngle(43.999880080789, 0, 0, 0)
    assert(dms.degrees == 44)
    assert(dms.minutes == 0)
    assert(dms.seconds == 0)
    assert(dms.sign == 1)

    local dms = Geometry.degAngleToDMSAngle(179.999880080789, 0, 0, 0)
    assert(dms.degrees == 180)
    assert(dms.minutes == 0)
    assert(dms.seconds == 0)
    assert(dms.sign == 1)
end
tests["test_degAngleToDMSAngle_degree_minute_seconds_with_precission_0_round_back_second_minutes_degrees"] = test_degAngleToDMSAngle_degree_minute_seconds_with_precission_0_round_back_second_minutes_degrees

local function test_degAngleToDMSAngle_degree_minute_seconds_with_precission_0_round_back_second_minutes()
    local dms = Geometry.degAngleToDMSAngle(0.989880080789, 0, 0, 0)
    assert(dms.degrees == 0)
    assert(dms.minutes == 59)
    assert(dms.seconds == 24)
    assert(dms.sign == 1)

    local dms = Geometry.degAngleToDMSAngle(43.989880080789, 0, 0, 0)
    assert(dms.degrees == 43)
    assert(dms.minutes == 59)
    assert(dms.seconds == 24)
    assert(dms.sign == 1)

    -- local dms = Geometry.degAngleToDMSAngle(359.999880080789, 0, 0, 0)
    -- assert(dms.degrees == 0)
    -- assert(dms.minutes == 0)
    -- assert(dms.seconds == 0)
    -- assert(dms.sign == 1)
end
tests["test_degAngleToDMSAngle_degree_minute_seconds_with_precission_0_round_back_second_minutes"] = test_degAngleToDMSAngle_degree_minute_seconds_with_precission_0_round_back_second_minutes


return tests