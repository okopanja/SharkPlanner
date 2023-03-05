local VERSION_INFO = require("SharkPlanner.VersionInfo")
local Base = require("SharkPlanner.Base")
local Modules = require("SharkPlanner.Modules")

-- make Base, Modules and VERSION_INFO available
return {
    Base = Base,
    Modules = Modules,
    VERSION_INFO = VERSION_INFO
}
