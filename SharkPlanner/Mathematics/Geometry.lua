local math = require("math")
local Arithmetic = require("SharkPlanner.Mathematics.Arithmetic")
local round_with_precision = Arithmetic.round_with_precision
local DEBUG = false

local function enable_debug()
    DEBUG = true
end

local function round_dms(dms)
    if dms.seconds >=60 then
        dms.seconds = 0
        dms.minutes = dms.minutes + 1
    end
    if dms.minutes >=60 then
        dms.minutes = 0
        dms.degrees = dms.degrees + 1
    end
end

local function degAngleToDMSAngle(decimal, degrees_precision, minutes_precision, seconds_precision)
    local result = {
        sign = 1,
        degrees = 0,
        minutes = 0,
        seconds = 0
    }
    degrees_precision = degrees_precision or 0
    local degrees_precision_multiplier = 10 ^ (degrees_precision + 16)

    result.sign = decimal < 0 and -1 or 1

    local degrees = math.abs(decimal)
    local degrees_rounded = minutes_precision == nil and round_with_precision(degrees, degrees_precision) or math.floor(degrees)

    local degrees_fraction = ((degrees * degrees_precision_multiplier) - (degrees_rounded * degrees_precision_multiplier)) / degrees_precision_multiplier
    if DEBUG then
        print(
            "degree: "..degrees..", "..
            "degree_rounded: "..degrees_rounded..", "..
            "degree_fraction: "..degrees_fraction
        )
    end
    result.degrees = degrees_rounded

    if degrees_fraction <= 0 or minutes_precision == nil then
        round_dms(result)
        return result
    end

    local minutes_precision_multiplier = 10 ^ (minutes_precision + 16)

    -- assert(degrees_fraction >= 0)

    local minutes = degrees_fraction * 60
    local minutes_rounded = seconds_precision == nil and round_with_precision(minutes, minutes_precision) or math.floor(minutes)
    -- local minutes_rounded = round(minutes, minute_precision)
    local minutes_fraction = ((minutes * minutes_precision_multiplier) - (minutes_rounded * minutes_precision_multiplier)) / minutes_precision_multiplier
    if DEBUG then
        print(
            "minutes: "..minutes..", "..
            "minutes_rounded: "..minutes_rounded..", "..
            "minutes_fraction: "..minutes_fraction
        )
    end
    result.minutes = minutes_rounded
    if minutes_fraction <= 0 or seconds_precision == nil then
        round_dms(result)
        return result
    end
    local seconds_precision_multiplier = 10 ^ (seconds_precision + 16)

    local seconds = minutes_fraction * 60
    local seconds_rounded = round_with_precision(seconds, seconds_precision)
    local seconds_fraction = ((seconds * seconds_precision_multiplier) - (seconds_rounded * seconds_precision_multiplier)) / seconds_precision_multiplier
    if DEBUG then
        print(
            "seconds: "..seconds..", "..
            "seconds_rounded: "..seconds_rounded..", "..
            "seconds_fraction: "..seconds_fraction
        )
    end
    result.seconds = seconds_rounded
    round_dms(result)
    return result
end

return {
    enable_debug = enable_debug,
    round_dms = round_dms,
    degAngleToDMSAngle = degAngleToDMSAngle,
}