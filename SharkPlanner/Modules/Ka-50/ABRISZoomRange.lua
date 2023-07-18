
-- class to be used to handle rotations in different ABRIS ranges
ABRISZoomRange = {}


function ABRISZoomRange:new (o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self

  o.ROTATION_TO_SCREEN_FACTOR = 1.23456
  o.HORIZONTAL_ROTATIONS = 10
  o.VERTICAL_ROTATIONS = 8

  o.vertical = o.range * o.VERTICAL_ROTATIONS / o.ROTATION_TO_SCREEN_FACTOR
  o.horizontal = o.range * o.HORIZONTAL_ROTATIONS / o.ROTATION_TO_SCREEN_FACTOR
  return o
end

function ABRISZoomRange:getLevel()
  return self.level
end

function ABRISZoomRange:getRange()
  return self.range
end

function ABRISZoomRange:getVertical()
  return self.vertical
end

function ABRISZoomRange:getHorizontal()
  return self.horizontal
end

function ABRISZoomRange:toRotationsX(deltaX)
  return self.VERTICAL_ROTATIONS * deltaX / self.vertical
end

function ABRISZoomRange:toRotationsZ(deltaZ)
  return self.HORIZONTAL_ROTATIONS * deltaZ / self.horizontal
end

function ABRISZoomRange:areBothPointsWithinZRange(current, next)
  return math.abs(current:getZ() - next:getZ()) <= (0.8 * self.horizontal)
end

function ABRISZoomRange:areBothPointsWithinXRange(current, next)
  return math.abs(current:getX() - next:getX()) <= (0.8 * self.vertical)
end

return ABRISZoomRange
