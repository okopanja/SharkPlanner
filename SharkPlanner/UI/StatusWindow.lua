-- provide sub-packages and modules
local Logging = require("SharkPlanner.Utils.Logging")
local DialogLoader = require("DialogLoader")
local dxgui = require('dxgui')
local lfs = require("lfs")
local SkinHelper = require("SharkPlanner.UI.SkinHelper")

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

    local statusSkin = SkinHelper.loadSkin("staticSkinSharkPlannerStatus")
    o.Status:setSkin(statusSkin)
    local versionSkin = SkinHelper.loadSkin("staticSkinSharkPlannerVersion")
    o.VersionInfo:setSkin(versionSkin)
    local screenWidth, screenHeight = dxgui.GetScreenSize()
    Logging.info("StatusWindow: setting bounds below crosshair")
    self:setBounds(x, y + h, w, 110)
    o.VersionInfo:setText(require("SharkPlanner.VersionInfo"))
    Logging.info("Showing StatusWindow")
    o:setVisible(true)

    return o
end

function StatusWindow:show()
    self:setVisible(true)
    -- show all widgets on status window
    local count = self:getWidgetCount()
  	for i = 1, count do
        local index 		= i - 1
  	    local widget 		= self:getWidget(index)
        widget:setVisible(true)
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
    self.Status:setText("Waypoint added.")
end

function StatusWindow:OnRemoveWaypoint(eventArgs)
    self.Status:setText("Waypoint removed.")
end

function StatusWindow:OnAddFixpoint(eventArgs)
    self.Status:setText("Fixpoint added.")
end

function StatusWindow:OnRemoveFixpoint(eventArgs)
    self.Status:setText("Fixpoint removed.")
end

function StatusWindow:OnAddTargetpoint(eventArgs)
    self.Status:setText("Target added.") 
end

function StatusWindow:OnRemoveTargetpoint(eventArgs)
    self.Status:setText("Target removed.") 
end

function StatusWindow:OnReset(eventArgs)
    self.Status:setText("Reseted all captued data.") 
end

function StatusWindow:OnTransferStarted(eventArgs)
    self.Status:setText("Transfer in progress...")
end

function StatusWindow:OnTransferFinished(eventArgs)
    self.Status:setText("Transfer completed")
end

function StatusWindow:OnPlayerEnteredSupportedVehicle(eventArg)
    self.Status:setText("Entered: "..eventArg.aircraftModel)
end

function StatusWindow:OnFlightPlanSaved(eventArgs)
    self.Status:setText("Flight plan is saved.")
end

function StatusWindow:OnFlightPlanLoaded(eventArgs)
    self.Status:setText("Flight plan is loaded.")
end

function StatusWindow:displayMessage(message)
    self.Status:setText(message)
end

return StatusWindow
