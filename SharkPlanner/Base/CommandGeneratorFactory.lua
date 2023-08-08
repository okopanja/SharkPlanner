local Logging = require("SharkPlanner.Utils.Logging")
local String = require("SharkPlanner.Utils.String")
local GameState = require("SharkPlanner.Base.GameState")
local Configuration = require("SharkPlanner.Base.Configuration")
local CommandGeneratorFactory = {}

-- helper function to read list of subfolders of modules
local function getListOfModules()
  local result = {}
  local path = lfs.writedir().."Scripts\\SharkPlanner\\Modules"
  for file in lfs.dir(path) do
    local full_path = path.."\\"..file
    if lfs.attributes(full_path, "mode") == "directory" then
      if file ~= '.' and file ~= '..' then
        result[file] = "SharkPlanner.Modules."..file
      end
    end
  end
  return result
end

-- function to reload the modules
function CommandGeneratorFactory.reload()
  -- clear list of supported variants
  CommandGeneratorFactory.supported = {}
  -- unload the packages belonging to modules
  for k, v in pairs(package.loaded) do
      if String.starts_with(k, "SharkPlanner.Modules.") then
        package[k] = nil
      end
  end
  -- prepare list of determineVariant functions
  CommandGeneratorFactory.variantLookupFunctions = {}
  -- rediscover modules
  local module_list = getListOfModules()
  -- for each module register variants
  for module_name, module_full_path in pairs(module_list) do
    Logging.info("Loading: "..module_full_path)
    local module = require(module_full_path)
    Configuration:setConfigurationDefinition(module_name, module.getConfigurationDefinition())
    CommandGeneratorFactory.variantLookupFunctions[module_name] = module.determineVariant
    local module_command_generators = module.getCommandGenerators()
    for variant, command_generator in pairs(module_command_generators) do
      Logging.info("Registering generator for: "..variant)
      CommandGeneratorFactory.supported[variant] = command_generator
    end
  end
end

-- returns current airframe, the function searches through all modules
function CommandGeneratorFactory.getCurrentAirframe()
  local default_variant = nil
  local selfData = Export.LoGetSelfData()

  if selfData == nil then 
    if GameState.getGameState() == GameState.States.MultiplayerSimulationActive then
      default_variant = "Combined Arms"
    end
  else
    default_variant = selfData["Name"]
  end

  local variant = nil
  for module_name, determineVariant in pairs(CommandGeneratorFactory.variantLookupFunctions) do
    variant = determineVariant(default_variant)
    if variant ~= nil then
      break
    end
  end
  if variant ~= nil then
    return variant
  end
  return default_variant
end

-- check if it is supported
function CommandGeneratorFactory.isSupported(name)
  Logging.info("Checking for support for: "..tostring(name))
  for k, v in pairs(CommandGeneratorFactory.supported) do
    if k == name then
      return true
    end
  end
  return false
end

--create generator for supported module
function CommandGeneratorFactory.createGenerator(module)
  Logging.info("Creating generator for: "..module)
  for k, v in pairs(CommandGeneratorFactory.supported) do
    if k == module then
      return v:new{}
    end
  end
  return nil
end

-- load modules
CommandGeneratorFactory.reload()

return CommandGeneratorFactory
