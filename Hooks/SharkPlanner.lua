local function loadSharkPlanner()
  local lfs = require("lfs")
  -- local FileDialog = require("FileDialog")
  package.path = package.path .. lfs.writedir() .. "Scripts\\?\\init.lua"
  local SharkPlanner = require("SharkPlanner")
end

local status, err = pcall(loadSharkPlanner)
if not status then
  net.log("[SharkPlanner] load error: " .. tostring(err))
end
