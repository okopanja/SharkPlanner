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


-- constuct the new class (derive from BaseCommandGenerator)
OH6ACommandGenerator = BaseCommandGenerator:new()

-- Object constructor
function OH6ACommandGenerator:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

-- This function will return the name of the aircraft module during runtime
function OH6ACommandGenerator:getAircraftName()
  return "OH-6A"
end

-- Function returns maximal numnber of waypoints available for entry. This is typically static value. Study the documentation of module. 
function OH6ACommandGenerator:getMaximalWaypointCount()
  return 10
end

-- Function returns maximal numnber of fix points available for entry. This is typically static value. Study the documentation of module. 
function OH6ACommandGenerator:getMaximalFixPointCount()
  return 0
end

-- Function returns maximal numnber of target points available for entry. This is typically static value. Study the documentation of module. 
function OH6ACommandGenerator:getMaximalTargetPointCount()
  return 0
end

return OH6ACommandGenerator
