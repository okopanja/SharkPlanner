local Logging = require("SharkPlanner.Utils.Logging")
local BaseCommandGenerator = require("SharkPlanner.Base.BaseCommandGenerator")
local Command = require("SharkPlanner.Base.Command")
local Position = require("SharkPlanner.Base.Position")

-- require("net")


local default_delay = 100 -- default delay in ms


-- KA50IIICommandGenerator = {}
CACommandGenerator = BaseCommandGenerator:new()


function CACommandGenerator:new(o)
  --o = BaseCommandGenerator:new()
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function CACommandGenerator:getMaximalWaypointCount()
  return 100
end

function CACommandGenerator:getMaximalFixPointCount()
  return 100
end

function CACommandGenerator:getMaximalTargetPointCount()
  return 100
end

function CACommandGenerator:generateCommands(waypoints, fixpoints, targets)
  return {}
end

return CACommandGenerator
