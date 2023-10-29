local latitude = 43.358880080789
local longitude = 44.055429646183
local Geometry = require("SharkPlanner.Mathematics.Geometry")
local tests = {}
local inspect = require("SharkPlanner.inspect")
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
    print(inspect(dms))
    assert(dms.degrees == 43)
    assert(dms.minutes == 0)
    assert(dms.seconds == 0)
    assert(dms.sign == 1)
end
tests["test_degAngleToDMSAngle_degree_with_precission_0"] = test_degAngleToDMSAngle_degree_with_precission_0

local function test_degAngleToDMSAngle_degree_with_precission_1()
    local dms = Geometry.degAngleToDMSAngle(43.358880080789, 1)
    print(inspect(dms))
    assert(dms.degrees == 43.4)
    assert(dms.minutes == 0)
    assert(dms.seconds == 0)
    assert(dms.sign == 1)
end
tests["test_degAngleToDMSAngle_degree_with_precission_1"] = test_degAngleToDMSAngle_degree_with_precission_1

local function test_degAngleToDMSAngle_degree_with_precission_2()
    local dms = Geometry.degAngleToDMSAngle(43.358880080789, 2)
    print(inspect(dms))
    assert(dms.degrees == 43.36)
    assert(dms.minutes == 0)
    assert(dms.seconds == 0)
    assert(dms.sign == 1)
end
tests["test_degAngleToDMSAngle_degree_with_precission_2"] = test_degAngleToDMSAngle_degree_with_precission_2

local function test_degAngleToDMSAngle_degree_minute_with_precission_0()
    local dms = Geometry.degAngleToDMSAngle(43.358880080789, 0, 0)
    print(inspect(dms))
    assert(dms.degrees == 43)
    assert(dms.minutes == 22)
    assert(dms.seconds == 0)
    assert(dms.sign == 1)
end
tests["test_degAngleToDMSAngle_degree_minute_with_precission_0"] = test_degAngleToDMSAngle_degree_minute_with_precission_0

local function test_degAngleToDMSAngle_degree_minute_with_precission_1()
    local dms = Geometry.degAngleToDMSAngle(43.358880080789, 0, 1)
    print(inspect(dms))
    assert(dms.degrees == 43)
    assert(dms.minutes == 21.5)
    assert(dms.seconds == 0)
    assert(dms.sign == 1)
end
tests["test_degAngleToDMSAngle_degree_minute_with_precission_1"] = test_degAngleToDMSAngle_degree_minute_with_precission_1

return tests