
local function loadSharkPlanner()
  local lfs = require("lfs")
  package.path = package.path .. lfs.writedir() .. "Scripts\\?\\init.lua;"
  local SharkPlanner = require("SharkPlanner")
  -- local FileDialog = require("FileDialog")
end

local status, err = pcall(loadSharkPlanner)
if not status then
  net.log("[SharkPlanner] load error: " .. tostring(err))
end
