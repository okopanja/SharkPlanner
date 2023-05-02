local Logging = require("SharkPlanner.Utils.Logging")
local inspect = require("SharkPlanner.inspect")
local OverlayWindow = require('OverlayWindow')
local OverlayWidget = require('OverlayWidget')
local Button = require('Button')

function createTransparentWindow()
  local window = Window.new()
  window:setSize(800,600)
  window:setVisible(true)
  local widget = OverlayWidget.new()
  window:insertWidget(widget, 1)
  widget:setBounds(0,0, 800,600)
  widget:setZIndex(100)
  widget:setVisible(true)

  local color = {r = 1.0, g = 0.0, b = 0.0, a = 1.0}
  --color = {1.0, 0.0, 0.0, 1.0}
  color = "0xffffffff"
  local line = widget:addLine(0,0,800,600, color)
  local line2 = widget:addVertLine(200, color)
  widget:setLineDistance(line, 0)
  widget:addCaption("Hello world!", 20, 20, color, color)
  -- Logging.info(inspect(line:getColor()))
  return window
end

local function experiment()
  local name = "GetTerrainConfig(Airdromes)"
  local filePath = lfs.writedir().."Logs\\Experiments\\terrain\\"..name..".dump.lua"
  Logging.info("Filepath: "..filePath)
  local fp = io.open(filePath, "wb")
  local result = terrain.GetTerrainConfig('Airdromes')
  fp:write(inspect(result))
  fp:close()

  name = "getRunwayList(Tbilisi.roadnet)"
  filePath = lfs.writedir().."Logs\\Experiments\\terrain\\"..name..".dump.lua"
  local runwayList = terrain.getRunwayList(result[29].roadnet)
  fp = io.open(filePath, "wb")
  fp:write(inspect(runwayList))
  fp:close()

  local cameraPosition = Export.LoGetCameraPosition()
  local x = cameraPosition['p']['x']
  local z = cameraPosition['p']['z']

  Logging.info("X: "..x.." Y: "..z)
  local object = terrain.getObjectsAtMapPoint(x, z)
  if object ~= nil then
    name = "getObjectsAtMapPoint(building)"
    filePath = lfs.writedir().."Logs\\Experiments\\terrain\\"..name..".dump.lua"
    fp = io.open(filePath, "wb")
    fp:write(inspect(object))
    fp:close()
  else
    Logging.info("Inspection did not find object")
  end
  
  -- result = terrain.FindOptimalPath("roads", -5533.3186035156, 294686.421875, x, z)
  local path = terrain.FindOptimalPath(-5533.3186035156, 294686.421875, x, z)
  if path ~= nil then
    name = "FindOptimalPath(points)"
    filePath = lfs.writedir().."Logs\\Experiments\\terrain\\"..name..".dump.lua"
    fp = io.open(filePath, "wb")
    fp:write(inspect(path))
    fp:close()  
  end
  Logging.info(tostring(result))
  local window = createTransparentWindow()
  Logging.info("Regular ending")
end

return experiment
