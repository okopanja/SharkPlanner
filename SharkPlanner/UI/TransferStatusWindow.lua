-- provide sub-packages and modules
local Logging = require("SharkPlanner.Utils.Logging")
local DialogLoader = require("DialogLoader")
local dxgui = require('dxgui')
local lfs = require("lfs")
local SkinHelper = require("SharkPlanner.UI.SkinHelper")

local TransferStatusWindow = DialogLoader.spawnDialogFromFile(
    lfs.writedir() .. "Scripts\\SharkPlanner\\UI\\TransferStatusWindow.dlg"
)

-- Constructor
function TransferStatusWindow:new(o)
    Logging.info("Creating status window")
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    local x, y, w, h = o.crosshairWindow:getBounds()

    local statusSkin = SkinHelper.loadSkin("staticSkinSharkPlannerStatus")
    o.Status:setSkin(statusSkin)
    local screenWidth, screenHeight = dxgui.GetScreenSize()
    Logging.info("TransferStatusWindow: setting bounds below crosshair")
    self:setBounds(x, y + h, w, 110)
    Logging.info("Showing TransferStatusWindow")
    o:setVisible(true)

    return o
end

function TransferStatusWindow:show()
    self:setVisible(true)
    -- show all widgets on status window
    local count = self:getWidgetCount()
  	for i = 1, count do
      local index 		= i - 1
  	  local widget 		= self:getWidget(index)
      if widget ~= self.Status then
        widget:setVisible(true)
      end
    end
end

function TransferStatusWindow:hide()
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

function TransferStatusWindow:OnTransferStarted(eventArgs)
    self.ProgressBar:setValue(1)
    self.ProgressBar:setRange(1, #eventArgs.commands)
    self:show()
end

function TransferStatusWindow:OnTransferFinished(eventArgs)
    self:hide()
end

function TransferStatusWindow:OnTransferProgressUpdated(eventArgs)
    self.ProgressBar:setValue(eventArgs.totalCommandsCount - eventArgs.currentCommandCount)
end

return TransferStatusWindow
