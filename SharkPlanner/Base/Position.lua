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
  format_spec.seconds_format = format_spec.seconds_format or "%02.0f"
  format_spec.hemisphere_format = format_spec.hemisphere_format or "%s "

  local latitude = self:getLatitudeAsDMS(format_spec.precision)

  local latitudeString = 
    string.format(format_spec.hemisphere_format, Hemispheres.LatHemispheresStr[self:getLatitudeHemisphere()])..
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
  format_spec.seconds_format = format_spec.seconds_format or "%02.0f"
  format_spec.hemisphere_format = format_spec.hemisphere_format or "%s "

  local latitude = self:getLongitudeAsDMS(format_spec.precision)

  local longitudeString = 
    string.format(format_spec.hemisphere_format, Hemispheres.LongHemispheresStr[self:getLongitudeHemisphere()])..
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
  format_spec.degrees_format = format_spec.degrees_format or "%03.0f"
  format_spec.minutes_format = format_spec.minutes_format or "%02.0f"
  format_spec.seconds_format = format_spec.seconds_format or "%02.0f"
  format_spec.hemisphere_format = format_spec.hemisphere_format or ""

  local longitudeString = self:getLongitudeAsDMSString(format_spec)

  local result = {}
  for i = 1, #longitudeString do
    local temp = string.sub(longitudeString, i, i)
    if temp ~= '.' and temp then
      result[#result + 1] = tonumber(temp)
    end
  end

  return result
end

function Position:getLatitudeAsDM(precision)
  precision = precision or 0
  local result = Geometry.degAngleToDMSAngle(self.latitude, 0, precision)
  return result
end

function Position:getLongitudeAsDM(precision)
  precision = precision or 0
  local result = Geometry.degAngleToDMSAngle(self.longitude, 0, precision)
  return result
end

function Position:getLatitudeAsDMString(format_spec)
  format_spec.precision = format_spec.precision or 0
  format_spec.degrees_format = format_spec.degrees_format or "%02.0f "
  format_spec.minutes_format = format_spec.minutes_format or "%02.0f"
  format_spec.hemisphere_format = format_spec.hemisphere_format or "%s "

  local latitude = self:getLatitudeAsDM(format_spec.precision)

  local latitudeString = 
    string.format(format_spec.hemisphere_format, Hemispheres.LatHemispheresStr[self:getLatitudeHemisphere()])..
    string.format(format_spec.degrees_format, latitude.degrees)..
    string.format(format_spec.minutes_format, latitude.minutes)

  return latitudeString
end

function Position:getLongitudeAsDMString(format_spec)
  format_spec.precision = format_spec.precision or 0
  format_spec.degrees_format = format_spec.degrees_format or "%03.0f "
  format_spec.minutes_format = format_spec.minutes_format or "%02.0f"

  format_spec.hemisphere_format = format_spec.hemisphere_format or "%s "

  local latitude = self:getLongitudeAsDM(format_spec.precision)

  local longitudeString = 
    string.format(format_spec.hemisphere_format, Hemispheres.LongHemispheresStr[self:getLongitudeHemisphere()])..
    string.format(format_spec.degrees_format, latitude.degrees)..
    string.format(format_spec.minutes_format, latitude.minutes)

  return longitudeString
end

function Position:getLatitudeAsDMBuffer(format_spec)
  format_spec.precision = format_spec.precision or 0
  format_spec.degrees_format = format_spec.degrees_format or "%02.0f"
  format_spec.minutes_format = format_spec.minutes_format or "%02.0f"
  format_spec.hemisphere_format = format_spec.hemisphere_format or ""

  local latitudeString = self:getLatitudeAsDMString(format_spec)

  local result = {}
  for i = 1, #latitudeString do
    local temp = string.sub(latitudeString, i, i)
    if temp ~= '.' and temp then
      result[#result + 1] = tonumber(temp)
    end
  end

  return result
end

function Position:getLongitudeAsDMBuffer(format_spec)
  format_spec.precision = format_spec.precision or 0
  format_spec.degrees_format = format_spec.degrees_format or "%03.0f"
  format_spec.minutes_format = format_spec.minutes_format or "%02.0f"
  format_spec.hemisphere_format = format_spec.hemisphere_format or ""

  local longitudeString = self:getLongitudeAsDMString(format_spec)

  local result = {}
  for i = 1, #longitudeString do
    local temp = string.sub(longitudeString, i, i)
    if temp ~= '.' and temp then
      result[#result + 1] = tonumber(temp)
    end
  end

  return result
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
  return self:getLatitudeAsDMSString{
    precision = 0,
    hemisphere_format = "",
    degrees_format = "%01d° ",
    minutes_format = "%02d' ",
    seconds_format = "%02d''",
  }..Hemispheres.LatHemispheresStr[self:getLatitudeHemisphere()]
end

function Position:getLongitudeDMSstr()
  return self:getLongitudeAsDMSString{
    precision = 0,
    hemisphere_format = "",
    degrees_format = "%01d° ",
    minutes_format = "%02d' ",
    seconds_format = "%02d''",
  }..Hemispheres.LongHemispheresStr[self:getLongitudeHemisphere()]
end

return Position
