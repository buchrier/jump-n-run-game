local GameEntity = {}

-- keep track of all GameEntities
-- this is part of the "class" table to allow external access
GameEntity.list = {}

-- a single object's metatable; define once to save memory
GameEntity_meta = {
	__index = Level
}

--****************
--[[
	GameEntities store their own values and are, among other things, subject to direct physics updates.
	This can result in a hit on performance if huge numbers of GameObjects are used.
	Thus, the immutable levelTiles should be used whenever possible.
]]
--****************

function GameEntity:__call(parameters) -- constructor function
	local self = setmetatable(parameters or {}, GameEntity_meta)
	
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

-- update single object
function GameEntity:update(dtMod)
	
end

-- draw single object
function GameEntity:draw()
	
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

return setmetatable(GameEntity, GameEntity)