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
local ToggleButton			= require("ToggleButton")
local Panel			= require("Panel")
local ScrollPane = require("ScrollPane")
local Static = require("Static")
local Checkbox = require("CheckBox")

local OptionsWindow = DialogLoader.spawnDialogFromFile(
    lfs.writedir() .. "Scripts\\SharkPlanner\\UI\\OptionsWindow.dlg"
)


local staticConfigurationSectionTitleSkin = SkinHelper.loadSkin("staticConfigurationSectionTitle")
local toggleConfigurationSidePanel = SkinHelper.loadSkin("toggleConfigurationSidePanel")
-- Constructor
function OptionsWindow:new(o)
    o = o or {}
    setmetatable(o, self)
    o.sectionPanels = {}
    self.__index = self
    local x, y, w, h = o.crosshairWindow:getBounds()
    local first = true
    local sidePanelWidth, sidePanelHeight = o.sidePanel:getSize()
    Logging.debug("Creating options window")
    for i, section in ipairs(Configuration.sections) do
      Logging.debug("Section found: "..section.SectionName)
      local btn = ToggleButton.new()
      -- button needs to be aware of the it's section name
      btn.sectionName = section.SectionName
      btn:setText(section.SectionName)
      btn:setSkin(toggleConfigurationSidePanel)
      -- btn:setSize(100,26)
      -- register button click to ensure that setions are navigable
      btn:addChangeCallback(
        function(button)
          Logging.debug("Clicked on: "..button.sectionName)
          local currentWidget = o.sectionContent:getWidget(0)
          local newWidget = o.sectionPanels[button.sectionName]
          if newWidget ~= currentWidget then
            Logging.debug("Replacing content")
            o.sidePanel.selectedButton:setState(false)
            o.sidePanel.selectedButton = button
            o.sectionContent:removeWidget(currentWidget)
            o.sectionContent:insertWidget(newWidget)
          else
            Logging.debug("Clicked section is already active, ignoring")
            o.sidePanel.selectedButton:setState(true)
          end
        end
      )

      o.sidePanel:insertWidget(btn, o.sidePanel:getWidgetCount() + 1)
      -- create Panel for section content
      local panel = Panel.new()
      panel:setBounds(0,0,200,200)
      o.sectionPanels[section.SectionName] = panel
      local sectionTitle = Static.new()
      -- o.sectionContent:insertWidget(sectionTitle, o.sectionContent:getWidgetCount() + 1)
      sectionTitle:setText(section.SectionName)
      sectionTitle:setBounds(0,0,200,30)
      sectionTitle:setVisible(true)
      sectionTitle:setSkin(staticConfigurationSectionTitleSkin)

      panel:insertWidget(sectionTitle)
      if first then
        o.sectionContent:insertWidget(panel, o.sectionContent:getWidgetCount() + 1)
        btn:setState(true)
        o.sidePanel.selectedButton = btn
        first = false
      end
    end
    o:setBounds(x, y - (h / 2), w, h)
    o:setVisible(true)
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