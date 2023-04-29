-- workaround: FileDialog imports me_modulesInfo module which further imports module that is not available in this lua environment
--             Therefore we need to remove this import.
--             This workaround does not modify original file, it is just modifying the FileDialog module on the fly and affects only export environment
local fp = io.open(lfs.currentdir().."MissionEditor\\modules\\FileDialog.lua", "rb")
local moduleContent = fp:read("*all")
fp:close()
local patchedFileDialog = loadstring(string.gsub(moduleContent, "local modulesInfo", "-- local modulesInfo").."\r\nreturn { save = save, open = open }")()

return patchedFileDialog