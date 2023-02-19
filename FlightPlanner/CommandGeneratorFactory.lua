if DEBUG_ENABLED ~= true then
  net.log("Debug mode is disabled")
  require("FlightPlanner.KA50IIICommandGenerator")
end
local CommandGeneratorFactory = {}

function CommandGeneratorFactory.createGenerator(module)
  if DEBUG_ENABLED == true then
    net.log("Debug mode is enabled")
    dofile(lfs.writedir().."Scripts\\FlightPlanner\\KA50IIICommandGenerator.lua")
  end
  if module == 'Ka-50_3' then
    return KA50IIICommandGenerator:new{}
  end
  return nil
end

return CommandGeneratorFactory
