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
Level.tileSize = 8

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
	if x < 1 or y < 1 or x > self.size.w or y > self.size.h then return "air" end
	return self.tiles[(y - 1) * self.size.w + x]
end

function Level:setTile(x, y, value)
	x = x % self.size.w
	y = y % self.size.h
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
					love.graphics.draw(tileData.graphic, tileData.quad, (x - 1) * Level.tileSize, (y - 1) * Level.tileSize)
				else
					love.graphics.draw(tileData.graphic, (x - 1) * Level.tileSize, (y - 1) * Level.tileSize)
				end
			end
		end
	end
end

--****************

function Level.coordsToTilePosition(x, y)
	return math.floor(x / 8 + 1), math.floor(y / 8 + 1)
end

return setmetatable(Level, Level)