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

Level.settings = {}
-- tiles should always be square, so we only need one value
Level.settings.tileSize = 8
Level.settings.enableLOD = true

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

function Level:draw(viewportX, viewportY, viewportWidth, viewportHeight)
	local simplify = math.floor(math.sqrt(viewportWidth / 2^9) * 3) - 3
	simplify = simplify < 1 and 1 or simplify
	if not Level.settings.enableLOD then simplify = 1 end
	
	local view_1x = math.floor(viewportX / 8 + simplify)
	local view_1y = math.floor(viewportY / 8 + simplify)
	local view_2x = math.floor(viewportX / 8) + math.floor(viewportWidth / 8)
	local view_2y = math.floor(viewportY / 8) + math.floor(viewportHeight / 8)
	
	for y = view_1y, view_2y, simplify do
		for x = view_1x, view_2x, simplify do
			local tileData = levelTiles[self:getTile(x, y)]
			if tileData and tileData.graphic then
				if not tileData.quads then
					love.graphics.draw(tileData.graphic, (x - 1) * Level.settings.tileSize, (y - 1) * Level.settings.tileSize)
				else
					local neighbors = {}
					for _x = -1, 1 do
						neighbors[_x] = {}
						for _y = -1, 1 do
							neighbors[_x][_y] = self:getTile(x + _x * simplify, y + _y * simplify) == self:getTile(x, y)
						end
					end
					
					local usedQuad
					if neighbors[0][1] and neighbors[0][-1] and neighbors[1][0] and neighbors[-1][0] then
						usedQuad = tileData.quads.center
					elseif neighbors[0][1] and neighbors[0][-1] and neighbors[1][0] then
						usedQuad = tileData.quads.sideLeft
					elseif neighbors[0][1] and neighbors[0][-1] and neighbors[-1][0] then
						usedQuad = tileData.quads.sideRight
					elseif neighbors[1][0] and neighbors[-1][0] and neighbors[0][1] then
						usedQuad = tileData.quads.sideTop
					elseif neighbors[1][0] and neighbors[-1][0] and neighbors[0][-1] then
						usedQuad = tileData.quads.sideBottom
					elseif neighbors[1][0] and neighbors[0][1] then
						usedQuad = tileData.quads.cornerTopLeft
					elseif neighbors[-1][0] and neighbors[0][1] then
						usedQuad = tileData.quads.cornerTopRight
					elseif neighbors[1][0] and neighbors[0][-1] then
						usedQuad = tileData.quads.cornerBottomLeft
					elseif neighbors[-1][0] and neighbors[0][-1] then
						usedQuad = tileData.quads.cornerBottomRight
					elseif neighbors[1][0] and neighbors[-1][0] then
						usedQuad = tileData.quads.colHorzMiddle
					elseif neighbors[0][1] and neighbors[0][-1] then
						usedQuad = tileData.quads.colVertCenter
					elseif neighbors[1][0] then
						usedQuad = tileData.quads.colHorzLeft
					elseif neighbors[-1][0] then
						usedQuad = tileData.quads.colHorzRight
					elseif neighbors[0][1] then
						usedQuad = tileData.quads.colVertTop
					elseif neighbors[0][-1] then
						usedQuad = tileData.quads.colVertBottom
					else
						usedQuad = tileData.quads.single
					end
					
					love.graphics.draw(tileData.graphic, usedQuad, (x - 1) * Level.settings.tileSize, (y - 1) * Level.settings.tileSize, 0, simplify, simplify)
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