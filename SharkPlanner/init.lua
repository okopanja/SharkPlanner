local VERSION_INFO = require("SharkPlanner.VersionInfo")
local Base = require("SharkPlanner.Base")
local Modules = require("SharkPlanner.Modules")
local Utils = require("SharkPlanner.Utils")
-- make Base, Modules Utils, and VERSION_INFO available
return {
    Base = Base,
    Modules = Modules,
    Utils = Utils,
    VERSION_INFO = VERSION_INFO
}
