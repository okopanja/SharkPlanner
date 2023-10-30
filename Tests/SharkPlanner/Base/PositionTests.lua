local Position = require("SharkPlanner.Base.Position")

local tests = {}
-- Geometry.enable_debug()

local function test_Position_getLatitudeAsDMSString()
    local pos = Position:new{
        latitude=21.4356,
        longitude=46.12655,
    }

    local latitudeStr = pos:getLatitudeAsDMSString{}
    assert(latitudeStr == "N 21 26 08")

    local latitudeStr = pos:getLatitudeAsDMSString{hemisphere_format = "%s "}
    assert(latitudeStr == "N 21 26 08")

    local latitudeStr = pos:getLatitudeAsDMSString{hemisphere_format = "%s ", degrees_format="%02.0f ", minutes_format = "%02.0f "}
    assert(latitudeStr == "N 21 26 08")

    local latitudeStr = pos:getLatitudeAsDMSString{hemisphere_format = "%s ", degrees_format="%02.0f ", minutes_format = "%02.0f ", seconds_format = "%02.0f"}
    assert(latitudeStr == "N 21 26 08")

    local latitudeStr = pos:getLatitudeAsDMSString{hemisphere_format = "%s ", degrees_format="%02.0f ", minutes_format = "%02.0f ", seconds_format = "%04.1f", precision = 1}
    assert(latitudeStr == "N 21 26 08.2")

    local latitudeStr = pos:getLatitudeAsDMSString{hemisphere_format = "%s ", degrees_format="%02.0f ", minutes_format = "%02.0f ", seconds_format = "%05.2f", precision = 2}
    assert(latitudeStr == "N 21 26 08.16")

    local pos = Position:new{
        latitude=1.4356,
        longitude=46.12655,
    }

    local latitudeStr = pos:getLatitudeAsDMSString{hemisphere_format = "%s ", degrees_format="%02.0f ", minutes_format = "%02.0f ", seconds_format = "%05.2f", precision = 2}
    assert(latitudeStr == "N 01 26 08.16")

    local pos = Position:new{
        latitude=0,
        longitude=0,
    }

    local latitudeStr = pos:getLatitudeAsDMSString{hemisphere_format = "%s ", degrees_format="%02.0f ", minutes_format = "%02.0f ", seconds_format = "%05.2f", precision = 2}
    assert(latitudeStr == "N 00 00 00.00")

end
tests["test_Position_getLatitudeAsDMSString"] = test_Position_getLatitudeAsDMSString

local function test_Position_getLongitudeAsDMSString()

    local pos = Position:new{
        latitude=21.4356,
        longitude=46.12655,
    }

    local longitudeStr = pos:getLongitudeAsDMSString{}
    assert(longitudeStr == "E 046 07 36")

    local longitudeStr = pos:getLongitudeAsDMSString{hemisphere_format = "%s "}
    assert(longitudeStr == "E 046 07 36")

    local longitudeStr = pos:getLongitudeAsDMSString{hemisphere_format = "%s ", degrees_format="%03.0f ", minutes_format = "%02.0f "}
    assert(longitudeStr == "E 046 07 36")

    local longitudeStr = pos:getLongitudeAsDMSString{hemisphere_format = "%s ", degrees_format="%03.0f ", minutes_format = "%02.0f ", seconds_format = "%02.0f"}
    assert(longitudeStr == "E 046 07 36")

    local longitudeStr = pos:getLongitudeAsDMSString{hemisphere_format = "%s ", degrees_format="%03.0f ", minutes_format = "%02.0f ", seconds_format = "%04.1f", precision = 1}
    assert(longitudeStr == "E 046 07 35.6")

    local longitudeStr = pos:getLongitudeAsDMSString{hemisphere_format = "%s ", degrees_format="%03.0f ", minutes_format = "%02.0f ", seconds_format = "%05.2f", precision = 2}
    assert(longitudeStr == "E 046 07 35.58")

    local pos = Position:new{
        latitude=21.4356,
        longitude=246.12655,
    }

    local longitudeStr = pos:getLongitudeAsDMSString{hemisphere_format = "%s ", degrees_format="%03.0f ", minutes_format = "%02.0f ", seconds_format = "%05.2f", precision = 2}
    assert(longitudeStr == "E 246 07 35.58")

    local pos = Position:new{
        latitude=21.4356,
        longitude=6.12655,
    }

    local longitudeStr = pos:getLongitudeAsDMSString{hemisphere_format = "%s ", degrees_format="%03.0f ", minutes_format = "%02.0f ", seconds_format = "%05.2f", precision = 2}
    assert(longitudeStr == "E 006 07 35.58")
end
tests["test_Position_getLongitudeAsDMSString"] = test_Position_getLongitudeAsDMSString


return  tests