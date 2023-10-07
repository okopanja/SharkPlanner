local Logging = require("SharkPlanner.Utils.Logging")


local function unloadPackage(package_name)
  package[package_name] = nil
  package.loaded[package_name] = nil
  _G[package_name] = nil
end

local function experiment(context)
  local packageName = "Sharkplanner.Modules.MyModule.MyModuleCommandGenerator"
  Logging.info("Unloading module: "..packageName)
  unloadPackage(packageName)
  Logging.info("Loading module: "..packageName)
  local MyModuleCommandGenerator = require(packageName)
  Logging.info("Loaded module: "..packageName)
  context.controlWindow.commandGenerator = MyModuleCommandGenerator:new{}
  Logging.info("Reference to currrnet command generator replaced")
end

return experiment
