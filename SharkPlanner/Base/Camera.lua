local Logging = require("SharkPlanner.Utils.Logging")
local Table = require("SharkPlanner.Utils.Table")

-- local inspect = require("SharkPlanner.inspect")
local Camera = {}

local EventTypes = {
    CameraMoved = 1
}

Camera.EventTypes = EventTypes

local CameraState = {
    Unknown = 0,
    InMapView = 1,
    InGame = 2,
}

Camera.CameraState = CameraState

local PositionCompResult = {
    Invalid = -1,
    Unchanged = 0,
    PositionChanged = 1,
    OrientationChanged = 2,
    PositionAndOrientationChanged = 3,
}

Camera.PositionCompResult = PositionCompResult

function Camera:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    o.position = nil
    o.state = CameraState.Unknown
    o.eventHandlers = {
        [EventTypes.CameraMoved] = {},
    }
    o.objectDetection = true
    return o
end

function Camera:update()
    local currentCameraPosition = Export.LoGetCameraPosition()
    self.state = self:determineState(currentCameraPosition)
    if self.position ~= nil then
        local comparison_result = self:comparePositions(self.position, currentCameraPosition)
        -- return w['x']['x'] == 0 and w['x']['y'] == -1 and w['x']['z'] == 0 and w['y']['x'] == 1 and w['y']['y'] == 0 and w['y']['z'] == 0 and w['z']['x'] == 0 and w['z']['y'] == 0 and w['z']['z'] == 1
        -- dispatch CameraMoved if camera was moved
        if comparison_result == PositionCompResult.PositionChanged or comparison_result == PositionCompResult.PositionAndOrientationChanged then
            local eventArgs = {
                oldPosition = self.position,
                newPosition = currentCameraPosition,
                cameraState = self.state,
                objects = {}
            }
            if self:getObjectDetection() then
                local foundObjects = terrain.getObjectsAtMapPoint(currentCameraPosition['p']['x'], currentCameraPosition['p']['z']) 
                if foundObjects ~= nil and #foundObjects > 0 then
                    eventArgs.objects = foundObjects
                end
            end
            self:dispatchEvent(EventTypes.CameraMoved, eventArgs)
        end
    end
    self.position = currentCameraPosition
end

function Camera:determineState(position)
    local result_state = CameraState.Unknown
    if position == nil then
        return result_state
    end
    if position['x']['x'] == 0 and position['x']['y'] == -1 and position['x']['z'] == 0 and
       position['y']['x'] == 1 and position['y']['y'] == 0 and position['y']['z'] == 0 and
       position['z']['x'] == 0 and position['z']['y'] == 0 and position['z']['z'] == 1 then
        result_state = CameraState.InMapView
    else
        result_state = CameraState.InGame
    end
    return result_state
end

function Camera:getState()
    return self.state
end

function Camera:getObjectDetection()
    return self.objectDetection
end

function Camera:setObjectDetection(objectDetection)
    self.objectDetection = objectDetection
end

function Camera:comparePositions(pos1, pos2)
    if (pos1 == nil and pos2 ~= nil) or (pos2 == nil and pos1 ~= nil) then
        return PositionCompResult.Invalid
    end
    local comparison_result = PositionCompResult.Unchanged
    -- check if position changed
    if pos1.p.x ~= pos2.p.x or pos1.p.y ~= pos2.p.y or pos1.p.z ~= pos2.p.z then
        comparison_result = comparison_result + PositionCompResult.PositionChanged
    end
    -- check if orientation changed
    if
        pos1.x.x ~= pos2.x.x or pos1.x.y ~= pos2.x.y or pos1.x.z ~= pos2.x.z or
        pos1.y.x ~= pos2.y.x or pos1.y.y ~= pos2.y.y or pos1.y.z ~= pos2.y.z or
        pos1.z.x ~= pos2.z.x or pos1.z.y ~= pos2.z.y or pos1.z.z ~= pos2.z.z
    then
        comparison_result = comparison_result + PositionCompResult.OrientationChanged
    end
    return comparison_result
end

function Camera:addEventHandler(eventType, object, eventHandler)
    self.eventHandlers[eventType][#self.eventHandlers[eventType] + 1] = { object = object, eventHandler = eventHandler }
end

-- the dispatchEvent for now executes directly the event handlers
function Camera:dispatchEvent(eventType, eventArg)
    for k, eventHandlerInfo in pairs(self.eventHandlers[eventType]) do
        eventHandlerInfo.eventHandler(eventHandlerInfo.object, eventArg)
    end
end

local singleton = Camera:new{}

return singleton