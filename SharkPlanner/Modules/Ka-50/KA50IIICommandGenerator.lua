local Logging = require("SharkPlanner.Utils.Logging")
local BaseCommandGenerator = require("SharkPlanner.Base.BaseCommandGenerator")
local Command = require("SharkPlanner.Base.Command")
local Position = require("SharkPlanner.Base.Position")
local ABRISZoomRange = require("SharkPlanner.Modules.Ka-50.ABRISZoomRange")
require("math")

local default_delay = 100 -- default delay in ms


KA50IIICommandGenerator = BaseCommandGenerator:new()
-- zoom depress delay
KA50IIICommandGenerator.DELAY_ABRIS_ZOOM = 40
-- pause made during waypoint entry (should allow ABRIS to settle down)
KA50IIICommandGenerator.DELAY_ABRIS_SETTLE = 0
-- rotation depress delay
KA50IIICommandGenerator.DELAY_ABRIS_ROTATE = 100

function KA50IIICommandGenerator:new(o)
  --o = BaseCommandGenerator:new()
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  -- self.
  self._ranges = {
    ABRISZoomRange:new{level = 0, range =     150},
    ABRISZoomRange:new{level = 1, range =     200},
    ABRISZoomRange:new{level = 2, range =     250},
    ABRISZoomRange:new{level = 3, range =     300},
    ABRISZoomRange:new{level = 4, range =     500},
    ABRISZoomRange:new{level = 5, range =     600},
    ABRISZoomRange:new{level = 6, range =     750},
    ABRISZoomRange:new{level = 7, range =    1000},
    ABRISZoomRange:new{level = 8, range =    1250},
    ABRISZoomRange:new{level = 9, range =    1500},
    ABRISZoomRange:new{level = 10, range =   2000},
    ABRISZoomRange:new{level = 11, range =   2500},
    ABRISZoomRange:new{level = 12, range =   3000},
    ABRISZoomRange:new{level = 13, range =   4000},
    ABRISZoomRange:new{level = 14, range =   5000},
    ABRISZoomRange:new{level = 15, range =   6000},
    ABRISZoomRange:new{level = 16, range =   7500},
    ABRISZoomRange:new{level = 17, range =  10000},
    ABRISZoomRange:new{level = 18, range =  12500},
    ABRISZoomRange:new{level = 19, range =  15000},
    ABRISZoomRange:new{level = 20, range =  20000},
    ABRISZoomRange:new{level = 21, range =  25000},
    ABRISZoomRange:new{level = 22, range =  30000},
    ABRISZoomRange:new{level = 23, range =  40000},
    ABRISZoomRange:new{level = 24, range =  50000},
    ABRISZoomRange:new{level = 25, range = 100000}
  }
  self.zoomLevel = 10
  return o
end

function KA50IIICommandGenerator:getAircraftName()
  return "Ka-50_3"
end

function KA50IIICommandGenerator:getMaximalWaypointCount()
  return 6
end

function KA50IIICommandGenerator:getMaximalFixPointCount()
  return 10
end

function KA50IIICommandGenerator:getMaximalTargetPointCount()
  return 10
end

function KA50IIICommandGenerator:generateCommands(waypoints, fixpoints, targets)
  local commands = {}
  local mode = Export.GetDevice(9):get_mode()
  mode = tostring(mode.master)..tostring(mode.level_2)..tostring(mode.level_3)..tostring(mode.level_4)
  Logging.info("ABRIS mode: "..mode)
  if #waypoints > 0 then
    self:prepareABRISCommands(commands, waypoints)
  end
    self:preparePVI800Commands(commands, waypoints, fixpoints, targets)
  return commands
end

