local Logging = require("SharkPlanner.Utils.Logging")
local GazelleCommandGenerator = require("SharkPlanner.Modules.SA342Gazelle.GazelleCommandGenerator")

local SA342MCommandGenerator = GazelleCommandGenerator:new()

function SA342MCommandGenerator:new(o)
  --o = BaseCommandGenerator:new()
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function SA342MCommandGenerator:getAircraftName()
    return "SA342M"
end

return SA342MCommandGenerator