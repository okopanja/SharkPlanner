local Logging = require("SharkPlanner.Utils.Logging")
local GazelleCommandGenerator = require("SharkPlanner.Modules.SA342Gazelle.GazelleCommandGenerator")

local SA342MinigunCommandGenerator = GazelleCommandGenerator:new()

function SA342MinigunCommandGenerator:new(o)
  --o = BaseCommandGenerator:new()
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function SA342MinigunCommandGenerator:getAircraftName()
    return "SA342Minigun"
  end

return SA342MinigunCommandGenerator