local geometryTests = require("Tests.Mathematics.GeometryTests")
local positionTests = require("Tests.SharkPlanner.Base.PositionTests")

print("Testing Geometry")
for name, test in pairs(geometryTests) do
    print("--------------------------------")
    print("Running: "..name)
    test()
    print("Completed: "..name)
end

print("Testing Position")
for name, test in pairs(positionTests) do
    print("--------------------------------")
    print("Running: "..name)
    test()
    print("Completed: "..name)
end
