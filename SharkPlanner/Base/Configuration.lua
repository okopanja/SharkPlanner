local lfs = require("lfs")
local JSON = require("JSON")
local Logging = require("SharkPlanner.Utils.Logging")
local String = require("SharkPlanner.Utils.String")
local Table = require("SharkPlanner.Utils.Table")
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
    local updated = false
    Logging.info("Loading configuration from: "..FILEPATH)
    local fp = io.open(FILEPATH, "r")
    if fp then
        local rawBuffer = fp:read("*all")
        local loadedOptions = JSON:decode(rawBuffer)
        fp:close()
        Logging.debug("Default options keys")
        local defaultOptionKeys = self:_getOptionKeys(self.options)
        Logging.debug("Loaded options keys")
        local loadedOptionKeys = self:_getOptionKeys(loadedOptions)
        -- check if there are new options not existing in config file
        for k, v in pairs(defaultOptionKeys) do
            if Table.is_in_values(loadedOptionKeys, v) == false then
                Logging.warning("Option: "..v.." was not specified in configuration file.")
                updated = true
            end
        end
        -- check if there are options specified in config file, but absent in default configuration
        for k, v in pairs(loadedOptionKeys) do
            if Table.is_in_values(defaultOptionKeys, v) == false then
                Logging.warning("Option: "..v.." found in config file is not in use anymore.")
            end
        end
        -- overlay the file values over any already loaded defaults
        for i, v in ipairs(loadedOptionKeys) do            
            self:setOption(v, self:_getOption(loadedOptions, v))
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

function Configuration:getOption(option)
    return self:_getOption(self.options, option)
end

function Configuration:_getOption(options, option)
    local configPath = String.csplit(option, "%.")
    Logging.debug("Option has "..#configPath.." components.")
    local currentElement = options
    for i, currentElementPathComponent in ipairs(configPath) do
        Logging.debug("Path component: "..currentElementPathComponent)
        local nextElement = currentElement[currentElementPathComponent]
        if nextElement == nil then
            Logging.debug("Option '"..option.."' is not found.")
        elseif i == #configPath then
            -- reached the option, set option
            Logging.debug("Reached option")
            return currentElement[currentElementPathComponent]
        end
        currentElement = nextElement
    end
    return nil
end

function Configuration:setOption(option, value)
    return self:_setOption(self.options, option, value)
end

function Configuration:_setOption(options, option, value)
    local configPath = String.csplit(option, "%.")
    Logging.debug("Option has "..#configPath.." components.")
    local currentElement = options
    for i, currentElementPathComponent in ipairs(configPath) do
        Logging.debug("Path component: "..currentElementPathComponent)
        local nextElement = currentElement[currentElementPathComponent]
        if nextElement == nil and i < #configPath then
            -- create option if it does not exist
            Logging.debug("Creating path component...")
            nextElement = {}
            currentElement[currentElementPathComponent] = nextElement
        elseif i == #configPath then
            -- reached the option, set option
            Logging.debug("Reached option")
            currentElement[currentElementPathComponent] = value
        else
        end
        currentElement = nextElement
    end
end

function Configuration:_getOptionKeys(options)
    local keys = {}
    local stack = {}
    -- local currentKeyComponents = {}
    stack[#stack + 1] = { k = nil,  v = options, keyComponents = {} }
    while #stack > 0 do
        local current = table.remove(stack)
        if type(current.v) == 'table' then
            -- iterate over table
            for k, v in pairs(current.v) do
                -- place key value on value stack
                local keyComponents = {}
                for i, v in ipairs(current.keyComponents) do
                    keyComponents[i] = v
                end
                keyComponents[#keyComponents + 1] = k
                stack[#stack + 1] = { k = k, v = v, keyComponents = keyComponents}
            end
        else
            -- we reached terminal value, key should be constracted now
            local key = ""
            for i, v in ipairs(current.keyComponents) do
                if i == 1 then
                    key = v
                else
                    key = key.."."..v
                end
            end
            -- top level has key with "" and this is not needed
            if key ~= "" then
                Logging.debug("Added key: "..key)
                keys[#keys + 1] = key
            end
        end
    end
    return keys
end

function Configuration:registerConfigurationDefinition(configurationDefinition)
    local section = configurationDefinition.SectionName
    if section == nil then return end
    Logging.info("Setting configuration definition for section: "..section)
    -- if section is not defined initialize with default values
    if self.options[section] == nil and #configurationDefinition > 0 then
        Logging.info("Section does not exist, and section has defined defaults in configurationDefinition")
        -- if at least one entry is found, register section
        self.sections[#self.sections + 1] = configurationDefinition
        self.options[section] = {}
        for i, currentSectionDefinition in ipairs(configurationDefinition) do
            if type(currentSectionDefinition) == "table" then
                for j, currentOptionDefinition in ipairs(currentSectionDefinition.Options) do
                    self:_setOption(self.options, section.."."..currentSectionDefinition.SectionName.."."..currentOptionDefinition.Name, currentOptionDefinition.Default)
                end
            end
        end
    end
end


local generalConfiguration = {
    SectionName = "General",
    {
        SectionName = "Logging",
        Options = {
            {
                Name = "Verbosity",
                Label = "Verbosity level",
                Default = true,
                Control = "ComboBox"
            },
        }
    },
}

local singleton = Configuration:new{}
singleton:registerConfigurationDefinition(generalConfiguration)

-- Singleton since the result gets cached by require directive
return singleton
