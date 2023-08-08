local lfs = require("lfs")
local JSON = require("JSON")
local Logging = require("SharkPlanner.Utils.Logging")
local FILEPATH = lfs.writedir()..[[Config\SharkPlanner.json]]

local Configuration = {}

function Configuration:new (o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  o.options = {}
  o.sections = {}
  return o
end

function Configuration:load()
    Logging.info("Pre-setting default configuration options")
    local updated = false
    for section, configurationDefinition in pairs(self.sections) do
        -- in which case we need to ensure that all required options are set
        for i, currentOptionDefinition in ipairs(configurationDefinition) do
            -- create any non existing option
            Logging.info("Ensure that option: "..section.."."..currentOptionDefinition.Name.." is set to default value: "..tostring(currentOptionDefinition.Default))
            if self:getOption(section, currentOptionDefinition.Name) == nil then
                self:setOption(section, currentOptionDefinition.Name, currentOptionDefinition.Default)
                updated = true
            end
        end
    end

    Logging.info("Loading configuration from: "..FILEPATH)
    local fp = io.open(FILEPATH, "r")
    if fp then
        local rawBuffer = fp:read("*all")
        local loadedOptions = JSON:decode(rawBuffer)
        fp:close()
        -- overlay the file values over any already loaded defaults
        for sectionName, section in pairs(loadedOptions) do
            for optionName, option in pairs(section) do
                self.options[sectionName][optionName] = option
            end
        end
        Logging.info("Loaded configuration")
    end
    return updated
end

function Configuration:save()
    Logging.info("Saving configuration to "..FILEPATH)
    local fp = io.open(FILEPATH, 'w')
    if fp then
        fp:write(JSON:encode_pretty(
                self.options
            )
        )
        fp:close()
        Logging.info("Saved configuration")
    end
end

function Configuration:exists()
    return lfs.attributes(FILEPATH) ~= nil
end

function Configuration:getOption(section, option)
    if self.options[section] ~= nil then
        if self.options[section][option] ~= nil then
            return self.options[section][option]
        end
    end
    return nil
end

function Configuration:setOption(section, option, value)
    -- create section if it does not exist
    if self.options[section] == nil then
        self.options[section] = {}
    end
    -- set option within option
    self.options[section][option] = value
end

function Configuration:setConfigurationDefinition(section, configurationDefinition)
    Logging.info("Setting configuration definition for section: "..section)
    -- if section is not defined initialize with default values
    if self.options[section] == nil and #configurationDefinition > 0 then
        Logging.info("Section does not exist, and section has defaults in configurationDefinition")
        -- if at least one entry is found, register section
        self.sections[section] = configurationDefinition
        self.options[section] = {}
        for i, currentOptionDefinition in ipairs(configurationDefinition) do
            self.options[section][currentOptionDefinition.Name] = currentOptionDefinition.Default
        end

    end
end

-- Singleton since the result gets cached by require directive
return Configuration:new{}
