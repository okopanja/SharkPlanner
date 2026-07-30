local BaseInputActionProcessor = require("SharkPlanner.Base.BaseInputActionProcessor")
local Logging = require("SharkPlanner.Utils.Logging")
local Table = require("SharkPlanner.Utils.Table")
local coordinateData = require("SharkPlanner.Base.CoordinateData")
local Command = require("SharkPlanner.Base.Command")
local Configuration = require("SharkPlanner.Base.Configuration")

local KA50InputActionProcessor = BaseInputActionProcessor:new()

local MAINPANEL_BUTTONS = {
    PVI_button_BTN_1 = 303,
    PVI_button_BTN_2 = 304,    
    PVI_button_BTN_3 = 305,    
    PVI_button_BTN_4 = 306,    
    PVI_button_BTN_5 = 307,    
    PVI_button_BTN_6 = 308,    
    PVI_button_BTN_7 = 309,    
    PVI_button_BTN_8 = 310,    
    PVI_button_BTN_9 = 311,    
    PVI_button_BTN_0 = 312,    
    PVI_button_ENTER = 313,
    PVI_button_CANCEL = 314,
    PVI_button_WPT = 315,
    PVI_button_FIXPT = 316,
    PVI_button_AERDR = 317,
    PVI_button_TGT = 318,
    PVI_button_FILAMBDA = 319,
    PVI_button_FIZ = 320,
    PVI_button_DU = 321,
    PVI_button_FII = 322,
    PVI_button_BRGRNG = 323,
    PVI_button_NAV_MASTER_MODES = 324,
    PVI_button_NAV_INU_FIX_METHOD = 325,
    PVI_button_NAV_DATALINK_POWER = 326,
    PVI_button_NAV_DATALINK_SELF_ID = 327,
    PVI_button_DATALINK_MASTER_MODE = 328,
    PVI_button_INSREALN = 519,
    PVI_button_PRECALN = 520,
    PVI_button_NORMALN = 521,
    PVI_button_INITCOORD = 522,
    PRC_button_CLEAR = 441,
}

function KA50InputActionProcessor:new(o)
    --o = BaseCommandGenerator:new()
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    local command_defs_path = lfs.currentdir()..[[Mods\aircraft\Ka-50_3\Cockpit\Scripts\command_defs.lua]]
    local input_events_path = lfs.currentdir()..[[Scripts\Input\InputEvents.lua]]
    local command_defs = tools.safeDoFileWithRequire(command_defs_path)
    o.Keys = command_defs.Keys
    o.DeviceCommands =  command_defs.device_commands
    o.monitoredActions = {
        o.Keys.PlaneDesignate_CageOn,
        o.Keys.PlaneDesignate_CageOff,
        o.Keys.PlaneNav_Targets,
        o.Keys.PlaneNav_PB1,
        o.Keys.PlaneNav_PB2,
        o.Keys.PlaneNav_PB3,
        o.Keys.PlaneNav_PB4,
        o.Keys.PlaneNav_PB5,
        o.Keys.PlaneNav_PB6,
        o.Keys.PlaneNav_PB7,
        o.Keys.PlaneNav_PB8,
        o.Keys.PlaneNav_PB9,
        o.Keys.PlaneNav_PB0_off,
        o.Keys.PlaneNav_PB1_off,
        o.Keys.PlaneNav_PB2_off,
        o.Keys.PlaneNav_PB3_off,
        o.Keys.PlaneNav_PB4_off,
        o.Keys.PlaneNav_PB5_off,
        o.Keys.PlaneNav_PB6_off,
        o.Keys.PlaneNav_PB7_off,
        o.Keys.PlaneNav_PB8_off,
        o.Keys.PlaneNav_PB9_off,
        o.Keys.PlaneNav_PB0_off,
        o.Keys.PlaneZoomIn,
        o.Keys.PlaneZoomOut,
        o.Keys.PlaneCancelWeaponsDelivery,
    }

    o.lastTime = 0
    o.slewed = false
    o.main_panel = Export.GetDevice(0)
    return o
end

function KA50InputActionProcessor:readMainPanelButtonStates()
    local states = {}
    for button, id in pairs(MAINPANEL_BUTTONS) do
        states[id] = self.main_panel:get_argument_value(id) 
    end
    return states
end

function KA50InputActionProcessor:processButtonStates(button_states)
    -- if TARGET mode is active
    if button_states[MAINPANEL_BUTTONS.PVI_button_TGT] > 0 then
        for i = MAINPANEL_BUTTONS.PVI_button_BTN_1, MAINPANEL_BUTTONS.PVI_button_BTN_0 do
            if button_states[i] > 0 then
                -- select target and stop processing
                self.selectedTarget = math.fmod((i - MAINPANEL_BUTTONS.PVI_button_BTN_1 + 1), 10)
                return
            end
        end
    -- if TARGET mode is inactive, clear the selected target
    else
        self.selectedTarget = nil
    end
    if button_states[MAINPANEL_BUTTONS.PRC_button_CLEAR] == 1 and self.slewed then
        Logging.info("Value: "..button_states[MAINPANEL_BUTTONS.PRC_button_CLEAR])
        self:clearSHKVAL()
    end
end

function KA50InputActionProcessor:clearSHKVAL()
    self.slewed = false
    Logging.info("Cleared SHKVAL")
end

