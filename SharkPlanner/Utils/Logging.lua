local net = require("net")

local LOG_LEVELS = {
  INFO    = { name = "INFO",    level = 0 },
  WARNING = { name = "WARNING", level = 1 },
  ERROR   = { name = "ERROR",   level = 2 },
  DEBUG   = { name = "DEBUG",   level = 3 },
}

local fp = io.open(lfs.writedir().."Logs\\SharkPlanner.log", "w")
local verbosity = LOG_LEVELS.ERROR
-- logs message into log file with info severity
local function log(level, message)
  fp:write(os.date("%Y-%m-%d %H:%M:%S").." "..level.name.." "..message.."\n")
  -- net.log("[SharkPlanner] "..message)
end

local function info(message)
  if verbosity.level >= LOG_LEVELS.INFO.level then
    log(LOG_LEVELS.INFO, message)
  end
end

local function warning(message)
  if verbosity.level >= LOG_LEVELS.WARNING.level then
    log(LOG_LEVELS.WARNING, message)
  end
end

local function error(message)
  if verbosity.level >= LOG_LEVELS.ERROR.level then
    log(LOG_LEVELS.ERROR, message)
  end
end

local function debug(message)
  if verbosity.level >= LOG_LEVELS.ERROR.level then
    log(LOG_LEVELS.DEBUG, message)
  end
end

local function setLogLevel(logLevel)
  verbosity = logLevel
end

return {
  log = log,
  info = info,
  warning = warning,
  error = error,
  debug = debug,
  setLogLevel = setLogLevel,
  LOG_LEVELS = LOG_LEVELS
}
