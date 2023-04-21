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

local function loadSkin(skinName)
    local result = nil
    local skinFileName = getFullSkinPath(names[skinName])
    Logging.info("Loading skin file: ".. skinFileName)
    local f, err = loadfile(skinFileName)
    if f then
        result = f()
        for stateName, state in pairs(result.skinData.states) do
            for i, style in pairs(state) do
                if style.bkg then
                    if style.bkg.file then
                        if Utils.String.starts_with(style.bkg.file, "dxgui") == false then
                            style.bkg.file = lfs.writedir() .. style.bkg.file
                        end
                    end
                end
            end
        end
        -- if result and result.skinData.skins then
        --     for widgetName, widgetSkin in pairs(result.skinData.skins) do
        --         -- FIXME: remove
        --         if type(widgetSkin) == 'string' then
        --             result.skinData.skins[widgetName] = getSkin(widgetSkin)
        --         end
        --     end
        -- end

    else
        Logging.info('Cannot load skin: '..err)
    end
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