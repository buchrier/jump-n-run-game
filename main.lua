local Level = require("classes.Level")
local GameEntity = require("classes.GameEntity")

local boolAsInt = {[true] = 1, [false] = 0}

love.window.setMode(512, 512, {fullscreen = false, resizable = true})

-- full window resolution
local windowResolution = {w = love.graphics.getWidth(), h = love.graphics.getHeight()}

--****************

local gameCanvasSize = {w = 512, h = 512}
local gameCanvas = love.graphics.newCanvas(512, 512)

local windowToWorldTransform = love.math.newTransform()

local cam = {x = 0, y = 0, targetX = 0, targetY = 0, z = 1}

local player = GameEntity{x = 128, y = -64}

local currentLevel = Level{width = 2^8, height = 2^8}
for y = 1, currentLevel.size.h do
	for x = 1, currentLevel.size.w do
		currentLevel:setTile(x, y, love.math.noise(x * 0.01, y * 0.01) / love.math.noise(x * 0.1, y * 0.1) > 0.5 and "grass" or "air")
	end
end
GameEntity.setLevel(currentLevel)

--****************

local function updateFrame(dt)
	local dtMod = dt * 60
	
	player.vx = player.vx + (boolAsInt[love.keyboard.isDown("d")] - boolAsInt[love.keyboard.isDown("a")]) * 0.2 * dtMod
	
	if love.keyboard.isDown("space") and player:checkCollisions() then
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
	
	if love.mouse.isDown(1) then
		local worldMx, worldMy = windowToWorldTransform:inverseTransformPoint(love.mouse.getX(), love.mouse.getY())
		worldMx = math.floor(worldMx / 8 + 0.5)
		worldMy = math.floor(worldMy / 8 + 0.5)
		currentLevel:setTile(worldMx, worldMy, "air")
	end
	
	currentLevel:update(dtMod)
	GameEntity.updateAll(dtMod)
end

local autoUpdateFrames = true
-- on each frame: handle physics, ...
function love.update(dt)
	if autoUpdateFrames then
		updateFrame(dt)
	end
end

-- handle single keypresses
function love.keypressed(key)
	if key == "escape" then
		love.event.push("quit") -- close game
	elseif key == "f4" then
		love.window.setFullscreen(not love.window.getFullscreen()) -- enter/leave fullscreen
	elseif key == "f3" then
		Level.settings.enableLOD = not Level.settings.enableLOD
	elseif key == "f2" then
		autoUpdateFrames = not autoUpdateFrames
	elseif key == "r" then
		player.x = 128
		player.y = -64
		player.vx = 0
		player.vy = 0
	elseif key == "f" then
		updateFrame(1/60)
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
		
		windowToWorldTransform:reset()
		windowToWorldTransform:translate(gameCanvasSize.w / 2, gameCanvasSize.h / 2)
		windowToWorldTransform:scale(cam.z, cam.z)
		windowToWorldTransform:translate(-cam.x, -cam.y)
		love.graphics.replaceTransform(windowToWorldTransform)
		
		love.graphics.setColor(1, 1, 1)
		currentLevel:draw(cam.x - gameCanvasSize.w/2 / cam.z, cam.y - gameCanvasSize.h/2 / cam.z, gameCanvasSize.w / cam.z + 32, gameCanvasSize.h / cam.z + 32)
		GameEntity.drawAll()
		
		love.graphics.setColor(1, 0, 0)
		--love.graphics.line(player.x, player.y, player.x + player.vx * 4, player.y + player.vy * 4)
		
		--[[
		local limitX = 1 / math.abs(player.vy)
		limitX = limitX < 3.5 and limitX or 3.5
		local limitY = 1 / math.abs(player.vx)
		limitY = limitY < 3.5 and limitY or 3.5
		love.graphics.line(player.x - limitX, player.y + 4, player.x + limitX, player.y + 4)
		love.graphics.line(player.x + 4, player.y - limitY, player.x + 4, player.y + limitY)
		love.graphics.line(player.x - limitX, player.y - 4, player.x + limitX, player.y - 4)
		love.graphics.line(player.x - 4, player.y - limitY, player.x - 4, player.y + limitY)
		]]
		
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