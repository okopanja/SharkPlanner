local Logging = require("SharkPlanner.Utils.Logging")

local TerrainHelper = {}


-- helper function to read list of subfolders of modules
function TerrainHelper:enumerateTerrainPaths()
    local result = {}
    local path = lfs.currentdir()..[[Mods\terrains]]
    for file in lfs.dir(path) do
      local full_path = path.."\\"..file
      if lfs.attributes(full_path, "mode") == "directory" then
        if file ~= '.' and file ~= '..' then
          result[#result+1] = { full_path = full_path, id = file }
        end
      end
    end
    return result
end

function TerrainHelper:loadTerrains(terrainPaths)
    self.terrains = {}
    for i, entry in ipairs(terrainPaths) do
        local towns = tools.safeDoFileWithRequire(entry.full_path..[[\Map\towns.lua]]).towns
        self.terrains[entry.id] = {
            path = entry.full_path,
            towns = towns
        }
    end
end

function TerrainHelper:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    local terrainPaths = o:enumerateTerrainPaths()
    o:loadTerrains(terrainPaths)
    return o
end

function TerrainHelper:lookupNearestTown(terrainID, position)
    local terrain = self.terrains[terrainID]
    local nearestTown = nil
    local nearestDistance = nil
    Logging.debug("Searching...")
    for name, town in pairs(terrain.towns) do
        if town.x == nil or town.z == nil then
            Logging.debug("Updating coordinates...")
            local localCoordinates = Export.LoGeoCoordinatesToLoCoordinates(town.longitude, town.latitude)
            town.x = localCoordinates.x
            town.z = localCoordinates.z
        end
        local distance = math.sqrt((town.x - position.x)^2 + (town.z - position.z)^2)
        if nearestDistance == nil or distance < nearestDistance then
            Logging.debug("Found nearer place")
            nearestDistance = distance
            nearestTown = town
        end
    end
    return nearestTown
end

local singleton = TerrainHelper:new()

return singleton