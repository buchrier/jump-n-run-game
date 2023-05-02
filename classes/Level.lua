local levelTiles = require("assets.data.levelTiles")

for key, tile in pairs(levelTiles) do
	if tile.graphic then
		tile.graphic:setFilter("nearest")
	end
end

local Level = {}

-- a single object's metatable; define once to save memory
Level_meta = {
	__index = Level
}

-- tiles should always be square, so we only need one value
local levelTileSize = 8

--****************
--[[
	For performance reasons, level tiles do NOT store individual data!
	Their values are constants that are stored in assets.data.levelTiles.
	If individual values are required, use a GameEntity.
]]
--****************

function Level:__call(parameters) -- constructor function
	local self = setmetatable(parameters or {}, Level_meta)
	
	self.size = {}
	self.size.w = self.width or 64
	self.size.h = self.height or 16
	
	self.tiles = {}
	for i = 1, self.size.w * self.size.h do
		self.tiles[i] = "air"
	end
	 
	return self
end

function Level:getTile(x, y)
	x = x % self.size.w + 1
	y = y % self.size.h + 1
	return self.tiles[(y - 1) * self.size.w + x]
end

function Level:setTile(x, y, value)
	x = x % self.size.w + 1
	y = y % self.size.h + 1
	self.tiles[(y - 1) * self.size.w + x] = value
end

function Level:update(dtMod)
	
end

function Level:draw()
	for y = 1, self.size.h do
		for x = 1, self.size.w do
			local tileData = levelTiles[self:getTile(x, y)]
			if tileData and tileData.graphic then
				if tileData.quad then
					love.graphics.draw(tileData.graphic, tileData.quad, (x - 1) * levelTileSize, (y - 1) * levelTileSize)
				else
					love.graphics.draw(tileData.graphic, (x - 1) * levelTileSize, (y - 1) * levelTileSize)
				end
			end
		end
	end
end

--****************

return setmetatable(Level, Level)