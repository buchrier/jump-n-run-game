local Level = require("classes.Level")
local GameEntity = require("classes.GameEntity")

local boolAsInt = {[true] = 1, [false] = 0}

love.window.setMode(512, 512, {fullscreen = false, resizable = true})

-- full window resolution
local windowResolution = {w = love.graphics.getWidth(), h = love.graphics.getHeight()}

--****************

local gameCanvasSize = {w = 512, h = 512}
local gameCanvas = love.graphics.newCanvas(512, 512)

local cam = {x = 0, y = 0, targetX = 0, targetY = 0, z = 1}

local player = GameEntity{x = 128, y = -64}

local currentLevel = Level{width = 2^9, height = 2^9}
for y = 1, currentLevel.size.h do
	for x = 1, currentLevel.size.w do
		currentLevel:setTile(x, y, love.math.noise(x * 0.01, y * 0.01) > 0.5 and "grass" or "air")
	end
end
GameEntity.setLevel(currentLevel)

--****************

-- on each frame: handle physics, ...
function love.update(dt)
	local dtMod = dt * 60
	
	player.vx = player.vx + (boolAsInt[love.keyboard.isDown("d")] - boolAsInt[love.keyboard.isDown("a")]) * 0.2 * dtMod
	
	if love.keyboard.isDown("space") and (player:collidesWithLevel(-3, 4) or player:collidesWithLevel(3, 4)) then
		player.vy = -8
	end
	
	cam.targetX = player.x
	cam.targetY = player.y
	
	cam.x = cam.x + (cam.targetX - cam.x) * 5 * dt
	cam.y = cam.y + (cam.targetY - cam.y) * 5 * dt
	
	if love.keyboard.isDown("+") then
		cam.z = cam.z * (1.1 ^ dtMod)
	end
	if love.keyboard.isDown("-") then
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

-- fires when window is resized
function love.resize(w, h)
	windowResolution.w = w
	windowResolution.h = h
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
		currentLevel:draw(cam.x - gameCanvasSize.w/2 / cam.z, cam.y - gameCanvasSize.h/2 / cam.z, gameCanvasSize.w / cam.z + 32, gameCanvasSize.h / cam.z + 32)
		GameEntity.drawAll()
		
		love.graphics.setColor(1, 0, 0)
		love.graphics.line(player.x, player.y, player.x + player.vx * 4, player.y + player.vy * 4)
		
		love.graphics.origin()
	end)
	love.graphics.pop()
	
	-- transform graphics origin to screen center
	love.graphics.translate(windowResolution.w / 2, windowResolution.h / 2)
	-- draw game canvas proportionally upscaled to window size
	local scaleFactor
	if windowResolution.w > windowResolution.h then
		scaleFactor = windowResolution.h / gameCanvasSize.h
	else -- windowResolution.w <= windowResolution.h
		scaleFactor = windowResolution.w / gameCanvasSize.w
	end
	love.graphics.draw(gameCanvas, 0, 0, 0,
		scaleFactor, scaleFactor,
		gameCanvasSize.w / 2, gameCanvasSize.h / 2
	)
end