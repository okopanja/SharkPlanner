-- provide sub-packages and modules
return {
  Hemispheres = require("SharkPlanner.Base.Hemispheres"),
  Position = require("SharkPlanner.Base.Position"),
  Command = require("SharkPlanner.Base.Command"),
  BaseCommandGenerator = require("SharkPlanner.Base.BaseCommandGenerator"),
  CommandGeneratorFactory = require("SharkPlanner.Base.CommandGeneratorFactory"),
  GameState = require("SharkPlanner.Base.GameState"),
  CoordinateData = require("SharkPlanner.Base.CoordinateData"),
  DCSEventHandlers = require("SharkPlanner.Base.DCSEventHandlers"),
  Configuration = require("SharkPlanner.Base.Configuration"),
  Camera = require("SharkPlanner.Base.Camera"),
}
