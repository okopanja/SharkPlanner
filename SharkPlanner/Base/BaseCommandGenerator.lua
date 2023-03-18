BaseCommandGenerator = {}

function BaseCommandGenerator:new (o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function BaseCommandGenerator:getAircraftName()
  return "Unknown"
end

function BaseCommandGenerator:getMaximalWaypointCount()
  return 0
end

function BaseCommandGenerator:getMaximalFixPointCount()
  return 0
end

function BaseCommandGenerator:getMaximalTargetPointCount()
  return 0
end

function BaseCommandGenerator:generateCommands(waypoints, fixpoints, targets)
  return {}
end

return BaseCommandGenerator
