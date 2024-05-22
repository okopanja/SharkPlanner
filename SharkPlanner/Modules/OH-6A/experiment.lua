local Logging = require("SharkPlanner.Utils.Logging")


local function unloadPackage(package_name)
  package[package_name] = nil
  package.loaded[package_name] = nil
  _G[package_name] = nil
end

local function experiment(context)
  local packageName = "Sharkplanner.Modules.OH6A.OH6ACommandGenerator"
  Logging.info("Unloading module: "..packageName)
  unloadPackage(packageName)
  unloadPackage("SharkPlanner.Modules.DeadReckoning.DeadReckoningCommandGenerator")
  Logging.info("Loading module: "..packageName)
  local OH6ACommandGenerator = require(packageName)
  Logging.info("Loaded module: "..packageName)
  context.controlWindow.commandGenerator = OH6ACommandGenerator:new{}
  Logging.info("Reference to currrnet command generator replaced")
end

return experiment
