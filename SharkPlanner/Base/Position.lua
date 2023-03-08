local math = require("math")

Position = {
  x = 0,
  y = 0,
  z = 0,
  longitude = 0,
  latitude = 0
}

LatHemispheres = {
  NORTH = 0,
  SOUTH = 1
}

LongHemispheres = {
  EAST = 0,
  WEST = 1
}

function Position:new (o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Position:getX()
  return self.x
end

function Position:getY()
  return self.y
end

function Position:getZ()
  return self.z
end

function Position:getLongitude()
  return self.longitude
end

function Position:getLatitude()
  return self.longitude
end

function Position:getLongitudeDMS()
  return convertDecimalToDMS(self.longitude)
end

function Position:getLatitudeDMS()
  return convertDecimalToDMS(self.longitude)
end

function Position:getLongitudeDMDec()
  return convertDecimalToDMDec(self.longitude)
end

function Position:getLatitudeDMDec()
  return convertDecimalToDMDec(self.latitude)
end

function Position:getLatitudeHemisphere()
  if self.latitude >= 0 then
    return LatHemispheres.NORTH
  else
    return LatHemispheres.SOUTH
  end
end

function Position:getLongitudeHemisphere()
  if self.longitude >= 0 then
    return LongHemispheres.EAST
  else
    return LongHemispheres.WEST
  end
end

function Position:getText()
  return "X: "..self.x.." Z: "..self.z.." Y: "..self.y.."(latitude: "..self.latitude..", longitude: "..self.longitude..")"
end

function convertDecimalToDMS(decimal)
  local result = {}
  result.degrees = math.floor(decimal)
  local rest = decimal - result.degrees
  result.minutes = math.floor(rest * 60)
  rest = rest - result.minutes
  -- round up last digit!
  result.seconds = math.floor((rest * 60) + 0.5)
  return result
end

function convertDecimalToDMDec(decimal)
  local result = {}
  result.degrees = math.floor(decimal)
  local rest = decimal - result.degrees
  result.minutes = rest * 60
  return result
end

return Position
