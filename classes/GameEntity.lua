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
	return currentLevel:getTile(Level.coordsToTilePosition(self.x + (xOffset or 0), self.y + (yOffset or 0))) ~= "air"
end

function GameEntity:checkCollisions()
	local limitX = 1 / math.abs(self.vy)
	limitX = limitX < 3.5 and limitX or 3.5
	local limitY = 1 / math.abs(self.vx)
	limitY = limitY < 3.5 and limitY or 3.5
	local down	= self:collidesWithLevel(-limitX, 4)	or self:collidesWithLevel(limitX, 4)
	local right	= self:collidesWithLevel(4, -limitY)	or self:collidesWithLevel(4, limitY)
	local up	= self:collidesWithLevel(-limitX, -4)	or self:collidesWithLevel(limitX, -4)
	local left	= self:collidesWithLevel(-4, -limitY)	or self:collidesWithLevel(-4, limitY)
	return down, right, up, left
end

-- update single object
function GameEntity:update(dtMod)	
	-- collision detection/handling:
	local doRecheck
	local checkCount = 0
	repeat
		doRecheck = false
		local down, right, up, left = self:checkCollisions()
		
		local handlers = {
			{vel = self.vy > 0 and 0 or self.vy, fct = function()
				if down then
					self.vy = self.vy > 0 and 0 or self.vy
					self.y = self.y - 0.1
					doRecheck = true
				end
			end},
			{vel = self.vx > 0 and 0 or self.vx, fct = function()
				if right then
					self.vx = self.vx > 0 and 0 or self.vx
					self.x = self.x - 0.1
					doRecheck = true
				end
			end},
			{vel = self.vy < 0 and 0 or self.vy, fct = function()
				if up then
					self.vy = self.vy < 0 and 0 or self.vy
					self.y = self.y + 0.1
					doRecheck = true
				end
			end},
			{vel = self.vx < 0 and 0 or self.vx, fct = function()
				if left then
					self.vx = self.vx < 0 and 0 or self.vx
					self.x = self.x + 0.1
					doRecheck = true
				end
			end}
		}
		
		table.sort(handlers, function(a, b)
			return math.abs(a.vel) > math.abs(b.vel)
		end)
		
		handlers[1].fct()
		handlers[2].fct()
		handlers[3].fct()
		handlers[4].fct()
		
		checkCount = checkCount + 1
	until (not doRecheck) or checkCount > 100
	
	self.vy = self.vy + 0.3 * dtMod
	
	self.x = self.x + self.vx * dtMod
	self.y = self.y + self.vy * dtMod
	
	self.vx = self.vx * (0.95 ^ dtMod)
	self.vy = self.vy * (0.95 ^ dtMod)
	
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
end

-- draw single object
function GameEntity:draw()
	local drawX = math.floor(self.x + 0.5)
	local drawY = math.floor(self.y + 0.5)
	love.graphics.rectangle("fill", drawX - 4, drawY - 4, 8, 8)
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