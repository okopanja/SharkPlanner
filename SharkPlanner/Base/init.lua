-- provide sub-packages and modules
return {
  Position = require("SharkPlanner.Base.Position"),
  Command = require("SharkPlanner.Base.Command"),
  BaseCommandGenerator = require("SharkPlanner.Base.BaseCommandGenerator"),
  CommandGeneratorFactory = require("SharkPlanner.Base.CommandGeneratorFactory"),
  GameState = require("SharkPlanner.Base.GameState")
}
