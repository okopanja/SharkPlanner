local net = require("net")

-- logs message into log file with info severity
local function info(message)
  net.log("[SharkPlanner] "..message)
end

return {
  info = info
}
