local Logging = require("SharkPlanner.Utils.Logging")
local Table = require("SharkPlanner.Utils.Table")

local BaseInputActionProcessor = {}
local Actions = {
    PlaneSelecterHorizontal,
	PlaneSelecterVertical,
	PlaneSelecterHorizontalAbs,
	PlaneSelecterVerticalAbs,
}

BaseInputActionProcessor.PositionCompResult = PositionCompResult

function BaseInputActionProcessor:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    o.Keys = {}
    o.DeviceCommands = {}
    o.monitoredActions = {}
    return o
end

function BaseInputActionProcessor:getDeviceEventName(inputAction)
    for name, value in pairs(self.Keys) do
        if inputAction.action == value then
            return name
        end
    end
    return "Unknown: "..tostring(inputAction.action)
end

function BaseInputActionProcessor:process(inputActions)
    Logging.debug("BaseInputActionProcessor: processing actions")
end

function BaseInputActionProcessor:addEventHandler(eventType, object, eventHandler)
    self.eventHandlers[eventType][#self.eventHandlers[eventType] + 1] = { object = object, eventHandler = eventHandler }
end

-- the dispatchEvent for now executes directly the event handlers
function BaseInputActionProcessor:dispatchEvent(eventType, eventArg)
    for k, eventHandlerInfo in pairs(self.eventHandlers[eventType]) do
        eventHandlerInfo.eventHandler(eventHandlerInfo.object, eventArg)
    end
end

return BaseInputActionProcessor