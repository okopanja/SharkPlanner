-- workaround: FileDialog imports me_modulesInfo module which further imports module that is not available in this lua environment
--             Therefore we need to remove this import.
local fp = io.open(lfs.currentdir().."MissionEditor\\modules\\FileDialog.lua", "rb")
local moduleContent = fp:read("*all")
fp:close()
local patchedFileDialog = loadstring(string.gsub(moduleContent, "local modulesInfo", "-- local modulesInfo").."\r\nreturn { save = save, open = open }")()

return patchedFileDialog