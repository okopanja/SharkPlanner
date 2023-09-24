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

return {
    is_in_keys = is_in_keys,
    is_in_values = is_in_values
}