-- main function for PVI commands
function KA50IIICommandGenerator:preparePVI800Commands(commands, waypoints, fixpoints, targets)
  -- cycle waypoint, fixpoints, airports (to ensure proper mode), then select waypoint 1
  self:pvi800PressWaypointBtn(commands)
  self:pvi800PressFixpointBtn(commands)
  self:pvi800PressAirfieldBtn(commands)
  self:pvi800PressNavTargetBtn(commands)
  self:pvi800PressWaypointBtn(commands)
  self:pvi800PressDigitBtn(commands, 1, "Waypoint: 1")
  -- entry of waypoints positions
  self:pvi800SwitchToEntryMode(commands)
  -- enter waypoints if any
  if #waypoints > 0 then
    self:pvi800PressWaypointBtn(commands)
    self:pvi800EnterPositions(commands, waypoints)
  end
  -- enter fixpoints if any
  if #fixpoints > 0 then
    self:pvi800PressFixpointBtn(commands)
    self:pvi800EnterPositions(commands, fixpoints)
  end
  -- enter targets if any
  if #targets > 0 then
    self:pvi800PressNavTargetBtn(commands)
    self:pvi800EnterPositions(commands, targets)
  end
  -- switch to operation mode
  self:pvi800SwitchToOperMode(commands)
  -- enter route consisting of previosly entered waypoints
  for digit, waypoint in pairs(waypoints) do
    self:pvi800PressDigitBtn(commands, digit, "Waypoint: "..digit)
    self:pvi800PressEnterBtn(commands)
  end
  -- self:pvi800PressDigitBtn(commands, 1, "Activate waypoint 1")
  self:pvi800PressDigitBtn(commands, 1, "Activate waypoint 1")
  self:pvi800PressWaypointBtn(commands)
  if #waypoints < 6 then
    self:pvi800PressWaypointBtn(commands)
  end
  self:pvi800PressDigitBtn(commands, 1, "Activate waypoint 1")
end

function KA50IIICommandGenerator:pvi800EnterPositions(commands, positions)
  for digit, position in pairs(positions) do
    -- select waypoint number
    self:pvi800PressDigitBtn(commands, digit, "Position: "..digit)
    -- enter lat hemisphere
    self:pvi800PressDigitBtn(commands, position:getLatitudeHemisphere(), "Latitude Hemisphere")
    -- enter latitude
    local latitude_digits = self:_getLatitudeDigits(position:getLatitudeDMDec())
    for pos, digit in pairs(latitude_digits) do
      self:pvi800PressDigitBtn(commands, digit, "Latitude digit: "..digit)
    end
    -- enter long hemisphere
    self:pvi800PressDigitBtn(commands, position:getLongitudeHemisphere(), "Longitude Hemisphere")
    -- enter longitude
    local longitude_digits = self:_getLongitudeDigits(position:getLongitudeDMDec())
    for pos, digit in pairs(longitude_digits) do
      self:pvi800PressDigitBtn(commands, digit, "Latitude digit: "..digit)
    end
    -- complete navpoint entry
    self:pvi800PressEnterBtn(commands)
  end
end

