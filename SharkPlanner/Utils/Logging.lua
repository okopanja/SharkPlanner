local net = require("net")

local LOG_LEVELS = {
  INFO="INFO",
  WARNING="WARNING",
  ERROR="ERROR",
  DEBUG="DEBUG"
}

local fp = io.open(lfs.writedir().."Logs\\SharkPlanner.log", "w")
local verbosity = LOG_LEVELS.INFO
-- logs message into log file with info severity
local function log(level, message)
  fp:write(os.date("%Y-%m-%d %H:%M:%S").." "..level.." "..message.."\n")
  fp:flush()
  -- net.log("[SharkPlanner] "..message)
end

local function info(message)
  if verbosity >= LOG_LEVELS.INFO then    
    log(LOG_LEVELS.INFO, message)
  end
end

local function warning(message)
  if verbosity >= LOG_LEVELS.WARNING then    
    log(LOG_LEVELS.WARNING, message)
  end
end

local function error(message)
  if verbosity >= LOG_LEVELS.ERROR then    
    log(LOG_LEVELS.ERROR, message)
    net.log("[SharkPlanner] "..message)
  end
end

local function debug(message)
  if verbosity >= LOG_LEVELS.ERROR then  
    log(LOG_LEVELS.DEBUG, message)
  end
end

function setLogLevel(logLevel)
  verbosity = logLevel
end

return {
  log = log,
  info = info,
  warning = warning,
  error = error,
  debug = debug,
  setLogLevel = setLogLevel
}
