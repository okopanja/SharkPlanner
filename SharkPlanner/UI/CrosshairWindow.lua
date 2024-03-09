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
local Camera = require("SharkPlanner.Base.Camera")
local Position = require("SharkPlanner.Base.Position")
local Mathematics = require("SharkPlanner.Mathematics")
local SkinHelper = require("SharkPlanner.UI.SkinHelper")

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
    -- local staticCrosshairValueSkin = SkinHelper.loadSkin('staticCrosshairRightValue')
    local staticCrosshairValueSkin = SkinHelper.loadSkin('staticCrosshairRightLightValue')
    local staticCrosshairLightValueSkin = SkinHelper.loadSkin('staticCrosshairRightLightValue')
    o.ObjectModel:setSkin(staticCrosshairLightValueSkin)
    o.DistanceFromLast:setSkin(staticCrosshairValueSkin)
    o.Longitude:setSkin(staticCrosshairValueSkin)
    o.Latitude:setSkin(staticCrosshairValueSkin)
    o.Elevation:setSkin(staticCrosshairValueSkin)
    local screenWidth, screenHeight = dxgui.GetScreenSize()
    local x = math.floor(screenWidth/2) - 200
    local y = math.floor(screenHeight/2) - 200
    Logging.info("X: "..x.." Y: "..y)
    Logging.info("Setting bounds")
    o:setBounds(x, y, 400, 400)
    o:setTransparentForUserInput(true)
    Logging.info("Showing the crosshair window")
    o:setVisible(true)
    Camera:addEventHandler(Camera.EventTypes.CameraMoved, o, o.OnCameraMoved)
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

function CrosshairWindow:OnCameraMoved(eventArgs)
  if eventArgs.cameraState == Camera.CameraState.InMapView then
      Logging.debug("Camera moved!")
      local elevation = Export.LoGetAltitude(eventArgs.newPosition.p.x, eventArgs.newPosition.p.z)
      local geoCoordinates = Export.LoLoCoordinatesToGeoCoordinates(eventArgs.newPosition.p.x, eventArgs.newPosition.p.z)
      local position = Position:new{x = eventArgs.newPosition.p.x, y = eventArgs.newPosition.p.y, z = eventArgs.newPosition.p.z, longitude = geoCoordinates['longitude'], latitude = geoCoordinates['latitude'] }
      Logging.debug(position:getLongitudeDMSstr())
      Logging.debug(position:getLatitudeDMSstr())
      if #coordinateData.wayPoints > 0 then
        local distance = position:getDistanceFrom(coordinateData.wayPoints[#coordinateData.wayPoints])
        if distance > 1000 then
          self.DistanceFromLast:setText(string.format("%.3f km", distance / 1000))
        else
          self.DistanceFromLast:setText(string.format("%.1f m", distance))
        end
      else
        self.DistanceFromLast:setText("")
      end
      if #eventArgs.objects > 0 then
        self.ObjectModel:setText(eventArgs.objects[1].model)
      else
        self.ObjectModel:setText("")
      end
      self.Longitude:setText(position:getLongitudeDMSstr())
      self.Latitude:setText(position:getLatitudeDMSstr())
      self.Elevation:setText(string.format("%3.1f m", Mathematics.Arithmetic.round_with_precision(elevation, 1)))
  end
end

return CrosshairWindow
