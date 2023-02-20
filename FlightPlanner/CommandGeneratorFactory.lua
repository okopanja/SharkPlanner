if DEBUG_ENABLED ~= true then
  net.log("Debug mode is disabled")
  require("FlightPlanner.KA50IIICommandGenerator")
  require("FlightPlanner.KA50IICommandGenerator")
end

local CommandGeneratorFactory = {}

-- Declare the module name and the corresponding command generator
CommandGeneratorFactory.supported = {
  "Ka-50_3" = KA50IIICommandGenerator,
  "Ka-50_3 2011" = KA50IICommandGenerator,
  "Ka-50" = KA50IICommandGenerator
}

function getCurrentAirframe() {
  local selfData = Export.LoGetSelfData()
  local moduleName = nil

  if selfData ~= nil then
    moduleName = selfData["Name"]
    -- BS3 needs special handling due to 2022 and 2011 version. The differnce is established by absenence of device 64.
    if moduleName == "Ka-50_3" and Export.GetDevice(64) == nil then
      -- Allocate new distinctive name for 2011 version
      moduleName = moduleName.." 2011"
    end
  end
 
  return moduleName 
}

function CommandGeneratorFactory.createGenerator(module)
  if DEBUG_ENABLED == true then
    net.log("Debug mode is enabled")
    dofile(lfs.writedir().."Scripts\\FlightPlanner\\KA50IIICommandGenerator.lua")
    dofile(lfs.writedir().."Scripts\\FlightPlanner\\KA50IICommandGenerator.lua")
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
