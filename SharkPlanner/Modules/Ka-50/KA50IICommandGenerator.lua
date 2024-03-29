local Logging = require("SharkPlanner.Utils.Logging")
local KA50IIICommandGenerator = require("SharkPlanner.Modules.Ka-50.KA50IIICommandGenerator")
local Position = require("SharkPlanner.Base.Position")

KA50IICommandGenerator = KA50IIICommandGenerator:new()

function KA50IICommandGenerator:getAircraftName()
  return "Ka-50"
end

function KA50IICommandGenerator:_determineNumberOfModePresses()
  local mode = Export.GetDevice(9):get_mode()
  mode = tostring(mode.master)..tostring(mode.level_2)..tostring(mode.level_3)..tostring(mode.level_4)
  if mode == "0000" then
    return 0
  elseif mode == "5000" then
    return 3
  elseif mode == "5500" then
    return 2
  elseif mode == "5100" then
    return 1
  elseif mode == "5400" then
    return 4
  elseif mode == "5310" then
    return 4
  elseif mode == "5200" then
    return 4
  elseif mode == "5430" then
    return 4
  elseif mode == "5240" then
    return 4
  elseif self:starts_with(mode,"5") then
    return 3
  end
  -- Logging.info("ABRIS Mode: "..mode)
  return 4
end

function KA50IICommandGenerator:abrisWorkaroundInitialSNSDrift(commands, selfX, selfZ)
  Logging.info("abrisWorkaroundInitialSNSDrift, zoom level: "..self.zoomLevel)

  local dummyRoute = {}
  dummyRoute[#dummyRoute + 1] = Position:new{x = selfX, y = 0, z = selfZ, longitude = 0, latitude = 0 }
  Logging.info("Before abrisUnloadRoute, zoom level: "..self.zoomLevel)
  self:abrisUnloadRoute(commands)
  Logging.info("Before abrisStartRouteEntry, zoom level: "..self.zoomLevel)
  self:abrisStartRouteEntry(commands)
  Logging.info("Before abrisEnterRouteWaypoints, zoom level: "..self.zoomLevel)
  self:abrisEnterRouteWaypoints(commands, dummyRoute, selfX, selfZ)
  Logging.info("Before abrisCompleteRouteEntry, zoom level: "..self.zoomLevel)
  self:abrisCompleteRouteEntry(commands)
  for i = 1, 3 do
    self:abrisPressButton5(commands, "Cycle mode")
  end
end

return KA50IICommandGenerator