local math = require("math")
local Logging = require("SharkPlanner.Utils.Logging")
local Hemispheres = require("SharkPlanner.Base.Hemispheres")

local Position = {
  x = 0,
  y = 0,
  z = 0,
  longitude = 0,
  latitude = 0
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

function Position:setX(x)
  self.x = x
end

function Position:getY()
  return self.y
end

function Position:setY(y)
  self.y = y
end

function Position:getZ()
  return self.z
end

function Position:setZ(z)
  self.z = z
end

function Position:getAltitude()
  return self.y
end

function Position:getLongitude()
  return self.longitude
end

function Position:getLatitude()
  return self.latitude
end

function Position:getLongitudeDMS()
  return convertDecimalToDMS(self.longitude)
end

function Position:getLatitudeDMS()
  return convertDecimalToDMS(self.latitude)
end

function Position:getLongitudeDMDec()
  return convertDecimalToDMDec(self.longitude)
end

function Position:getLatitudeDMDec()
  return convertDecimalToDMDec(self.latitude)
end

function Position:getLatitudeHemisphere()
  if self.latitude >= 0 then
    return Hemispheres.LatHemispheres.NORTH
  else
    return Hemispheres.LatHemispheres.SOUTH
  end
end

function Position:getLongitudeHemisphere()
  if self.longitude >= 0 then
    return Hemispheres.LongHemispheres.EAST
  else
    return Hemispheres.LongHemispheres.WEST
  end
end

function Position:getText()
  return "X: "..self.x.." Z: "..self.z.." Y: "..self.y.."(latitude: "..self.latitude..", longitude: "..self.longitude..")"
end

function Position:getLatitudeDMSstr()
  local latitude = self:getLatitudeDMS()
  local hemisphere = "N"
  if(self.latitude < 0) then hemisphere = "S" end
  return  ""..latitude.degrees.."° "..string.format("%02d", latitude.minutes).."' "..string.format("%02d",latitude.seconds).."''"..hemisphere
end

function Position:getLongitudeDMSstr()
  local longitude = self:getLongitudeDMS()
  local hemisphere = "E"
  if(self.longitude < 0) then hemisphere = "W" end
  return ""..longitude.degrees.."° "..string.format("%02d",longitude.minutes).."' "..string.format("%02d", longitude.seconds).."''"..hemisphere
end

function convertDecimalToDMS(decimal)
  local result = {}
  result.degrees = math.floor(math.abs(decimal))
  local rest = math.abs(decimal) - result.degrees
  result.minutes = math.floor(rest * 60)
  rest = rest - (result.minutes / 60 )
  -- round up last digit!
  result.seconds = math.floor((rest * 3600) + 0.5)
  -- if input is negative, now that componets got calcualted, return the original sign
  if decimal < 0 then result.degrees = - result.degrees end
  return result
end

function convertDecimalToDMDec(decimal)
  local result = {}
  result.degrees = math.floor(math.abs(decimal))
  local rest = math.abs(decimal) - result.degrees
  result.minutes = rest * 60
  if decimal < 0 then result.degrees = - result.degrees end
  return result
end

return Position
