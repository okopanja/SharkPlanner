local Logging = require("SharkPlanner.Utils.Logging")
-- handle lua 5.4 deprecation
if table.unpack == nil then
table.unpack = unpack
end

local CoordinateData = {}
local EventTypes = {
    AddWayPoint = 1,
    RemoveWayPoint = 2,
    AddFixPoint = 3,
    RemoveFixPoint = 4,
    AddTargetPoint = 5,
    RemoveTargetPoint = 6,
    Reset = 7
}
-- make event types visible to users
CoordinateData.EventTypes = EventTypes

function CoordinateData:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    o.wayPoints = {}
    o.fixPoints = {}
    o.targetPoints = {}
    o.eventHandlers = {
        [EventTypes.AddWayPoint] = {},
        [EventTypes.RemoveWayPoint] = {},
        [EventTypes.AddFixPoint] = {},
        [EventTypes.RemoveFixPoint] = {},
        [EventTypes.AddTargetPoint] = {},
        [EventTypes.RemoveTargetPoint] = {},
        [EventTypes.Reset] = {},
    }
    return o
end

function CoordinateData:addWaypoint(wayPoint)
    self.wayPoints[#self.wayPoints + 1] = wayPoint
    local eventArg = {
        wayPoints = self.wayPoints,
        wayPoint = wayPoint,
        wayPointIndex = #self.wayPoints
    }
    self:dispatchEvent(EventTypes.AddWayPoint, eventArg)
end

function CoordinateData:removeWaypoint(wayPointIndex)
    local wayPoint = table.remove(self.wayPoints, wayPointIndex)
    local eventArg = {
        wayPoints = self.wayPoints,
        wayPoint = wayPoint,
        wayPointIndex = wayPointIndex
    }
    self:dispatchEvent(EventTypes.RemoveWayPoint, eventArg)
end

function CoordinateData:addFixpoint(fixPoint)
    self.fixPoints[#self.fixPoints + 1] = fixPoint

    local eventArg = {
        fixPoints = self.fixPoints,
        fixPoint = fixPoint,
        fixPointIndex = #self.fixPoints
    }
    self:dispatchEvent(EventTypes.AddFixPoint, eventArg)
end

function CoordinateData:removeFixpoint(fixPointIndex)
    local fixPoint = table.remove(self.fixPoints, fixPointIndex)
    local eventArg = {
        fixPoints = self.fixPoints,
        fixPoint = fixPoint,
        fixPointIndex = fixPointIndex
    }
    self:dispatchEvent(EventTypes.RemoveFixPoint, eventArg)
end

function CoordinateData:addTargetpoint(targetPoint)
    self.targetPoints[#self.targetPoints + 1] = targetPoint

    local eventArg = {
        targetPoints = self.targetPoints,
        targetPoint = targetPoint,
        targetPointIndex = #self.targetPoints
    }
    self:dispatchEvent(EventTypes.AddTargetPoint, eventArg)
end

function CoordinateData:removeTargetpoint(targetPointIndex)
    local targetPoint = table.remove(self.targetPoints, targetPointIndex)
    local eventArg = {
        targetPoints = self.targetPoints,
        targetPoint = targetPoint,
        targetPointIndex = targetPointIndex
    }
    self:dispatchEvent(EventTypes.RemoveTargetPoint, eventArg)
end


function CoordinateData:reset()
    self.wayPoints = {}
    self.fixPoints = {}
    self.targetPoints = {}
    local eventArg = {
        -- at the moment no actual need, but still needed for generic dispatchEvent method
        -- reserved for future use
    }
    self:dispatchEvent(EventTypes.Reset, eventArg)
end

function CoordinateData:addEventHandler(eventType, object, eventHandler)
    self.eventHandlers[eventType][#self.eventHandlers[eventType] + 1] = { object = object, eventHandler = eventHandler }
end

-- the dispatchEvent for now executes directly the event handlers
function CoordinateData:dispatchEvent(eventType, eventArg)
    for k, eventHandlerInfo in pairs(self.eventHandlers[eventType]) do
        eventHandlerInfo.eventHandler(eventHandlerInfo.object, eventArg)
    end
end

function CoordinateData:normalize(commandGenerator)
    Logging.info("Normalizing data structures")
    -- no commandGenerator nothing to do
    if commandGenerator == nil then return end
    -- trim number of waypoints
    Logging.info("Setting correct structure size")
    if #self.wayPoints > commandGenerator:getMaximalWaypointCount() then
        Logging.info("Prunning waypoints from "..#self.wayPoints.." to "..commandGenerator:getMaximalWaypointCount())        
        -- self.wayPoints = { table.unpack(self.wayPoints, 1, math.min(#self.wayPoints, commandGenerator:getMaximalWaypointCount())) }
        for i = #self.wayPoints, commandGenerator:getMaximalWaypointCount() + 1, -1 do
            self:removeWaypoint(i)
        end
        Logging.info("Result: "..#self.wayPoints)
    end
    if #self.fixPoints > commandGenerator:getMaximalFixPointCount() then
        Logging.info("Prunning fixpoints...")
        -- self.fixPoints = { table.unpack(self.fixPoints, 1, math.min(#self.fixPoints, commandGenerator:getMaximalFixPointCount())) }
        for i = #self.fixPoints, commandGenerator:getMaximalFixPointCount() + 1, -1 do
            self:removeFixpoint(i)
        end
        Logging.info("Result: "..#self.fixPoints)
    end
    if #self.targetPoints > commandGenerator:getMaximalTargetPointCount() then
        Logging.info("Prunning target points...")
        -- self.targetPoints = { table.unpack(self.targetPoints, 1, math.min(#self.targetPoints, commandGenerator:getMaximalTargetPointCount())) }
        for i = #self.targetPoints, commandGenerator:getMaximalTargetPointCount() + 1, -1 do
            self:removeTargetpoint(i)
        end
        Logging.info("Result: "..#self.targetPoints)
    end
end

-- Singleton
return CoordinateData:new{}

