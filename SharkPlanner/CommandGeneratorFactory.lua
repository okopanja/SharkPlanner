CommandGeneratorFactory = {}

if DEBUG_ENABLED ~= true then
  net.log("Debug mode is disabled")
  require("SharkPlanner.KA50IIICommandGenerator")
  require("SharkPlanner.KA50IICommandGenerator")
  -- Declare the module name and the corresponding command generator
  CommandGeneratorFactory.supported = {}
  CommandGeneratorFactory.supported["Ka-50_3"] = KA50IIICommandGenerator
  CommandGeneratorFactory.supported["Ka-50_3 2011"] = KA50IICommandGenerator
  CommandGeneratorFactory.supported["Ka-50"] = KA50IICommandGenerator

end

function CommandGeneratorFactory.getCurrentAirframe()
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
end

function CommandGeneratorFactory.isSupported(name)
  if DEBUG_ENABLED == true then
    net.log("Debug mode is enabled")
    dofile(lfs.writedir().."Scripts\\SharkPlanner\\KA50IIICommandGenerator.lua")
    dofile(lfs.writedir().."Scripts\\SharkPlanner\\KA50IICommandGenerator.lua")
    CommandGeneratorFactory.supported = {}
    CommandGeneratorFactory.supported["Ka-50_3"] = KA50IIICommandGenerator
    CommandGeneratorFactory.supported["Ka-50_3 2011"] = KA50IICommandGenerator
    CommandGeneratorFactory.supported["Ka-50"] = KA50IICommandGenerator
  end
  for k, v in pairs(CommandGeneratorFactory.supported) do
    if k == name then
      return true
    end
  end
  return false
end

function CommandGeneratorFactory.createGenerator(module)
  for k, v in pairs(CommandGeneratorFactory.supported) do
    if k == module then
      return v:new{}
    end
  end
  return nil
end

return CommandGeneratorFactory
