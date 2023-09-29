local Logging = require("SharkPlanner.Utils.Logging")
local BaseCommandGenerator = require("SharkPlanner.Base.BaseCommandGenerator")

local F16CBL50CommandGenerator = BaseCommandGenerator:new{}

function F16CBL50CommandGenerator:new(o)
    --o = BaseCommandGenerator:new()
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    -- self.
    return o
end

function F16CBL50CommandGenerator:getAircraftName()
    return "Ka-50_3"
end

function F16CBL50CommandGenerator:getMaximalWaypointCount()
    return 699
end

function F16CBL50CommandGenerator:getMaximalFixPointCount()
    return 0
end

function F16CBL50CommandGenerator:getMaximalTargetPointCount()
    return 0
end

function F16CBL50CommandGenerator:generateCommands(waypoints, fixpoints, targets)
    local commands = {}
    return commands
end

return F16CBL50CommandGenerator