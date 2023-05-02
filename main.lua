local Level = require("classes.Level")
local GameEntity = require("classes.GameEntity")

local boolAsInt = {[true] = 1, [false] = 0}

love.window.setMode(0, 0, {fullscreen = true})

-- full screen resolution
local screenResolution = {w = love.graphics.getWidth(), h = love.graphics.getHeight()}

--****************

local gameCanvasSize = {w = 512, h = 512}
local gameCanvas = love.graphics.newCanvas(512, 512)

local cam = {x = 0, y = 0, z = 1}

local currentLevel = Level()
currentLevel:setTile(1, 1, "grass00")
currentLevel:setTile(2, 1, "grass10")
currentLevel:setTile(3, 1, "grass20")
currentLevel:setTile(1, 2, "grass01")
currentLevel:setTile(2, 2, "grass11")
currentLevel:setTile(3, 2, "grass21")
currentLevel:setTile(1, 3, "grass02")
currentLevel:setTile(2, 3, "grass12")
currentLevel:setTile(3, 3, "grass22")

--****************

-- on each frame: handle physics, ...
function love.update(dt)
	local dtMod = dt * 60
	
	cam.x = cam.x + (boolAsInt[love.keyboard.isDown("d")] - boolAsInt[love.keyboard.isDown("a")]) * dtMod
	cam.y = cam.y + (boolAsInt[love.keyboard.isDown("s")] - boolAsInt[love.keyboard.isDown("w")]) * dtMod
	
	if love.keyboard.isDown("+") then
		cam.z = cam.z * (1.1 ^ dtMod)
	elseif love.keyboard.isDown("-") then
		cam.z = cam.z / (1.1 ^ dtMod)
	end
	
	currentLevel:update(dtMod)
	GameEntity.updateAll(dtMod)
end

-- handle single keypresses
function love.keypressed(key)
	if key == "escape" then
		love.event.push("quit") -- close game
	elseif key == "f4" then
		love.window.setFullscreen(not love.window.getFullscreen()) -- enter/leave fullscreen
	end
end

-- on each frame: draw game world, UI, ...
love.graphics.setBackgroundColor(0, 0.5, 1)
function love.draw()
	love.graphics.push("all")
	gameCanvas:renderTo(function() -- render game world
		love.graphics.clear()
		love.graphics.translate(gameCanvasSize.w / 2, gameCanvasSize.h / 2)
		love.graphics.scale(cam.z, cam.z)
		love.graphics.translate(-cam.x, -cam.y)
		love.graphics.setColor(1, 1, 1)
		currentLevel:draw()
		GameEntity.drawAll()
	end)
	love.graphics.pop()
	
	-- transform graphics origin to screen center
	love.graphics.translate(screenResolution.w / 2, screenResolution.h / 2)
	-- draw game canvas proportionally upscaled to screen height
	local yScaleFactor = screenResolution.h / gameCanvasSize.h
	love.graphics.draw(gameCanvas, 0, 0, 0,
		yScaleFactor, yScaleFactor,
		gameCanvasSize.w / 2, gameCanvasSize.h / 2
	)
end