function KA50InputActionProcessor:slewSHKVAL(commands)
    self.slewed = true
    if self.selectedTarget > #coordinateData.targetPoints then
        Logging.info("Selected target on PVI is not visible in SharkPlanner => SHKVAL is in the scan mode.")
    end
    Logging.info("SHKVAL slews toward target: "..self.selectedTarget)
    local targetPosition = coordinateData.targetPoints[self.selectedTarget]
    local selfData = Export.LoGetSelfData()
    local selfX = selfData["Position"]["x"]
    local selfZ = selfData["Position"]["z"]
    local selfY = selfData["Position"]["y"]
    local horizontalDistance = math.sqrt(((selfX - targetPosition:getX()) ^ 2) + ((selfZ - targetPosition:getZ()) ^ 2))
    local verticalDistance = selfY - targetPosition:getY()
    local dcsVerticalAngle = math.atan(selfY / horizontalDistance)
    local trueVerticalAngle = math.atan(verticalDistance / horizontalDistance)
    local correctionVerticalAngle = trueVerticalAngle - dcsVerticalAngle
    local dcsVerticalAngleControl = math.deg(dcsVerticalAngle)
    local trueVerticalAngleControl = math.deg(trueVerticalAngle)
    local correctionVerticaAngleControl = math.deg(correctionVerticalAngle)
    -- local intensity = 18.75 * correctionVerticaAngle
    -- local delay = 1000
    -- local intensity = 10 * 4.6 * correctionVerticaAngle
    local intensity = 10 * 4.6 * correctionVerticalAngle
    local intensity = 10 * 4.47 * correctionVerticalAngle
    local delay = 400
    local slewSpeed = math.abs(correctionVerticaAngleControl / delay) * 1000
    Logging.info("DCS vertical angle: "..dcsVerticalAngleControl)
    Logging.info("True vertical angle: "..trueVerticalAngleControl)
    Logging.info("Vertical correction angle: "..correctionVerticaAngleControl)
    Logging.info("Requested slew speed: "..slewSpeed.." °/s")
    -- request initial delay
    commands[#commands + 1] = Command:new():setName("NOP"):setComment(comment):setDevice(nil):setCode(nil):setDelay(Configuration:getOption("Ka-50.SHKVAL.InitialCorrectionDelay")):setIntensity(nil):setDepress(false)
    if self.zoomed == true then
        commands[#commands + 1] = Command:new():setName("SHKVAL: Zoom Out"):setDevice(8):setCode(self.Keys.PlaneZoomOut):setDelay(50):setIntensity(1):setDepress(false)    
        commands[#commands + 1] = Command:new():setName("NOP"):setComment(comment):setDevice(nil):setCode(nil):setDelay(Configuration:getOption("Ka-50.SHKVAL.InitialCorrectionDelay")):setIntensity(nil):setDepress(false)
    end
    -- move shkval vertically
    -- commands[#commands + 1] = Command:new():setName("SHKVAL: PlaneRadarVertical"):setDevice(8):setCode(self.Keys.PlaneRadarVerticalAbs):setDelay(delay):setIntensity(intensity):setDepress(true)
    commands[#commands + 1] = Command:new():setName("SHKVAL: PlaneRadarVertical"):setDevice(8):setCode(self.Keys.PlaneRadarVerticalAbs):setDelay(delay):setIntensity(intensity):setDepress(true)
    if self.zoomed == true then
        commands[#commands + 1] = Command:new():setName("SHKVAL: Zoom IN"):setDevice(8):setCode(self.Keys.PlaneZoomIn):setDelay(50):setIntensity(1):setDepress(true)
    end


    -- local shkval = Export.GetDevice(8)
    -- shkval:performClickableAction(self.Keys.PlaneRadarVerticalAbs, 1000)
    return commands
end

function KA50InputActionProcessor:process(inputActions)
    local commands = {}
    if Configuration:getOption("Ka-50.SHKVAL.EnableVerticalCorrection") == false then
        return commands
    end
    -- read state of buttons defined inside main panel
    local button_states = self:readMainPanelButtonStates()
    -- process states
    self:processButtonStates(button_states)
    -- process regular inputActions
    if #inputActions > 0 then
        for i, inputAction in ipairs(inputActions) do
            -- time field in inputAction represents OS uptime in miliseconds
            -- since none of the exposed functions provide this information inside lua environment, we will approximate it with time of the event. 
            if inputAction.time >= self.lastTime then
                -- advance the time
                self.lastTime = inputAction.time
                if Table.is_in_values(self.monitoredActions, inputAction.action) then                
                    -- Logging.debug("Recognized action: "..self:getDeviceEventName(inputAction))
                    if inputAction.action == self.Keys.PlaneDesignate_CageOff and button_states[MAINPANEL_BUTTONS.PVI_button_TGT] > 0 and self.selectedTarget ~= nil and self.slewed == false then
                        self:slewSHKVAL(commands)
                    elseif inputAction.action == self.Keys.PlaneCancelWeaponsDelivery and self.slewed then
                        self:clearSHKVAL()
                    elseif inputAction.action == self.Keys.PlaneZoomOut then
                        Logging.info("Zoomed out")
                        self.zoomed = false
                    elseif inputAction.action == self.Keys.PlaneZoomIn then
                        Logging.info("Zoomed in")
                        self.zoomed = true
                    end
                end
            end
        end
    end
    return commands

end

return KA50InputActionProcessor

