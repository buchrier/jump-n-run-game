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
	This can result in a hit on performance if huge numbers of game entities are used.
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
	self.vy = self.vy + 0.3 * dtMod
	
	-- collision detection/handling:
	--[[ old code
	if self:collidesWithLevel(-4, -3) or self:collidesWithLevel(-4, 3) then -- left collision
		self.vx = 0
		self.x = math.floor(self.x / 8) * 8 + 4
	end
	if self:collidesWithLevel(4, -3) or self:collidesWithLevel(4, 3) then -- right collision
		self.vx = 0
		self.x = math.floor(self.x / 8) * 8 + 4
	end
	if self:collidesWithLevel(-3, 4) or self:collidesWithLevel(3, 4) then -- down collision
		self.vy = 0
		self.y = math.floor(self.y / 8) * 8 + 4
	end
	if  then -- up collision
		self.vy = 0
		self.y = math.floor(self.y / 8) * 8 + 4
	end
	
	-- check whether game entity is stuck in a tile
	if self:collidesWithLevel(0, 0) then
		-- try to find an empty nearby tile
		local clipWasFixed = false
		for oy = -1, 1 do
			for ox = -1, 1 do
				if not self:collidesWithLevel(ox * 8, oy * 8) then
					self.x = self.x + ox * 8
					self.y = self.y + oy * 8
					clipWasFixed = true
					break
				end
			end
		end
		if not clipWasFixed then
			self.y = self.y - 8
		end
	end
	]]
	
	local iterationCount = 0
	local addX, addY = 0, 0
	repeat
		iterationCount = iterationCount + 1
		local doRecheck = false
		
		if self:collidesWithLevel(-3 + addX, 4 + addY) or self:collidesWithLevel(3 + addX, 4 + addY) then
			self.vy = 0
			addY = addY - 0.1
			doRecheck = true
		end
		if self:collidesWithLevel(-3 + addX, -4 + addY) or self:collidesWithLevel(3 + addX, -4 + addY) then
			self.vy = 0
			addY = addY + 0.1
			doRecheck = true
		end
		if self:collidesWithLevel(-4 + addX, -3 + addY) or self:collidesWithLevel(-4 + addX, 3 + addY) then
			self.vx = 0
			addX = addX + 0.1
			doRecheck = true
		end
		if self:collidesWithLevel(4 + addX, -3 + addY) or self:collidesWithLevel(4 + addX, 3 + addY) then
			self.vx = 0
			addX = addX - 0.1
			doRecheck = true
		end
	until (not doRecheck) or iterationCount > 8
	self.x = self.x + addX
	self.y = self.y + addY
	
	self.x = self.x + self.vx * dtMod
	self.y = self.y + self.vy * dtMod
	
	self.vx = self.vx * (0.95 ^ dtMod)
	self.vy = self.vy * (0.95 ^ dtMod)
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