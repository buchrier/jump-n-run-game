local Level = require("classes.Level")

--****************

local GameEntity = {}

-- keep track of all GameEntities
-- this is part of the "class" table to allow external access
GameEntity.list = {}

-- a single object's metatable; define once to save memory
GameEntity_meta = {
	__index = GameEntity
}

--****************
--[[
	GameEntities store their own values and are, among other things, subject to direct physics updates.
	This can result in a hit on performance if huge numbers of GameObjects are used.
	Thus, the immutable levelTiles should be used whenever possible.
]]
--****************

local currentLevel

--****************

function GameEntity:__call(parameters) -- constructor function
	local self = setmetatable(parameters or {}, GameEntity_meta)
	
	self.x = self.x or 0
	self.y = self.y or 0
	self.vx = self.vx or 0
	self.vy = self.vy or 0
	
	table.insert(GameEntity.list, self)
	return self
end

-- this only removes the object from the member list; other references persist!
function GameEntity:destroy()
	for key, entity in ipairs(GameEntity.list) do
		if entity == self then
			table.remove(GameEntity.list, key)
			break
		end
	end
end

function GameEntity:collidesWithLevel(xOffset, yOffset)
	return currentLevel:getTile(Level.coordsToTilePosition(self.x + self.vx + (xOffset or 0), self.y + self.vy + (yOffset or 0))) ~= "air"
end

-- update single object
function GameEntity:update(dtMod)
	self.vy = self.vy + 0.3
	
	-- collision handling
	if self:collidesWithLevel(-3.9, 4) or self:collidesWithLevel(3.9, 4) then
		self.vy = 0
		while self:collidesWithLevel(-4, 4) or self:collidesWithLevel(4, 4) do
			self.y = self.y - 0.01
		end
		while not (self:collidesWithLevel(-4, 4) or self:collidesWithLevel(4, 4)) do
			self.y = self.y + 0.01
		end
	end
	
	self.x = self.x + self.vx * dtMod
	self.y = self.y + self.vy * dtMod
	
	self.vx = self.vx * (0.9 ^ dtMod)
	self.vy = self.vy * (0.9 ^ dtMod)
end

-- draw single object
function GameEntity:draw()
	love.graphics.rectangle("fill", self.x - 4, self.y - 4, 8, 8)
end

--****************

-- update members
function GameEntity.updateAll(dtMod)
	for key, entity in ipairs(GameEntity.list) do
		entity:update(dtMod)
	end
end

-- draw members
function GameEntity.drawAll()
	for key, entity in ipairs(GameEntity.list) do
		entity:draw()
	end
end

-- this scope needs to know the current level for collision detection
function GameEntity.setLevel(level)
	currentLevel = level
end

return setmetatable(GameEntity, GameEntity)