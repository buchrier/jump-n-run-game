local tileSize = 8

local tiles = {
	air = {
		graphic = nil
	}
}

local function assembleTilemap(imgName)
	local img = love.graphics.newImage("assets/graphics/" .. imgName .. ".png")
	for y = 1, img:getHeight() / tileSize do
		for x = 1, img:getWidth() / tileSize do
			tiles[imgName .. x - 1 .. y - 1] = {
				graphic = img,
				quad = love.graphics.newQuad((x - 1) * tileSize, (y - 1) * tileSize, tileSize, tileSize, img)
			}
		end
	end
end

assembleTilemap("grass")

return tiles