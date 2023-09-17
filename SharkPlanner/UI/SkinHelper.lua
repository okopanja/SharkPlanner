local lfs = require("lfs")
local Skin = require("Skin")
-- local base = require("base")
local skinPath = lfs.writedir() .. 'Scripts/SharkPlanner/UI/skins/'
local Logging = require("SharkPlanner.Utils.Logging")
local Utils = require("SharkPlanner.Utils")
-- local loadfile = base.loadfile

local function getFullSkinPath(filename)
	return skinPath .. filename
end

local namesFilename = getFullSkinPath('skin_names.lua')
local names = {}
local skins = {}


local function loadSkin(skinName)
    if skins[skinName] ~= nil then
        return skins[skinName]
    end
    local result = nil
    local skinFileName = getFullSkinPath(names[skinName])
    Logging.debug("Loading skin file: ".. skinFileName)
    local f, err = loadfile(skinFileName)
    if f then
        result = f()
        -- dxgui pictures by default searches within the main installation. 
        -- To workaround that the relative paths of the mode need to be adjusted to absolute paths within user's Saved Games
        for stateName, state in pairs(result.skinData.states) do
            Logging.debug("State: "..stateName)
            for i, style in pairs(state) do                
                if style.bkg then
                    if style.bkg.file then
                        if Utils.String.starts_with(style.bkg.file, "dxgui") == false and Utils.String.starts_with(style.bkg.file, "Mods") == false and style.bkg.file ~= "$nil$"  then
                            Logging.debug("Correcting path to: "..lfs.writedir() .. style.bkg.file)
                            style.bkg.file = lfs.writedir() .. style.bkg.file
                        end
                    end
                end
                if style.picture then
                    if style.picture.file then
                        if Utils.String.starts_with(style.picture.file, "dxgui") == false and Utils.String.starts_with(style.picture.file, "Mods") == false and style.picture.file ~= "$nil$"  then
                            Logging.debug("Correcting path to: "..lfs.writedir() .. style.picture.file)
                            style.picture.file = lfs.writedir() .. style.picture.file
                        end
                    end
                end
            end
        end
    else
        Logging.info('Cannot load skin: '..err)
    end
    -- record skin for future use
    skins[skinName] = result
    return result
end

local function loadLocalSkins()
    Logging.info("Loading skin file: ".. namesFilename)
	local f, err = loadfile(namesFilename)
	if f then
        Logging.info("Setting environment and obtaining the names")
		setfenv(f, names)
		f()
	else
		Logging.info('Cannot load ' .. namesFilename .. '!')
	end
end
loadLocalSkins()

return {
    loadSkin = loadSkin,
}