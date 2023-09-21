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
local Panel			= require("Panel")
local ScrollPane = require("ScrollPane")
local Static = require("Static")
local Checkbox = require("CheckBox")

local OptionsWindow = DialogLoader.spawnDialogFromFile(
    lfs.writedir() .. "Scripts\\SharkPlanner\\UI\\OptionsWindow.dlg"
)

local skinMappings = {
  ["Ka-50"] = SkinHelper.loadSkin("buttonConfigurationKa50"),
  ["SA-342 Gazelle"] = SkinHelper.loadSkin("buttonConfigurationSA342")
}

local staticConfigurationSectionTitleSkin = SkinHelper.loadSkin("staticConfigurationSectionTitle")
local statusSkin = SkinHelper.loadSkin("staticSkinSharkPlannerStatus")

-- Constructor
function OptionsWindow:new(o)
    o = o or {}
    setmetatable(o, self)
    o.sectionPanels = {}
    self.__index = self
    local x, y, w, h = o.crosshairWindow:getBounds()
    local first = true
    Logging.info("Creating options window")
    for k, v in pairs(Configuration.sections) do
      Logging.debug("Section found: "..k)
      local btn = Button.new()
      btn.sectionName = k
      btn:setSkin(skinMappings[k])
      btn:addChangeCallback(
        function(button)
          Logging.debug("Clicked on: "..button.sectionName)
          local currentWidget = o.sectionContent:getWidget(0)
          local newWidget = o.sectionPanels[button.sectionName]
          if newWidget ~= currentWidget then
            Logging.debug("Replacing content")
            o.sectionContent:removeWidget(currentWidget)
            o.sectionContent:insertWidget(newWidget)
          else
            Logging.debug("Same section selection, ignoring")
          end
        end
      )

      o.panelSections:insertWidget(btn, o.panelSections:getWidgetCount() + 1)
      -- create Panel
      local panel = Panel.new()
      panel:setBounds(0,0,200,200)
      o.sectionPanels[k] = panel
      local sectionTitle = Static.new()
      -- o.sectionContent:insertWidget(sectionTitle, o.sectionContent:getWidgetCount() + 1)
      sectionTitle:setText(k)
      sectionTitle:setBounds(0,0,200,30)
      sectionTitle:setVisible(true)
      sectionTitle:setSkin(staticConfigurationSectionTitleSkin)

      panel:insertWidget(sectionTitle)
      if first then
        o.sectionContent:insertWidget(panel, o.sectionContent:getWidgetCount() + 1)
        first = false
      end
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