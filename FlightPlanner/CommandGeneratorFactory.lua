if DEBUG_ENABLED ~= true then
  net.log("Debug mode is disabled")
  require("FlightPlanner.KA50IIICommandGenerator")
  require("FlightPlanner.KA50IICommandGenerator")
end
local CommandGeneratorFactory = {}

function CommandGeneratorFactory.createGenerator(module)
  if DEBUG_ENABLED == true then
    net.log("Debug mode is enabled")
    dofile(lfs.writedir().."Scripts\\FlightPlanner\\KA50IIICommandGenerator.lua")
  end
  if module == 'Ka-50_3' then
    local device = Export.GetDevice(64)
    if device ~= nil then
      net.log("Ka-50_3 version 2022 detected")
      return KA50IIICommandGenerator:new{}
    else
      net.log("Ka-50_3 version 2011 detected")
      return KA50IICommandGenerator:new{}
    end
  elseif module == "Ka-50" then
    net.log("Ka-50 BS2 detected")
    return KA50IICommandGenerator:new{}
  end
  return nil
end

return CommandGeneratorFactory
