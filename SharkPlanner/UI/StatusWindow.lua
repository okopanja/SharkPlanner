-- provide sub-packages and modules
local Logging = require("SharkPlanner.Utils.Logging")
local coordinateData = require("SharkPlanner.Base.CoordinateData")
local DialogLoader = require("DialogLoader")
local dxgui = require('dxgui')
local Input = require("Input")
local lfs = require("lfs")
local Skin = require("Skin")
local SkinUtils = require("SkinUtils")
local window = nil

local StatusWindow = DialogLoader.spawnDialogFromFile(
    lfs.writedir() .. "Scripts\\SharkPlanner\\UI\\StatusWindow.dlg"
)

-- Constructor
function StatusWindow:new(o)
    Logging.info("Creating status window")
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    local x, y, w, h = o.crosshairWindow:getBounds()

    -- modify horizontal alignment
    local skin = self.Status:getSkin()
    skin.skinData.states.released[1].text.horzAlign.type = "min"
    self.Status:setSkin(skin)

    local screenWidth, screenHeight = dxgui.GetScreenSize()
    Logging.info("StatusWindow: setting bounds below crosshair")
    -- statusWindow:setBounds(x, y + h, w, 30)
    self:setBounds(x, y + h, w, 110)
    -- TODO: remove this and update external references
    self.statusStatic = self.Status
    self.versionInfoStatic = self.VersionInfo
    self.progressBar = self.ProgressBar
    -- self.versionInfoStatic:setText(SharkPlanner.VERSION_INFO)
    self.versionInfoStatic:setText(require("SharkPlanner.VersionInfo"))
    Logging.info("Showing StatusWindow")
    self:setVisible(true)
    return o
end

function StatusWindow:show()
    self:setVisible(true)
    -- show all widgets on status window
    local count = self:getWidgetCount()
  	for i = 1, count do
      local index 		= i - 1
  	  local widget 		= self:getWidget(index)
      if widget ~= self.ProgressBar then
        widget:setVisible(true)
      end
    end
end

function StatusWindow:hide()
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

function StatusWindow:OnAddWaypoint(eventArgs)
    self.statusStatic:setText("Waypoint added.")
end

function StatusWindow:OnRemoveWaypoint(eventArgs)
    self.statusStatic:setText("Waypoint removed.")
end

function StatusWindow:OnAddFixpoint(eventArgs)
    self.statusStatic:setText("Fixpoint added.")
end

function StatusWindow:OnRemoveFixpoint(eventArgs)
    self.statusStatic:setText("Fixpoint removed.")
end

function StatusWindow:OnAddTargetpoint(eventArgs)
    self.statusStatic:setText("Target added.") 
end

function StatusWindow:OnRemoveTargetpoint(eventArgs)
    self.statusStatic:setText("Target removed.") 
end

function StatusWindow:OnReset(eventArgs)
    self.statusStatic:setText("Reseted all captued data.") 
end

function StatusWindow:OnTransferStarted(eventArgs)
    self.statusStatic:setText("Transfer in progress...")
    self.progressBar:setValue(1)
    self.progressBar:setRange(1, #eventArgs.commands)
    self.progressBar:setVisible(true)
end

function StatusWindow:OnTransferFinished(eventArgs)
    self.statusStatic:setText("Transfer completed")
    self.progressBar:setVisible(false)
end

function StatusWindow:OnTransferProgressUpdated(eventArgs)
    self.progressBar:setValue(eventArgs.totalCommandsCount - eventArgs.currentCommandCount)
end

function StatusWindow:OnPlayerEnteredSupportedVehicle(eventArg)
    self.Status:setText("Entered: "..eventArg.aircraftModel)
end

return StatusWindow
