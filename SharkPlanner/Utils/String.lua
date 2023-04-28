local function starts_with(str, start)
   return str:sub(1, #start) == start
end

local function ends_with(str, ending)
   return ending == "" or str:sub(-#ending) == ending
end

local function basename(filePath)
   return filePath:match("([^\\]+)$")
end

return {
  starts_with = starts_with,
  ends_with = ends_with,
  basename = basename
}
