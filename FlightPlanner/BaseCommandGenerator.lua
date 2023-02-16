BaseCommandGenerator = {}

function BaseCommandGenerator:new (o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function BaseCommandGenerator:getMaximalWaypointCount()
  return nil
end

function BaseCommandGenerator:getMaximalTargetPointsCount()
  return nil
end

function BaseCommandGenerator:generateCommands(waypoints)
  return nil
end
