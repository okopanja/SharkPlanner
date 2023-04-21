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

local CrosshairWindow = DialogLoader.spawnDialogFromFile(
    lfs.writedir() .. "Scripts\\SharkPlanner\\UI\\CrosshairWindow.dlg"
)

-- Constructor
function CrosshairWindow:new(o)
    Logging.info("Creating status window")
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    local skin = o.WaypointCrosshair:getSkin()
    local crosshair_picture_path = lfs.writedir()..skin.skinData.states.released[1].picture.file
    Logging.info("Path to crosshair picture: "..crosshair_picture_path)
    o.WaypointCrosshair:setSkin(SkinUtils.setStaticPicture(crosshair_picture_path, skin))


    local screenWidth, screenHeight = dxgui.GetScreenSize()
    local x = math.floor(screenWidth/2) - 200
    local y = math.floor(screenHeight/2) - 200    
    Logging.info("X: "..x.." Y: "..y)
    Logging.info("Setting bounds")
    o:setBounds(x, y, 400, 400)
    o:setTransparentForUserInput(true)
    Logging.info("Showing the crosshair window")
    o:setVisible(true)

    return o
end

function CrosshairWindow:show()
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

function CrosshairWindow:hide()
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

return CrosshairWindow
