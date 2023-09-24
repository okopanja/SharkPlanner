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
local CheckBox = require("CheckBox")
local ComboBox = require("ComboBox")
local ListBoxItem = require("ListBoxItem")
local LayoutFactory = require("LayoutFactory")
local HorzLayout = require("HorzLayout")
local VertLayout = require("VertLayout")

local OptionsWindow = DialogLoader.spawnDialogFromFile(
    lfs.writedir() .. "Scripts\\SharkPlanner\\UI\\OptionsWindow.dlg"
)


local staticConfigurationSectionTitleSkin = SkinHelper.loadSkin("staticConfigurationSectionTitle")
local staticConfigurationOptionLabelSkin = SkinHelper.loadSkin("staticConfigurationOptionLabel")
local toggleConfigurationSidePanel = SkinHelper.loadSkin("toggleConfigurationSidePanel")
local checkBoxNewBlue = SkinHelper.loadSkin("checkBoxNewBlue")
local comboBoxSkin = SkinHelper.loadSkin("comboBox")

-- Constructor
function OptionsWindow:new(o)
    o = o or {}
    setmetatable(o, self)
    self.sectionPanels = {}
    self.__index = self
    local x, y, w, h = o.crosshairWindow:getBounds()

    Logging.debug("Creating options window")
    for i, section in ipairs(Configuration.sections) do
      Logging.debug("Adding sections: "..section.SectionName)
      local btn = self:createSectionButton(section)
      o.sidePanel:insertWidget(btn, o.sidePanel:getWidgetCount() + 1)
      -- create Panel for section content
      local sectionPanel = self:createSectionPanel(section)
      -- first section must be manually selected        
      if i == 1 then
        o.sectionContent:insertWidget(sectionPanel, o.sectionContent:getWidgetCount() + 1)
        o.sidePanel.selectedButton = btn
        btn:setState(true)
      end
    end
    o:setBounds(x - h - 80, y, w + 80, h)
    -- o:setVisible(true)
    return o
end

function OptionsWindow:createSectionButton(section)
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
      local currentWidget = self.sectionContent:getWidget(0)
      local newWidget = self.sectionPanels[button.sectionName]
      if newWidget ~= currentWidget then
        Logging.debug("Replacing content")
        self.sidePanel.selectedButton:setState(false)
        self.sidePanel.selectedButton = button
        self.sectionContent:removeWidget(currentWidget)
        self.sectionContent:insertWidget(newWidget)
      else
        Logging.debug("Clicked section is already active, ignoring")
        self.sidePanel.selectedButton:setState(true)
      end
    end
  )
  -- need to make sure that no controls hold focus so hotkeys can work
  btn:addMouseUpCallback(
    function(button)
      button:setFocused(false)
    end
  )

  return btn
end

function OptionsWindow:createSectionPanel(section)
  local sectionPanel = Panel.new()
  sectionPanel:setBounds(0,0,200,200)
  local sectionLayout = LayoutFactory.createLayout("vert", VertLayout.newLayout())
  sectionLayout:setGap(20)
  sectionLayout:setVertAlign(
    {
      ["offset"] = 0,
      ["type"] = "middle",
    }
  )
  sectionLayout:setHorzAlign(
    {
      ["offset"] = 0,
      ["type"] = "middle",
    }
  )
  sectionPanel:setLayout(sectionLayout)
  self.sectionPanels[section.SectionName] = sectionPanel
  for j, subSection in ipairs(section) do
    local subSectionPanel = self:createSubSectionPanel(section, subSection)
    sectionPanel:insertWidget(subSectionPanel)
  end
  return sectionPanel
end

function OptionsWindow:createSubSectionPanel(section, subSection)
  Logging.debug("Adding subsection: "..subSection.SectionName)
  local subSectionPanel = Panel.new()
  local subSectionLayout = LayoutFactory.createLayout("vert", VertLayout.newLayout())
  subSectionLayout:setGap(10)
  subSectionLayout:setVertAlign(
    {
      ["offset"] = 0,
      ["type"] = "middle",
    }
  )
  subSectionLayout:setHorzAlign(
    {
      ["offset"] = 0,
      ["type"] = "min",
    }
  )
  subSectionPanel:setLayout(subSectionLayout)
  local subSectionTitle = Static.new()
  subSectionTitle:setText(subSection.SectionName)
  subSectionTitle:setBounds(0,0,200,30)
  subSectionTitle:setVisible(true)
  subSectionTitle:setSkin(staticConfigurationSectionTitleSkin)
  subSectionPanel:insertWidget(subSectionTitle)
  for k, option in ipairs(subSection.Options) do
    Logging.debug("Adding option: "..option.Name)
    local optionPanel = self:createOptionPanel(section, subSection, option)
    subSectionPanel:insertWidget(optionPanel)
  end
  return subSectionPanel
