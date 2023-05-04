local tileSize = 8

local imageGrass = love.graphics.newImage("assets/graphics/grass.png")

local tiles = {
	air = {
		graphic = nil
	},
	grass = {
		graphic = imageGrass,
		quads = {
			single = love.graphics.newQuad(0, 24, 8, 8, imageGrass),
			center = love.graphics.newQuad(8, 8, 8, 8, imageGrass),
			
			colHorzLeft = love.graphics.newQuad(0, 32, 8, 8, imageGrass),
			colHorzMiddle = love.graphics.newQuad(8, 24, 8, 8, imageGrass),
			colHorzRight = love.graphics.newQuad(8, 32, 8, 8, imageGrass),
			colVertTop = love.graphics.newQuad(16, 24, 8, 8, imageGrass),
			colVertCenter = love.graphics.newQuad(16, 32, 8, 8, imageGrass),
			colVertBottom = love.graphics.newQuad(16, 40, 8, 8, imageGrass),
			
			cornerTopLeft = love.graphics.newQuad(0, 0, 8, 8, imageGrass),
			cornerTopRight = love.graphics.newQuad(16, 0, 8, 8, imageGrass),
			cornerBottomLeft = love.graphics.newQuad(0, 16, 8, 8, imageGrass),
			cornerBottomRight = love.graphics.newQuad(16, 16, 8, 8, imageGrass),
			
			sideTop = love.graphics.newQuad(8, 0, 8, 8, imageGrass),
			sideBottom = love.graphics.newQuad(8, 16, 8, 8, imageGrass),
			sideLeft = love.graphics.newQuad(0, 8, 8, 8, imageGrass),
			sideRight = love.graphics.newQuad(16, 8, 8, 8, imageGrass)
		}
	}
}

return tiles