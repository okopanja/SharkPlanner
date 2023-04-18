Command = {}

function Command:new (o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  self.name = "UnknownDevice: Unknown command"
  self.comment = nil
  self.schedule = nil
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
