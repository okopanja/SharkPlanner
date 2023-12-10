local Logging = require("SharkPlanner.Utils.Logging")
local inspect = require("SharkPlanner.inspect")

local Camera = {}

local EventTypes = {
    CameraMoved = 1,
    CameraInF10 = 2,
    CameraInGame = 3,
}

Camera.EventTypes = EventTypes

local PositionCompResult = {
    Unchanged = 1,
    PositionChanged = 2,
    DirectionChanged = 3,
    PositionAndDirectionChanged = 4,
}

Camera.PositionCompResult = PositionCompResult

function Camera:new (o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    o.position = nil
    o.eventHandlers = {
        [EventTypes.CameraMoved] = {},
        [EventTypes.CameraInF10] = {},
        [EventTypes.CameraInGame] = {},
      }
    return o
end

function Camera:update()
    local currentCameraPosition = Export.LoGetCameraPosition()
    -- Logging.info(inspect(currentCameraPosition))
    local eventArg = {
    }
    Camera.dispatchEvent(EventTypes.TransferStarted, eventArg)

    self.position = currentCameraPosition
end

function Camera:comparePositions(pos1, pos2)
    if (pos1 == nil and pos2 ~= nil) or (pos2 == nil and pos1 ~= nil) then
        
    end
    return PositionCompResult.Unchanged
end

function Camera.addEventHandler(eventType, object, eventHandler)
    Camera.eventHandlers[eventType][#Camera.eventHandlers[eventType] + 1] = { object = object, eventHandler = eventHandler }
end

-- the dispatchEvent for now executes directly the event handlers
function Camera.dispatchEvent(eventType, eventArg)
    for k, eventHandlerInfo in pairs(Camera.eventHandlers[eventType]) do
        eventHandlerInfo.eventHandler(eventHandlerInfo.object, eventArg)
    end
end

return Camera