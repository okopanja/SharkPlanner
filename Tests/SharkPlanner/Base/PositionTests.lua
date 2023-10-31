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


local function test_Position_getLatitudeAsDMSBuffer()
    local pos = Position:new{
        latitude=21.4356,
        longitude=46.12655,
    }
    local latitudeBuffer = pos:getLatitudeAsDMSBuffer{}
    local expected = {2, 1, 2, 6 ,0, 8}
    assert(#latitudeBuffer == #expected)
    for i, v in ipairs(latitudeBuffer) do
        assert(v == expected[i])
    end

    local latitudeBuffer = pos:getLatitudeAsDMSBuffer{degrees_format="%02.0f ", minutes_format = "%02.0f ", seconds_format = "%04.1f", precision = 1}
    local expected = {2, 1, 2, 6, 0, 8, 2}
    assert(#latitudeBuffer == #expected)
    for i, v in ipairs(latitudeBuffer) do
        assert(v == expected[i])
    end
end
tests["test_Position_getLatitudeAsDMSBuffer"] = test_Position_getLatitudeAsDMSBuffer


local function test_Position_getLongitudeAsDMSBuffer()
    local pos = Position:new{
        latitude=21.4356,
        longitude=46.12655,
    }
    local longitudeBuffer = pos:getLongitudeAsDMSBuffer{}
    local expected = {0, 4, 6, 0, 7, 3, 6}
    assert(#longitudeBuffer == #expected)
    for i, v in ipairs(longitudeBuffer) do
        assert(v == expected[i])
    end

    local longitudeBuffer = pos:getLongitudeAsDMSBuffer{degrees_format="%03.0f ", minutes_format = "%02.0f ", seconds_format = "%04.1f", precision = 1}
    local expected = {0, 4, 6, 0, 7, 3, 5, 6}
    assert(#longitudeBuffer == #expected)
    for i, v in ipairs(longitudeBuffer) do
        assert(v == expected[i])
    end
end
tests["test_Position_getLongitudeAsDMSBuffer"] = test_Position_getLongitudeAsDMSBuffer

local function test_Position_getLatitudeAsDMString()
    local pos = Position:new{
        latitude=21.4356,
        longitude=46.12655,
    }

    local latitudeStr = pos:getLatitudeAsDMString{}
    assert(latitudeStr == "N 21 26")

    local latitudeStr = pos:getLatitudeAsDMString{hemisphere_format = "%s "}
    assert(latitudeStr == "N 21 26")

    local latitudeStr = pos:getLatitudeAsDMString{hemisphere_format = "%s ", degrees_format="%02.0f ", minutes_format = "%02.0f"}
    assert(latitudeStr == "N 21 26")

    local latitudeStr = pos:getLatitudeAsDMString{hemisphere_format = "%s ", degrees_format="%02.0f ", minutes_format = "%04.1f", precision = 1}
    assert(latitudeStr == "N 21 26.1")

    local latitudeStr = pos:getLatitudeAsDMString{hemisphere_format = "%s ", degrees_format="%02.0f ", minutes_format = "%05.2f", precision = 2}
    assert(latitudeStr == "N 21 26.14")

    local pos = Position:new{
        latitude=1.4356,
        longitude=46.12655,
    }

    local latitudeStr = pos:getLatitudeAsDMString{hemisphere_format = "%s ", degrees_format="%02.0f ", minutes_format = "%05.2f", precision = 2}
    assert(latitudeStr == "N 01 26.14")

    local pos = Position:new{
        latitude=0,
        longitude=0,
    }

    local latitudeStr = pos:getLatitudeAsDMString{hemisphere_format = "%s ", degrees_format="%02.0f ", minutes_format = "%05.2f", precision = 2}
    assert(latitudeStr == "N 00 00.00")
end
tests["test_Position_getLatitudeAsDMString"] = test_Position_getLatitudeAsDMString

return  tests