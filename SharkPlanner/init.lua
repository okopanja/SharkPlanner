local VERSION_INFO = require("SharkPlanner.VersionInfo")
local Utils = require("SharkPlanner.Utils")
Utils.Logging.info("Version: "..VERSION_INFO)
local Base = require("SharkPlanner.Base")
local Modules = require("SharkPlanner.Modules")
local UI = require("SharkPlanner.UI")

-- make Base, Modules Utils, and VERSION_INFO available
return {
    Base = Base,
    Modules = Modules,
    Utils = Utils,
    UI = UI,
    VERSION_INFO = VERSION_INFO
}
