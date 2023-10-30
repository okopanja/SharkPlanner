local math = require("math")
-- local Logging = require("SharkPlanner.Utils.Logging")
local Hemispheres = require("SharkPlanner.Base.Hemispheres")
local Geometry = require("SharkPlanner.Mathematics.Geometry")


local Position = {
  x = nil,
  y = nil,
  z = nil,
  longitude = nil,
  latitude = nil
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

function Position:getAltitudeFeet()
  return self.y * 3.28084
end

function Position:getLongitude()
  return self.longitude
end

function Position:getLatitude()
  return self.latitude
end

function Position:getLatitudeAsDMS(precision)
  precision = precision or 0
  local result = Geometry.degAngleToDMSAngle(self.latitude, 0, 0, precision)
  return result
end

function Position:getLongitudeAsDMS(precision)
  precision = precision or 0
  local result = Geometry.degAngleToDMSAngle(self.longitude, 0, 0, precision)
  return result
end

function Position:getLatitudeAsDMSString(format_spec)
  format_spec.precision = format_spec.precision or 0
  format_spec.degrees_format = format_spec.degrees_format or "%02.0f "
  format_spec.minutes_format = format_spec.minutes_format or "%02.0f "
  format_spec.seconds_format = format_spec.seconds_format or "%02.0f" -- "%04.1f"
  format_spec.hemisphere_format = format_spec.hemisphere_format or "%s "

  local latitude = self:getLatitudeAsDMS(format_spec.precision)

  local latitudeString = string.format(
    format_spec.hemisphere_format, Hemispheres.LatHemispheresStr[self:getLatitudeHemisphere()])..
    string.format(format_spec.degrees_format, latitude.degrees)..
    string.format(format_spec.minutes_format, latitude.minutes)..
    string.format(format_spec.seconds_format, latitude.seconds
  )

  return latitudeString
end

function Position:getLongitudeAsDMSString(format_spec)
  format_spec.precision = format_spec.precision or 0
  format_spec.degrees_format = format_spec.degrees_format or "%03.0f "
  format_spec.minutes_format = format_spec.minutes_format or "%02.0f "
  format_spec.seconds_format = format_spec.seconds_format or "%02.0f" -- "%04.1f"
  format_spec.hemisphere_format = format_spec.hemisphere_format or "%s "

  local latitude = self:getLongitudeAsDMS(format_spec.precision)

  local longitudeString = string.format(
    format_spec.hemisphere_format, Hemispheres.LongHemispheresStr[self:getLongitudeHemisphere()])..
    string.format(format_spec.degrees_format, latitude.degrees)..
    string.format(format_spec.minutes_format, latitude.minutes)..
    string.format(format_spec.seconds_format, latitude.seconds
  )

  return longitudeString
end

function Position:getLatitudeAsDMSBuffer(format_spec)
  format_spec.precision = format_spec.precision or 0
  format_spec.degrees_format = format_spec.degrees_format or "%02.0f"
  format_spec.minutes_format = format_spec.minutes_format or "%02.0f"
  format_spec.seconds_format = format_spec.seconds_format or "%02.0f"
  format_spec.hemisphere_format = format_spec.hemisphere_format or ""

  local latitudeString = self:getLatitudeAsDMSString(format_spec)

  local result = {}
  for i = 1, #latitudeString do
    local temp = string.sub(latitudeString, i, i)
    if temp ~= '.' and temp then
      result[#result + 1] = tonumber(temp)
    end
  end

  return result
end

function Position:getLongitudeAsDMSBuffer(format_spec)
  format_spec.precision = format_spec.precision or 0
  format_spec.degrees_format = format_spec.degrees_format or "%02.0f"
  format_spec.minutes_format = format_spec.minutes_format or "%02.0f"
  format_spec.seconds_format = format_spec.seconds_format or "%02.0f"
  format_spec.hemisphere_format = format_spec.hemisphere_format or ""

  local latitudeString = self:getLongitudeAsDMSString(format_spec)

  local result = {}
  for i = 1, #latitudeString do
    local temp = string.sub(latitudeString, i, i)
    if temp ~= '.' and temp then
      result[#result + 1] = tonumber(temp)
    end
  end

  return result
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

function Position:getLatitudeDMSDec()
  return convertDecimalToDMSDec(self.latitude)
end

function Position:getLongitudeDMSDec()
  return convertDecimalToDMSDec(self.longitude)
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

function convertDecimalToDMSDec(decimal)
  local result = {}
  result.degrees = math.floor(math.abs(decimal))
  local rest = math.abs(decimal) - result.degrees
  result.minutes = math.floor(rest * 60)
  rest = rest - (result.minutes / 60 )
  -- round up last digit!
  result.seconds = rest * 3600
  -- if input is negative, now that componets got calcualted, return the original sign
  if decimal < 0 then result.degrees = - result.degrees end
  return result
end

return Position
