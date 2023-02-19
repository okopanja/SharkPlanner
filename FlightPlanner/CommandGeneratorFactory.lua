if DEBUG_ENABLED ~= true then
  require("FlightPlanner.KA50IIICommandGenerator")
end
local CommandGeneratorFactory = {}

function CommandGeneratorFactory.createGenerator(module)
  if DEBUG_ENABLED == true then
    dofile("C:\\Users\\xxxxxxx\\Saved Games\\DCS.openbeta\\Scripts\\FlightPlanner\\KA50IIICommandGenerator.lua")
  end
  if module == 'Ka-50_3' then
    return KA50IIICommandGenerator:new{}
  end
  return nil
end

return CommandGeneratorFactory
