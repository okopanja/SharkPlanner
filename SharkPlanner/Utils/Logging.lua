local net = require("net")

local LOG_LEVELS = {
  INFO    = { name = "INFO",    value = 0 },
  WARNING = { name = "WARNING", value = 1 },
  ERROR   = { name = "ERROR",   value = 2 },
  DEBUG   = { name = "DEBUG",   value = 3 },
}

local fp = io.open(lfs.writedir().."Logs\\SharkPlanner.log", "w")
local verbosity = LOG_LEVELS.ERROR
-- logs message into log file with info severity
local function log(level, message)
  fp:write(os.date("%Y-%m-%d %H:%M:%S").." "..level.name.." "..message.."\n")
  -- net.log("[SharkPlanner] "..message)
end

local function info(message)
  if verbosity.value >= LOG_LEVELS.INFO.value then
    log(LOG_LEVELS.INFO, message)
  end
end

local function warning(message)
  if verbosity.value >= LOG_LEVELS.WARNING.value then
    log(LOG_LEVELS.WARNING, message)
  end
end

local function error(message)
  if verbosity.value >= LOG_LEVELS.ERROR.value then
    log(LOG_LEVELS.ERROR, message)
  end
end

local function debug(message)
  if verbosity.value >= LOG_LEVELS.DEBUG.value then
    log(LOG_LEVELS.DEBUG, message)
  end
end

local function setLogLevel(logLevel)
  info("Changing log level to: "..logLevel.name)
  verbosity = logLevel
end

local function updateVerbosity(option, logLevelName)
  local logLevel = LOG_LEVELS[logLevelName]
  if logLevel ~= nil then
    setLogLevel(logLevel)
  end
end

return {
  log = log,
  info = info,
  warning = warning,
  error = error,
  debug = debug,
  setLogLevel = setLogLevel,
  updateVerbosity = updateVerbosity,
  LOG_LEVELS = LOG_LEVELS
}
