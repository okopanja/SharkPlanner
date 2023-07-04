local Logging = require("SharkPlanner.Utils.Logging")
local GameState = require("SharkPlanner.Base.GameState")
local coordinateData = require("SharkPlanner.Base.CoordinateData")
local CommandGeneratorFactory = require("SharkPlanner.Base.CommandGeneratorFactory")
local DCSEventHandlers = {}

local EventTypes = {
  TransferStarted = 1,
  TransferFinished = 2,
  TransferProgressUpdated = 3,
  SimulationStarted = 4,
  PlayerChangeSlot = 5,
  PlayerEnteredSupportedVehicle = 6,
  SimulationStopped = 7,
}

DCSEventHandlers.minimalInterval = 0.001
DCSEventHandlers.lastTime = DCS.getModelTime()
DCSEventHandlers.commands = {}
DCSEventHandlers.delayed_depress_commands = {}
DCSEventHandlers.EventTypes = EventTypes
DCSEventHandlers.eventHandlers = {
  [EventTypes.TransferStarted] = {},
  [EventTypes.TransferFinished] = {},
  [EventTypes.TransferProgressUpdated] = {},
  [EventTypes.PlayerChangeSlot] = {},
  [EventTypes.SimulationStarted] = {},
  [EventTypes.PlayerEnteredSupportedVehicle] = {},
  [EventTypes.SimulationStopped] = {},
}