-- utility functions for PVI-800
function KA50IIICommandGenerator:pvi800SwitchToEntryMode(commands)
  commands[#commands + 1] = Command:new():setName("PVI-800: switch to Entry mode"):setDevice(20):setCode(3026):setDelay(default_delay):setIntensity(0.2):setDepress(false)
end

function KA50IIICommandGenerator:pvi800SwitchToOperMode(commands)
  commands[#commands + 1] = Command:new():setName("PVI-800: switch to Oper mode"):setDevice(20):setCode(3026):setDelay(default_delay):setIntensity(0.3):setDepress(false)
end

function KA50IIICommandGenerator:pvi800PressWaypointBtn(commands)
  commands[#commands + 1] = Command:new():setName("PVI-800: press Waypoint button"):setDevice(20):setCode(3011):setDelay(default_delay):setIntensity(1):setDepress(true)
end

function KA50IIICommandGenerator:pvi800PressFixpointBtn(commands)
  commands[#commands + 1] = Command:new():setName("PVI-800: press Waypoint button"):setDevice(20):setCode(3013):setDelay(default_delay):setIntensity(1):setDepress(true)
end

function KA50IIICommandGenerator:pvi800PressAirfieldBtn(commands)
  commands[#commands + 1] = Command:new():setName("PVI-800: press Waypoint button"):setDevice(20):setCode(3015):setDelay(default_delay):setIntensity(1):setDepress(true)
end

function KA50IIICommandGenerator:pvi800PressNavTargetBtn(commands)
  commands[#commands + 1] = Command:new():setName("PVI-800: press Waypoint button"):setDevice(20):setCode(3017):setDelay(default_delay):setIntensity(1):setDepress(true)
end

function KA50IIICommandGenerator:pvi800PressEnterBtn(commands)
  commands[#commands + 1] = Command:new():setName("PVI-800: press Enter button"):setDevice(20):setCode(3018):setDelay(default_delay):setIntensity(1):setDepress(true)
end

function KA50IIICommandGenerator:pvi800PressDigitBtn(commands, digit, comment)
  -- ignore out of [0-9] bounds
  if digit < 0 or digit > 9 then
    return
  end
  -- ignore non integer numbers
  if digit ~= math.floor(digit) then
    return
  end
  commands[#commands + 1] = Command:new():setName("PVI-800: press digit "..digit):setComment(comment):setDevice(20):setCode(3001 + digit):setDelay(default_delay):setIntensity(1):setDepress(true)
end

-- Main function for ABRIS
function KA50IIICommandGenerator:prepareABRISCommands(commands, waypoints)
  Logging.info("prepareABRISCommands, zoom level: "..self.zoomLevel)

  -- current location of aircraft is needed for relative entry of waypoints
  local selfData = Export.LoGetSelfData()
  local selfX = selfData["Position"]["x"]
  local selfZ = selfData["Position"]["z"]
  -- Place ABRIS into MENU mode, no matter in which mode it is currently in
  self:abrisCycleToMenuMode(commands)
  Logging.info("abrisCycleToMenuMode, zoom level: "..self.zoomLevel)
  -- Workaround ABRIS/SNS drift (this occurs only on the first usage, but for simplicity we will repeat it every time)
  self:abrisWorkaroundInitialSNSDrift(commands, selfX, selfZ)
  -- Make sure there is no route loaded
  self:abrisUnloadRoute(commands)
  -- Start entering
  self:abrisStartRouteEntry(commands)
  -- Enter waypoints
  self:abrisEnterRouteWaypoints(commands, waypoints, selfX, selfZ)
  -- Complete and store route
  self:abrisCompleteRouteEntry(commands)
end

function KA50IIICommandGenerator:abrisCycleToMenuMode(commands)
  local cycleNumber = self:_determineNumberOfModePresses()
  for i = 1,cycleNumber do
    self:abrisPressButton5(commands, "Cycle mode", nil)
  end
end

function KA50IIICommandGenerator:abrisWorkaroundInitialSNSDrift(commands, selfX, selfZ)
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
  for i = 1, 4 do
    self:abrisPressButton5(commands, "Cycle mode")
  end
end

function KA50IIICommandGenerator:abrisUnloadRoute(commands)
  -- ABRIS: plan mode
  self:abrisPressButton3(commands, "Plan mode", 0)
  -- ABRIS: activate select menu
  self:abrisPressButton1(commands, "Activate select menu", 0)
  -- ABRIS: select menu move down 2 entries (this will be split into 4 increments of 0.4)
  for i = 1,4 do
    self:abrisRotate(commands, 0.4, "Rotate menu: "..i.."/4")
  end
  -- ABRIS: activate unload option
  self:abrisPressButton1(commands, "Activate unload option", 0)
  -- ABRIS: activate select menu again
  self:abrisPressButton1(commands, "Activate select menu again", 0)
  -- ABRIS: move menu back 2 entries
  for i = 1,4 do
    self:abrisRotate(commands, -0.4, "Rotate menu: "..i.."/4")
  end
  -- ABRIS: now switch to menu mode again
  self:abrisPressButton5(commands, "Switch to main menu", 0)
end

function KA50IIICommandGenerator:abrisStartRouteEntry(commands)
  -- ABRIS: plan mode
  self:abrisPressButton3(commands, "Plan mode", 0)
  -- ABRIS: activate EDIT menu
  self:abrisPressButton2(commands, "activate EDIT menu", 0)
  -- ABRIS: zoom in to maximum to make sure we start with known zoom level 0
  self:abrisFullZoom(commands)
end

function KA50IIICommandGenerator:abrisEnterRouteWaypoints(commands, waypoints, selfX, selfZ)
  Logging.info("abrisEnterRouteWaypoints, zoom level "..self.zoomLevel)
  -- create initial waypoint from current location
  local previous = Position:new{x = selfX, y = 0, z = selfZ, longitude = 0, latitude = 0 }
  -- add waypoints
  for i, waypoint in pairs(waypoints) do
    if i == 1 then
      -- first entry does not require edit/insert command
      self:abrisAddWaypoint(commands, previous, waypoint, false)
    else
      -- other wayppints require edit/insert commands
      self:abrisAddWaypoint(commands, previous, waypoint, true)
    end
    -- allocated current waypoint to priorWaypoint for next iteration
    previous = waypoint
  end
end

function KA50IIICommandGenerator:abrisAddWaypoint(commands, previous, waypoint, isNotFirst)
  -- Calculate deltaX and deltaZ to the prior coordinate
  local deltaX = waypoint:getX() - previous:getX()
  local deltaZ = waypoint:getZ() - previous:getZ()
  -- first waypoint does not need edit/insert
  if isNotFirst then
    self:abrisStartNextWaypoint(commands)
    -- ABRIS: wait for 100ms for ABRIS to settle
    self:nop(commands, "Wait for ABRIS to settle", KA50IIICommandGenerator.DELAY_ABRIS_SETTLE)
  end
  -- determine the smallest bounding Z range
  local range = self:findSmallestBoundingZRange(previous, waypoint)
  Logging.info("Smallest Z range: "..range:getLevel())
  -- ABRIS: zoom to the bounding range
  self:abrisZoomToRange(commands, range:getLevel())
  -- ABRIS: wait for 100ms for ABRIS to settle
  self:nop(commands, "Wait for ABRIS to settle", KA50IIICommandGenerator.DELAY_ABRIS_SETTLE)
  local rotationsZ = range:toRotationsZ(deltaZ)
  -- ABRIS: rotate dial for Z
  self:abrisRotateEx(commands, rotationsZ, KA50IIICommandGenerator.DELAY_ABRIS_ROTATE, true,"Rotate Z")
  -- ABRIS: zoom to level 0 to avoid snapping
  self:abrisZoomToRange(commands, 0)
  -- ABRIS: wait for 100ms for ABRIS to settle
  self:nop(commands, "Wait for ABRIS to settle", KA50IIICommandGenerator.DELAY_ABRIS_SETTLE)
  -- ABRIS: switch to X entry  
  self:abrisPressRotateButton(commands, "Switch to X entry")
  -- determine the smallest bounding X range
  range = self:findSmallestBoundingXRange(previous, waypoint);
  Logging.info("Smallest X range: "..range:getLevel())
  -- ABRIS: zoom to the bounding range
  self:abrisZoomToRange(commands, range:getLevel())
  -- calculate number of dial rotations
  local rotationsX = range:toRotationsX(deltaX)
  -- ABRIS: wait for 100ms for ABRIS to settle
  self:nop(commands, "Wait for ABRIS to settle", KA50IIICommandGenerator.DELAY_ABRIS_SETTLE)
  -- ABRIS: rotate dial for X
  self:abrisRotateEx(commands, rotationsX, KA50IIICommandGenerator.DELAY_ABRIS_ROTATE, true,"Rotate X")
  -- ABRIS: zoom to level 0 to avoid snapping
  self:abrisZoomToRange(commands, 0)
  -- ABRIS: wait for 100ms for ABRIS to settle
  self:nop(commands, "Wait for ABRIS to settle", KA50IIICommandGenerator.DELAY_ABRIS_SETTLE)
  -- ABRIS: complete entry of waypoint
  self:abrisStartNextWaypoint(commands)
end

function KA50IIICommandGenerator:abrisStartNextWaypoint(commands)
  -- ABRIS: edit
  self:abrisPressButton1(commands, "Edit", 100) -- 1
  -- ABRIS: add
  self:abrisPressButton1(commands, "Add", 100) -- 1
end

function KA50IIICommandGenerator:findSmallestBoundingZRange(previous, waypoint)
  for i, range in pairs(self._ranges) do
    Logging.info("Checking Z level: "..range:getRange().." level: "..range:getLevel().." horizontal: "..range:getHorizontal().." vertical "..range:getVertical())
    if range:areBothPointsWithinZRange(previous, waypoint) then
      return range
    end
  end
  -- we should never reach here until ED creates larger MAPS than current BS3 can handle
  -- if this happens self:_ranges must be extended accordingly, but at this moment we can not anticipate future ranges
  return nil
end

function KA50IIICommandGenerator:findSmallestBoundingXRange(previous, waypoint)
  for i, range in pairs(self._ranges) do
    Logging.info("Checking X level: "..range:getRange().." level: "..range:getLevel().." horizontal: "..range:getHorizontal().." vertical "..range:getVertical())
    if range:areBothPointsWithinXRange(previous, waypoint) then
      return range
    end
  end
  -- we should never reach here until ED creates larger MAPS than current BS3 can handle
  -- if this happens self:_ranges must be extended accordingly, but at this moment we can not anticipate future ranges
  return nil
end

function KA50IIICommandGenerator:abrisCompleteRouteEntry(commands)
  -- ABRIS: Switch back to PLAN
  self:abrisPressButton5(commands, "Switch back to PLAN", 0)
  -- ABRIS: activate the route
  self:abrisPressButton4(commands, "Activate the route", 0)
end
-- Utility functions for ABRIS
function KA50IIICommandGenerator:nop(commands, comment, delay)
  commands[#commands + 1] = Command:new():setName("NOP"):setComment(comment):setDevice(nil):setCode(nil):setDelay(delay):setIntensity(nil):setDepress(false)
end

function KA50IIICommandGenerator:abrisPressButton1(commands, comment, delay)
  delay = delay or default_delay
  commands[#commands + 1] = Command:new():setName("ABRIS: press button 1"):setComment(comment):setDevice(9):setCode(3001):setDelay(delay):setIntensity(1):setDepress(true)
end

function KA50IIICommandGenerator:abrisPressButton2(commands, comment, delay)
  delay = delay or default_delay
  commands[#commands + 1] = Command:new():setName("ABRIS: press button 2"):setComment(comment):setDevice(9):setCode(3002):setDelay(delay):setIntensity(1):setDepress(true)
end

function KA50IIICommandGenerator:abrisPressButton3(commands, comment, delay)
  delay = delay or default_delay
  commands[#commands + 1] = Command:new():setName("ABRIS: press button 3"):setComment(comment):setDevice(9):setCode(3003):setDelay(delay):setIntensity(1):setDepress(true)
end

function KA50IIICommandGenerator:abrisPressButton4(commands, comment, delay)
  delay = delay or default_delay
  commands[#commands + 1] = Command:new():setName("ABRIS: press button 4"):setComment(comment):setDevice(9):setCode(3004):setDelay(delay):setIntensity(1):setDepress(true)
end

function KA50IIICommandGenerator:abrisPressButton5(commands, comment, delay)
  delay = delay or default_delay
  commands[#commands + 1] = Command:new():setName("ABRIS: press button 5"):setComment(comment):setDevice(9):setCode(3005):setDelay(delay):setIntensity(1):setDepress(true)
end

function KA50IIICommandGenerator:abrisRotate(commands, intensity, comment)
  commands[#commands + 1] = Command:new():setName("ABRIS: rotate"):setComment(comment):setDevice(9):setCode(3006):setDelay(0):setIntensity(intensity):setDepress(false)
end

function KA50IIICommandGenerator:abrisRotateEx(commands, intensity, delay, depress, comment)
  commands[#commands + 1] = Command:new():setName("ABRIS: rotate"):setComment(comment):setDevice(9):setCode(3006):setDelay(delay):setIntensity(intensity):setDepress(depress)
end

function KA50IIICommandGenerator:abrisPressRotateButton(commands, comment)
  commands[#commands + 1] = Command:new():setName("ABRIS: press rotate button"):setComment(comment):setDevice(9):setCode(3007):setDelay(default_delay):setIntensity(1):setDepress(true)
end

function KA50IIICommandGenerator:abrisZoomToRange(commands, level)
  local delta = level - self.zoomLevel
  Logging.info("Requested zoom: "..level)
  Logging.info("Current zoom: "..self.zoomLevel)
  Logging.info("Delta: "..delta)
  if delta < 0 then
    self:abrisZoomIn(commands, -delta)
  else
    self:abrisZoomOut(commands, delta)
  end
  Logging.info("POST Requested zoom: "..level)
  Logging.info("POST Current zoom: "..self.zoomLevel)
  Logging.info("POST Delta: "..delta)
end

function KA50IIICommandGenerator:abrisFullZoom(commands)
  self:abrisZoomIn(commands, #self._ranges)
end

function KA50IIICommandGenerator:abrisZoomIn(commands, relativeZoomLevel)
  Logging.info("abrisZoomIn relativeZoomLevel: "..relativeZoomLevel)
  if relativeZoomLevel < 0 then
    return
  end
  for i = 1, relativeZoomLevel do
    self:abrisPressButton3(commands, "ZoomIn", KA50IIICommandGenerator.DELAY_ABRIS_ZOOM)
  end
  self.zoomLevel = math.max(self.zoomLevel - relativeZoomLevel, 0)
  Logging.info("abrisZoomIn Zoom Level: "..self.zoomLevel)
end

function KA50IIICommandGenerator:abrisZoomOut(commands, relativeZoomLevel)
  Logging.info("abrisZoomOut Zoom Level: "..self.zoomLevel)
  Logging.info("abrisZoomOut relativeZoomLevel: "..relativeZoomLevel)
  if relativeZoomLevel < 0 then
    return
  end
  for i = 1, relativeZoomLevel do
    self:abrisPressButton4(commands, "ZoomOut", KA50IIICommandGenerator.DELAY_ABRIS_ZOOM)
  end
  self.zoomLevel = math.min(self.zoomLevel + relativeZoomLevel, #self._ranges)
  Logging.info("abrisZoomOut Zoom Level: "..self.zoomLevel)
end

function KA50IIICommandGenerator:_determineNumberOfModePresses()
  local mode = Export.GetDevice(9):get_mode()
  mode = tostring(mode.master)..tostring(mode.level_2)..tostring(mode.level_3)..tostring(mode.level_4)
  if mode == "0000" then
    return 0
  elseif mode == "9000" then
    return 1
  elseif mode == "5000" then
    return 4
  elseif mode == "5500" then
    return 3
  elseif mode == "5100" then
    return 2
  elseif mode == "5400" then
    return 5
  elseif mode == "5310" then
    return 5
  elseif mode == "5200" then
    return 5
  elseif mode == "5430" then
    return 5
  elseif mode == "5240" then
    return 5
  elseif self:starts_with(mode,"5") then
    return 5
  end
  -- Logging.info("ABRIS Mode: "..mode)
  return 5
end

-- Coordinates utility functions
function KA50IIICommandGenerator:_getLatitudeDigits(latitude)
  local buffer = string.format("%02.0f", latitude.degrees)..string.format("%04.1f", latitude.minutes)
  -- Logging.info("Latitude buffer: "..buffer)
  local result = {}
  for i = 1, #buffer do
    local temp = string.sub(buffer, i, i)
    if temp ~= '.' and temp then
      result[#result + 1] = tonumber(temp)
    end
  end
  return result
end

function KA50IIICommandGenerator:_getLongitudeDigits(longitude)
  local buffer = string.format("%03.0f", longitude.degrees)..string.format("%04.1f", longitude.minutes)
  -- Logging.info("Longitude buffer: "..buffer)
  local result = {}
  for i = 1, #buffer do
    local temp = string.sub(buffer, i, i)
    if temp ~= '.' then
      result[#result + 1] = tonumber(temp)
    end
  end
  return result
end

function KA50IIICommandGenerator:starts_with(str, start)
   return str:sub(1, #start) == start
end

return KA50IIICommandGenerator
