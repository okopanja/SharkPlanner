-- provide sub-packages and modules
local Logging = require("SharkPlanner.Utils.Logging")
local DialogLoader = require("DialogLoader")
local SkinHelper = require("SharkPlanner.UI.SkinHelper")
local dxgui = require('dxgui')
local lfs = require("lfs")
local Skin = require("Skin")
local SkinUtils = require("SkinUtils")
local Static = require("Static")
local Configuration = require("SharkPlanner.Base.Configuration")
local Button			= require("Button")

local OptionsWindow = DialogLoader.spawnDialogFromFile(
    lfs.writedir() .. "Scripts\\SharkPlanner\\UI\\OptionsWindow.dlg"
)

local skinMappings = {
  ["Ka-50"] = SkinHelper.loadSkin("buttonConfigurationKa50"),
  ["SA-342 Gazelle"] = SkinHelper.loadSkin("buttonConfigurationSA342")
}

-- Constructor
function OptionsWindow:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    local x, y, w, h = o.crosshairWindow:getBounds()
    Logging.info("Creating options window")
    for k, v in pairs(Configuration.sections) do
      Logging.debug("Section found: "..k)
      local btn = Button.new()
      -- btn:setText(v.SectionName)
      btn:setSkin(skinMappings[k])
      o.panelSections:insertWidget(btn, o.panelSections:getWidgetCount() + 1)
    end
    -- o.panelSections:getLayout():updateSize()
    o:setBounds(x, y - h, w, h)
    -- o:setVisible(true)
    return o
end

function OptionsWindow:show()
    self:setVisible(true)
    -- show all widgets on status window
    local count = self:getWidgetCount()
  	for i = 1, count do
      local index 		= i - 1
  	  local widget 		= self:getWidget(index)
      widget:setVisible(true)
      widget:setFocused(false)
    end
    local width, height = self:getSize()
  end

function OptionsWindow:hide()
    -- hide all widgets on status window
    local count = self:getWidgetCount()
    for i = 1, count do
        local index 		= i - 1
        local widget 		= self:getWidget(index)
    widget:setVisible(false)
    widget:setFocused(false)
  end
  self:setHasCursor(false)
  self:setVisible(false)
end

return OptionsWindow