local Logging = require("SharkPlanner.Utils.Logging")
local GazelleCommandGenerator = require("SharkPlanner.Modules.SA342Gazelle.GazelleCommandGenerator")

local SA342LCommandGenerator = GazelleCommandGenerator:new()

function SA342LCommandGenerator:new(o)
  --o = BaseCommandGenerator:new()
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function SA342LCommandGenerator:getAircraftName()
    return "SA342L"
end

return SA342LCommandGenerator