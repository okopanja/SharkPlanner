package.path = package.path .. lfs.writedir() .. "Scripts\\?\\init.lua;"
local Logging = require("SharkPlanner.Utils.Logging")

local function loadSharkPlanner()
  local lfs = require("lfs")
  local SharkPlanner = require("SharkPlanner")
end

local status, err = pcall(loadSharkPlanner)
if not status then
  Logging.error("Load error: "..tostring(err))
end
