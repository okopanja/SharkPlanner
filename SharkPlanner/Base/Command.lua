local Command = {}

function Command:new (o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  o.name = "UnknownDevice: Unknown command"
  o.comment = nil
  o.schedule = nil
  o.intensityUpdateCallback = nil
  o.intensityUpdateObject = nil
  return o
end

function Command:getDevice()
  return self.device
end

function Command:setDevice(device)
  self.device = device
  return self
end

function Command:getCode()
  return self.code
end

function Command:setCode(code)
  self.code = code
  return self
end

function Command:getDelay()
  return self.delay
end

function Command:setDelay(delay)
  self.delay = delay
  self.schedule = nil
  return self
end

function Command:getSchedule()
  return self.schedule
end

function Command:setSchedule(schedule)
  self.schedule = schedule
  return self
end

function Command:getIntensity()
  return self.intensity
end

function Command:setIntensity(intensity)
  self.intensity = intensity
  return self
end

function Command:getDepress()
  return self.depress
end

function Command:setDepress(depress)
  self.depress = depress
  return self
end

function Command:getName()
  return self.name
end

function Command:setName(name)
  self.name = name
  return self
end

function Command:getComment()
  return self.comment
end

function Command:setComment(comment)
  self.comment = comment
  return self
end

-- this function is used to update command intensity of command when intensity can not be calculated accuratly at the time of creation, but only later prior to immidiate command execution.
-- as parameters it takes:
-- recipient object (can be nil)
-- intensityUpdateCallback
-- updateParameters: table containing static parameters needed for update
function Command:setIntensityUpdateCallback(object, intensityUpdateCallback, updateParameters)
  self.intensityUpdateObject = object
  self.intensityUpdateCallback = intensityUpdateCallback
  self.updateParameters = updateParameters
  return self
end

-- this function is used to update command when command execution conditions can not be calculated accuratly at the time of creation, but only later prior to immidiate command execution.
-- as parameters it takes:
-- recipient object (can be nil), normally this is instance of BaseCommandGenerator or one of derived classes
-- updateCallback
-- updateParameters: table containing static parameters needed for update
function Command:setUpdateCallback(object, updateCallback, updateParameters)
  self.updateObject = object
  self.updateCallback = updateCallback
  self.updateParameters = updateParameters
  return self
end

function Command:update(remainingCommands)
  if self.updateCallback ~= nil then
    if self.updateObject ~= nil then
      return self.updateCallback(self.updateObject, self, self.updateParameters, remainingCommands)
    else
      return self.updateCallback(self, self.updateParameters, remainingCommands)
    end
  end
end

function Command:getText()
  local text = self.name
  if self.comment ~= nil then
    text = text.." ("..self.comment..")"
  end
  if self.device ~= nil then
    text = text..", \n\tDevice: "..self.device
  end
  if self.code ~= nil then
    text = text..", \n\tCode: "..self.code
  end
  if self.delay ~= nil then
    text = text..", \n\tDelay: "..self.delay
  end
  if self.intensity ~= nil then
    text = text..", \n\tIntensity: "..self.intensity
  end
  text = text..", \n\tDepress: "..tostring(self.depress)
  if self.schedule ~= nil then
    text = text..", \n\tSchedule: "..self.schedule
  end
  return text
end

return Command
