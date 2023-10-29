local geometryTests = require("Tests.Mathematics.Geometry")
print("Testing Geometry")
for name, test in pairs(geometryTests) do
    print("--------------------------------")
    print("Running: "..name)
    test()
    print("Completed: "..name)
end
-- local latitude = 43.358880080789
-- local longitude = 44.055429646183
-- local Geometry = require("SharkPlanner.Mathematics.Geometry")
-- local inspect = require("SharkPlanner.inspect")

-- print("Hello world")
-- local dms = Geometry.decimalAngleToDMS(43.358880080789, 0, 0)
-- assert(dms.degrees == 43)
-- assert(dms.minutes == 21)
-- print(inspect(dms))
-- local dms = Geometry.decimalAngleToDMS(43.358880080789, 0, 1)
-- print(inspect(dms))
-- local dms = Geometry.decimalAngleToDMS(43.5, 0, 0)
-- print(inspect(dms))

-- local dms = Geometry.decimalAngleToDMS(3.001, 0, 1)
-- print(inspect(dms))
-- -- local dms = decimalAngleToDMS(3.50, 0, 3)
-- -- print(inspect(dms))
-- -- local dms = decimalAngleToDMS(3.51, 0, 3)
-- -- print(inspect(dms))
-- -- local dms = decimalAngleToDMS(3.51, 0, 1)
-- -- print(inspect(dms))
