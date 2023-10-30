local geometryTests = require("Tests.Mathematics.GeometryTests")
local positionTests = require("Tests.SharkPlanner.Base.PositionTests")
local Position = require("SharkPlanner.Base.Position")

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


local pos = Position:new{
    latitude=21.4356,
    longitude=46.12655,
 --   longitude=46.5,
}

-- print(pos:getLatitudeAsDMSString{})
-- print(pos:getLatitudeAsDMSString{hemisphere_format=""})
-- print(pos:getLatitudeAsDMSString{
--         -- hemisphere_format="",
--         -- degrees_format="%02.0f",
--         -- minutes_format="%02.0f",
--         seconds_format="%04.1f",
--         precision = 1
--     }
-- )

-- for i, v in ipairs(pos:getLatitudeAsDMSBuffer{precision = 1, seconds_format="%04.1f"}) do
--     print(v)
-- end