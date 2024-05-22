-- Logging package is extremely important in order to debug issues
local Logging = require("SharkPlanner.Utils.Logging")
-- Your command generators must be derived from class BaseCommandGenerator
local BaseCommandGenerator = require("SharkPlanner.Base.BaseCommandGenerator")
-- Command is a class representing single entry event into the device
local Command = require("SharkPlanner.Base.Command")
-- Position is a class, representing coordinates prepared by UI part of Black Shark. They can be used to represent waypoints, fixpoints, target points, mark points etc.
local Position = require("SharkPlanner.Base.Position")
-- Enumeration for Hemispheres
local Hemispheres = require("SharkPlanner.Base.Hemispheres")
-- Singleton class used to obtain value of configuration option
local Configuration = require("SharkPlanner.Base.Configuration")
-- for coordinate conversion you might need math module
require("math")

-- Enter ID of entry devices
local DEAD_RECKONING_DEVICE_ID = 22

-- constuct the new class (derive from BaseCommandGenerator)
DeadReckoningCommandGenerator = BaseCommandGenerator:new()

-- Object constructor
function DeadReckoningCommandGenerator:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

-- This function will return the name of the aircraft module during runtime
function DeadReckoningCommandGenerator:getAircraftName()
  return "DeadReckoning"
end

-- Function returns maximal numnber of waypoints available for entry. This is typically static value. Study the documentation of module. 
function DeadReckoningCommandGenerator:getMaximalWaypointCount()
  return 10
end

-- Function returns maximal numnber of fix points available for entry. This is typically static value. Study the documentation of module. 
function DeadReckoningCommandGenerator:getMaximalFixPointCount()
  return 0
end

-- Function returns maximal numnber of target points available for entry. This is typically static value. Study the documentation of module. 
function DeadReckoningCommandGenerator:getMaximalTargetPointCount()
  return 0
end

-- Function generates sequence of commands, which are used by SharkPlanner to perform entry. 
-- Consider this to be the "main" of your module. It will be called each time you click on Transfer button in UI.
-- - waypoints, list of Position objects designated as waypoints
-- - fixpoints, list of Position objects designated as fix points (fix points are normally used for )
-- - targetpoints, list of Position objects designated as target points
function DeadReckoningCommandGenerator:generateCommands(waypoints, fixpoints, targets)
  -- define device delay that will be passed later, derived from default_delay
  -- it is recommended to have default delay between 2 commands, e.g. 100ms. 
  -- The delay value depends on the module implementation, and it may even vary from command to command. 
  -- Safe value should be 100ms, but sometimes lower values are used, even 0. 
  -- Many buttons will not reacto properly if this value is lower than 70-75ms
  -- declare empty list of commands
  local commands = {}
  -- following are high level sequences of commands, each takes commands list and adds additional command to it

  -- normally you need to enter the entry mode, since this may require pushing multiple buttons or dialing dials, it is best to have that in function rather than implement it in this function. See the function documentation.
  self:deadReckoningEnterEntryMode(commands, "Entering entry mode", 0.2)
  -- once you are in the correct mode it's time to enter the waypoints.
  self:deadReckoningEnterWaypoints(commands, waypoints)
  -- if you enter other types of positions, use another function/function call ;)
  -- once the entry is completed you will want to return to the main mode of the device
  self:deadReckoningReturnToMainMode(commands, "Enter main mode")
  -- If you ever wish to have optional commands, you can use the Configuration object to lookup for the option
  if Configuration:getOption("OH-6A.DeadReckoning.SelectWaypoint1") then
    -- in this case we specified non a specific delay for this particular command
    local delay = 200
    self:deadReckoningPressDigitButton(commands, 1, "Selected waypoint: 1", delay)
  end

  return commands
end

-- Example sequence for entry mode
function DeadReckoningCommandGenerator:deadReckoningEnterEntryMode(commands, comment, intensity)
end

function DeadReckoningCommandGenerator:deadReckoningReturnToMainMode(commands, comment, intensity)
end


-- Example sequence which enters waypoints
function DeadReckoningCommandGenerator:deadReckoningEnterWaypoints(commands, waypoints)
  -- in most cases this simply iterates through all waypoints 
  for position, waypoint in ipairs(waypoints) do
    -- typically you need to pass existing commands, position (e.g. 1, 2, 3, 4, 5...), waypoint (as Position object you got from UI)
    self:deadReckoningEnterWaypoint(commands, position, waypoint)
  end
end

-- Example sequence for entering single waypoint, this is typically the most complex function.
function DeadReckoningCommandGenerator:deadReckoningEnterWaypoint(commands, position, waypoint)
end


-- generator class must always returned!
return DeadReckoningCommandGenerator
