local Logging = require("SharkPlanner.Utils.Logging")
local BaseCommandGenerator = require("SharkPlanner.Base.BaseCommandGenerator")
local Command = require("SharkPlanner.Base.Command")
local Position = require("SharkPlanner.Base.Position")
local Configuration = require("SharkPlanner.Base.Configuration")
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

function CACommandGenerator:getAircraftName()
  return "Combined Arms"
end


function CACommandGenerator:getMaximalWaypointCount()
  return Configuration:getOption("Combined Arms.Entry limits.MaximalNumberWaypoints")
end

function CACommandGenerator:getMaximalFixPointCount()
  return Configuration:getOption("Combined Arms.Entry limits.MaximalNumberFixpoints")
end

function CACommandGenerator:getMaximalTargetPointCount()
  return Configuration:getOption("Combined Arms.Entry limits.MaximalNumberTargetpoints")
end

function CACommandGenerator:generateCommands(waypoints, fixpoints, targets)
  return {}
end

return CACommandGenerator
