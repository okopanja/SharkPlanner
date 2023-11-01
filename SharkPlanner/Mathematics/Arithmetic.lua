local function round_with_precision(number, decimals)
    local scale = 10^decimals
    local c = 2^52 + 2^51
    return ((number * scale + c ) - c) / scale
end

return {
    round_with_precision = round_with_precision,
  }