function DCSEventHandlers.onSimulationFrame()
  -- ensure we run command checks at most every minimalInterval miliseconds
  local current_time = DCS.getModelTime()
  if( DCSEventHandlers.lastTime + DCSEventHandlers.minimalInterval <= current_time) then
      -- lastTime = current_time
      if DCSEventHandlers.transferIsActive() then
      -- determine what can be depressed
      local last_command_due_for_depress = DCSEventHandlers.find_last_due_command_index(DCSEventHandlers.delayed_depress_commands, current_time)
      if last_command_due_for_depress > 0 then
          Logging.info("Last command due for depress: "..last_command_due_for_depress)
          -- depress all matching
          for i = 1, last_command_due_for_depress do
          local command = DCSEventHandlers.delayed_depress_commands[i]
          Export.GetDevice(command:getDevice()):performClickableAction(command:getCode(), 0)
          end
          -- remove depressed commands
          for i = 1, last_command_due_for_depress do
          table.remove(DCSEventHandlers.delayed_depress_commands, 1)
          end
          -- if the delayed_depress_commands is still not empty we need to wait further, and not proceed with scheduled!
          if #DCSEventHandlers.delayed_depress_commands > 0 then
          return
          end
      end

      -- determine commands that have reach the point for execition
      local last_scheduled_command = DCSEventHandlers.find_last_due_command_index(DCSEventHandlers.commands, current_time)
      if last_scheduled_command > 0 then
          Logging.info("Commands found: "..last_scheduled_command)
          for i = 1, last_scheduled_command do
            local command = DCSEventHandlers.commands[i]
            -- update command if needed, e.g. if command has associated update callback
            command:update(DCSEventHandlers.commands)
            Logging.info(command:getText())
            if command:getDevice() then          
              Export.GetDevice(command:getDevice()):performClickableAction(command:getCode(), command:getIntensity())
              Logging.info("Pressed")
              -- check if the command needs depress
              if command:getDepress() then
                -- check for Delay
                if command:getDelay() == 0 then
                -- if the delay is 0, the command can be immidiatly depressed
                Export.GetDevice(command:getDevice()):performClickableAction(command:getCode(), 0)
                Logging.info("Depressed")
                else
                -- Delayed commands can not be depressed now
                command:setSchedule(current_time + (command:getDelay() / 1000))
                DCSEventHandlers.delayed_depress_commands[#DCSEventHandlers.delayed_depress_commands + 1] = command
                Logging.info("Queued for delayed depress")
                end
              else
                Logging.info("NOP command, skipping")
              end
            end
          end
          -- remove depressed commands (includes both depressed and those that were moved to delayed depress queue)
          for i = 1, last_scheduled_command do
            table.remove(DCSEventHandlers.commands, 1)
          end
          local eventArg = {
            commands = DCSEventHandlers.commands,
            currentCommandCount = #DCSEventHandlers.commands,
            totalCommandsCount = DCSEventHandlers.totalCommandsCount
          }
          DCSEventHandlers.dispatchEvent(EventTypes.TransferProgressUpdated, eventArg)
      end

      if DCSEventHandlers.transferIsInactive() then
        -- Transfer has stopped
        Logging.info("Commands have been fully executed.")
        -- notify that transfer has finished
        local eventArg = {
          -- at the moment no actual need, but still needed for generic dispatchEvent method
          -- reserved for future use
        }
        DCSEventHandlers.dispatchEvent(EventTypes.TransferFinished, eventArg)
      end
    end
  end
end

function DCSEventHandlers.onSimulationStart()
    Logging.info("onSimulationStart")
    local eventArgs = {
    }    
    DCSEventHandlers.dispatchEvent(EventTypes.SimulationStarted, eventArgs)

    Logging.info("Game state: "..GameState.getGameState())  
    DCSEventHandlers.aircraftModel = CommandGeneratorFactory.getCurrentAirframe()
    if DCSEventHandlers.aircraftModel ~= nil then
      Logging.info("Detected: "..DCSEventHandlers.aircraftModel)
      if CommandGeneratorFactory.isSupported(DCSEventHandlers.aircraftModel) then
        Logging.info("Airframe is supported: "..DCSEventHandlers.aircraftModel)
        Logging.info("Creating command generator")
        DCSEventHandlers.commandGenerator = CommandGeneratorFactory.createGenerator(DCSEventHandlers.aircraftModel)
        if DCSEventHandlers.commandGenerator ~= nil then
          Logging.info("Command generator for "..DCSEventHandlers.aircraftModel.." was created")
          local eventArgs = {
            aircraftModel = DCSEventHandlers.aircraftModel,
            commandGenerator = DCSEventHandlers.commandGenerator
          }
          coordinateData:normalize(DCSEventHandlers.commandGenerator)
          DCSEventHandlers.dispatchEvent(EventTypes.PlayerEnteredSupportedVehicle, eventArgs)
        else
          Logging.info("Command generator for was not created")
        end
        -- reset()
      else
        Logging.info("Airframe is not supported: "..DCSEventHandlers.aircraftModel)
      end
    end

end

function DCSEventHandlers.onSimulationStop()
    Logging.info("onSimulationStop")
    DCSEventHandlers.aircraftModel = nil
    DCSEventHandlers.commandGenerator = nil
    local eventArgs = {
    }    
    DCSEventHandlers.dispatchEvent(EventTypes.SimulationStopped, eventArgs)
end

function DCSEventHandlers.onPlayerChangeSlot(id)
    Logging.info("onPlayerChangeSlot")
    local my_id = net.get_my_player_id()
    if id == my_id then
      local eventArgs = {
        id = id
      }
      DCSEventHandlers.aircraftModel = nil
      DCSEventHandlers.commandGenerator = nil
      DCSEventHandlers.dispatchEvent(EventTypes.PlayerChangeSlot, eventArgs)
    end
end

function DCSEventHandlers.register()
    DCS.setUserCallbacks(DCSEventHandlers)
end

function DCSEventHandlers.unregister()
    DCS.setUserCallbacks(DCSEventHandlers)
end

function DCSEventHandlers.transferIsInactive()
  return #DCSEventHandlers.commands == 0 and #DCSEventHandlers.delayed_depress_commands == 0
end

function DCSEventHandlers.transferIsActive()
  return not DCSEventHandlers.transferIsInactive()
end

function DCSEventHandlers.find_last_due_command_index(command_list, reference_time)
  local last_due_command_index = 0
  for k, command in pairs(command_list) do
    if command:getSchedule() > reference_time then
      return k - 1
    end
    last_due_command_index = k
  end
  return last_due_command_index
end

function DCSEventHandlers.transfer(commands)
  DCSEventHandlers.totalCommandsCount = #commands
  DCSEventHandlers.commands = DCSEventHandlers.scheduleCommands(commands)
  -- notify that transfer has started
  local eventArg = {
    commands = DCSEventHandlers.commands
  }
  DCSEventHandlers.dispatchEvent(EventTypes.TransferStarted, eventArg)
end

function DCSEventHandlers.scheduleCommands(commands)
  -- introduce 100ms delay at start
  local schedule_time = DCS.getModelTime() + 0.100
  Logging.info("Expected schedule start: "..schedule_time)
  for k, command in pairs(commands) do
    command:setSchedule(schedule_time)
    Logging.info(command:getText())
    -- adjust the schedule_time by delay caused by current command. (causes all remaning to be delayed)
    schedule_time = schedule_time + (command:getDelay() / 1000)
  end
  Logging.info("Expected schedule end: "..schedule_time)
  return commands
end

function DCSEventHandlers.addEventHandler(eventType, object, eventHandler)
  DCSEventHandlers.eventHandlers[eventType][#DCSEventHandlers.eventHandlers[eventType] + 1] = { object = object, eventHandler = eventHandler }
end

-- the dispatchEvent for now executes directly the event handlers
function DCSEventHandlers.dispatchEvent(eventType, eventArg)
  for k, eventHandlerInfo in pairs(DCSEventHandlers.eventHandlers[eventType]) do
      eventHandlerInfo.eventHandler(eventHandlerInfo.object, eventArg)
  end
end

return DCSEventHandlers