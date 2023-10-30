
local LatHemispheres = {
    NORTH = 0,
    SOUTH = 1
}

local LatHemispheresStr = {
    [LatHemispheres.NORTH] = "N",
    [LatHemispheres.SOUTH] = "S"
}

local LongHemispheres = {
    EAST = 0,
    WEST = 1
}

local LongHemispheresStr = {
    [LongHemispheres.EAST] = "E",
    [LongHemispheres.WEST] = "W",
}

return {
    LatHemispheres = LatHemispheres,
    LongHemispheres = LongHemispheres,
    LatHemispheresStr = LatHemispheresStr,
    LongHemispheresStr =LongHemispheresStr,
}