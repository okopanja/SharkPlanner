local function is_in_values(inspected_table, inspected_value)
    for k, v in pairs(inspected_table) do
        if v == inspected_value then
            return true
        end
    end
    return false
end

local function is_in_keys(inspected_table, inspected_key)
    for k, v in pairs(inspected_table) do
        if k == inspected_key then
            return true
        end
    end
    return false
end

--from https://forum.cockos.com/showthread.php?t=221712
--from stackoverflow
--modified
local function clone(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[clone(orig_key)] = clone(orig_value)
        end
        setmetatable(copy, clone(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

return {
    is_in_keys = is_in_keys,
    is_in_values = is_in_values,
    clone = clone
}