end

function OptionsWindow:createOptionPanel(section, subSection, option)
  local optionPanel = Panel.new()
  local optionPanelLayout = LayoutFactory.createLayout("horz", HorzLayout.newLayout())

  optionPanelLayout:setGap(10)
  optionPanelLayout:setVertAlign(
    {
      ["offset"] = 0,
      ["type"] = "middle",
    }
  )
  optionPanelLayout:setHorzAlign(
    {
      ["offset"] = 0,
      ["type"] = "min",
    }
  )  
  -- local optionPanelLayout = LayoutFactory.createLayout("vert", VertLayout.newLayout())
  optionPanel:setLayout(optionPanelLayout)
  local optionLabel = Static.new()
  optionLabel:setText(option.Label)
  optionLabel:setSkin(staticConfigurationOptionLabelSkin)
  optionLabel:setVisible(true)
  optionPanel:insertWidget(optionLabel)

  local optionControl = self:createOptionControl(section, subSection, option)
  if optionControl then
    optionPanel:insertWidget(optionControl)
  end

  return optionPanel
end

function OptionsWindow:createOptionControl(section, subSection, option)
  local control = nil
  local configKey = section.SectionName.."."..subSection.SectionName.."."..option.Name
  local configValue = Configuration:getOption(configKey)
  Logging.debug("Creating: "..option.Control)
  if option.Control == "CheckBox" then
    control = self:createCheckBox(configKey, configValue)
  elseif option.Control == "ComboBox" then
    control = self:createComboBox(configKey, configValue, option)
  end
  if control ~= nil then
    control.key = configKey
  else
    Logging.error("Could not create control for option: "..configKey..", specified for: "..option.Control)
  end
  return control
end

function OptionsWindow:createCheckBox(configKey, configValue)
  local control = CheckBox.new()
  control:setSkin(checkBoxNewBlue)
  control:setState(configValue)
  control:addChangeCallback(
    function(control)
      Logging.debug("Modified: "..configKey.." to: "..tostring(control:getState()))
      Configuration:setOption(configKey, control:getState())
      Configuration:save()
    end
  )
  -- need to make sure that no controls hold focus so hotkeys can work
  control:addMouseUpCallback(
    function(control)
      control:setFocused(false)
    end
  )

  return control
end

function OptionsWindow:createComboBox(configKey, configValue, option)
  local control = ComboBox.new()
  control:clear()
  control:setVisible(true)
  control:setReadOnly(true)
  local selected = 0
  for i, item in ipairs(option.Items) do
    Logging.debug("Adding item: "..item.name)
    local listBoxItem = ListBoxItem.new(item.name)
    listBoxItem.value = item.value
    listBoxItem.index = i - 1
    if item.name == configValue then
      selected = i
    end
    control:insertItem(listBoxItem)
  end
  control:selectItem(control:getItem(selected - 1))
  control:setSkin(comboBoxSkin)
  control:addChangeListBoxCallback(
    function(control)      
      local value = control:getSelectedItem():getText()
      Logging.debug("Modified: "..configKey.." to: "..value)
      Configuration:setOption(configKey, value)
      Configuration:save()
    end
  )
  -- need to make sure that no controls hold focus so hotkeys can work
  control:addMouseUpCallback(
    function(control)
      control:setFocused(false)
    end
  )

  return control
end

function OptionsWindow:show()
  Logging.debug("Showing Options window")
    self:setVisible(true)
    -- -- show all widgets on status window
    -- local count = self:getWidgetCount()
  	-- for i = 1, count do
    --   local index 		= i - 1
  	--   local widget 		= self:getWidget(index)
    --   widget:setVisible(true)
    --   widget:setFocused(false)
    -- end
  end

function OptionsWindow:hide()
  Logging.debug("Hidding Options window")
  -- hide all widgets on status window
  -- local count = self:getWidgetCount()
  -- for i = 1, count do
  --   local index 		= i - 1
  --   local widget 		= self:getWidget(index)
  --   widget:setVisible(false)
  --   widget:setFocused(false)
  -- end
  -- self:setHasCursor(false)
  self:setVisible(false)
end

return OptionsWindow