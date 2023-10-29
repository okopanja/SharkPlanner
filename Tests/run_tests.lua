local geometryTests = require("Tests.Mathematics.Geometry")
print("Testing Geometry")
for name, test in pairs(geometryTests) do
    print("--------------------------------")
    print("Running: "..name)
    test()
    print("Completed: "..name)
end
