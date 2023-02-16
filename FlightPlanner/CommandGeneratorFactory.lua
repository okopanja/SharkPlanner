require("FlightPlanner.KA50IIICommandGenerator")

local CommandGeneratorFactory = {}

function CommandGeneratorFactory.createGenerator(module)
  if module == 'Ka-50_3' then
    return KA50IIICommandGenerator:new()
  end
  return nil
end

return CommandGeneratorFactory
