local usesDoubleBuffer = ...

local version = "v1.1.3c"
local isDevVersion = false

local resX, resY = require("component").gpu.getResolution()
local offsetX, offsetY = resX / 2 / 2, resY / 2 / 2
SF1_isRunning = true

local component = require("component")
local computer = require("computer")
local system = require("os")
local term = require("term")
local keyboard = require("keyboard")
local gpu
local unicode = require("unicode")

package.loaded.player = nil
local player = require("player")
package.loaded.player = nil
local player2 = require("player")

package.loaded.graphic = nil
require("graphic")

package.loaded.deltaTime = nil
local delta = require("deltaTime")

package.loaded.background = nil
local background = require("background")

local deltaTime = 0
local previousDeltaTime = 0

local fpsCheckInterval = 20
local deltaTimeTable = {}
local fps = 0
local frameCounter = 0
local realDeltaTime = 0

local lastBlinkTime = computer.uptime()
local blinkState = true
local lastLooser

local gameIsRunning = true

--==========--
local blinkDelay = 1

local orgResX = 80
local orgResY = 25

local sleepTime = 1 --caps it to about 20 fps

local controls = require("libs/LIP").load("../controls.ini")

--===== init =====--
if usesDoubleBuffer then
	gpu = gpuProxy
else
	gpu = component.gpu
end

--=============== Functions ===============--

function Start()
	player.Start()
	player2.Start()

	player.right = tostring(controls.player1.right)
	player.left = tostring(controls.player1.left)
	player.punch = tostring(controls.player1.punch)
	
	player2.right = tostring(controls.player2.right)
	player2.left = tostring(controls.player2.left)
	player2.punch = tostring(controls.player2.punch)
	
	player2.body.aSet[1] = {2, 1, "   ", 0x000000, 0xbf2f11}
	player2.body.aSet[2] = {3, 0, " "}
	
	Reset()
end

function Update()
	if gameIsRunning then
		player.Update()
		player2.Update()
		
		Draw()
		
		if HitCheck(player, player2) then
			player2.life = player2.life - (player.charge /2)
			player.charge = 0
		end
		if HitCheck(player2, player) then
			player.life = player.life - (player2.charge /2)
			player2.charge = 0
		end
		
		if player2.life <= 0 and player.life <= 0 then
			GameOver(0)
		else
			if player.life <= 0 then
				GameOver("Player2")
			elseif player2.life <= 0 then
				GameOver("Player1")
			end
		end
	else
		if computer.uptime() - lastBlinkTime > blinkDelay then
			if blinkState then
				DrawResetText()
				blinkState = false
			else
				Draw()
				GameOver(lastLooser)
				blinkState = true
			end
			lastBlinkTime = computer.uptime()
		end
	end
end


function Draw()
	--gpu.fill(1, 1, resX, resY, " ")
	--DrawAt(testTexture, 0, 0, gpu)
	
	ClearAt(player2.body, player2.oldPosX, player2.oldPosY, gpu)
	ClearAt(player.body, player.oldPosX, player.oldPosY, gpu)
	
	ClearAt(player.arm2, player.oldPosX, player.oldPosY, gpu)
	ClearAt(player.arm3, player.oldPosX, player.oldPosY, gpu)
	
	ClearAt(player2.arm2, player2.oldPosX, player2.oldPosY, gpu)
	ClearAt(player2.arm3, player2.oldPosX, player2.oldPosY, gpu)
	
	--Background
	DrawAt(background.street, 1, 17, gpu)
	
	--Player
	
	DrawAt(player.body, player.posX, player.posY, gpu)
	DrawAt(player2.body, player2.posX, player2.posY, gpu)
	
	DrawArms(player)
	DrawArms(player2)
	
	LifeGui()

	gpu.setBackground(0x0)
	gpu.fill(1, 1, resX, offsetY, " ")
	gpu.fill(1, offsetY + orgResY + 1, resX, offsetY, " ")
	gpu.fill(1, 1, offsetX, resY, " ")
	gpu.fill(offsetX + orgResX + 1, 1, offsetX, resY, " ")

	gpu.setBackground(0x5a5a5a)
	gpu.setForeground(0xe1e1e1)
	gpu.fill(offsetX - 1, offsetY, orgResX + 4, 1, "▄")
	gpu.fill(offsetX - 1, offsetY + orgResY + 1, orgResX + 4, 1, "▀")
	gpu.fill(offsetX - 1, offsetY, 1, orgResY + 2, " ")
	gpu.fill(offsetX, offsetY + 1, 1, orgResY, "█")
	gpu.fill(offsetX + orgResX + 2, offsetY, 1, orgResY + 2, " ")
	gpu.fill(offsetX + orgResX + 1, offsetY + 1, 1, orgResY, "█")

end

function LifeGui() 
	DrawAt({
		fillSize = 4,
		aFill = {
			[1] = {2, 1, 36, 5, " ", 0x000000, 0xaaaaaa},
			[2] = {42, 1, 36, 5, " ", 0x000000, 0xaaaaaa},
			
		},
		
		setSize = 2,
		aSet = {
			
		},
	}, 1, 1, gpu)
	gpu.setBackground(0x000000)
	gpu.set(5 + offsetX, 3 + offsetY, "                                ")
	gpu.set(45 + offsetX, 3 + offsetY, "                                ")
	gpu.set(5 + offsetX, 5 + offsetY, "                                ")
	gpu.set(45 + offsetX, 5 + offsetY, "                                ")
	gpu.setBackground(0x00aa00)
	gpu.fill(5 + offsetX, 3 + offsetY, player.life, 1, " ")
	gpu.fill(45 + offsetX, 3 + offsetY, player2.life, 1, " ")
	gpu.setBackground(0x000000ff)
	gpu.fill(5 + offsetX, 5 + offsetY, player.charge, 1, " ")
	gpu.fill(45 + offsetX, 5 + offsetY, player2.charge, 1, " ")
	
	gpu.setForeground(0xaaaaaa)
	gpu.setBackground(0x00509f)
	gpu.set(orgResX / 2 - unicode.len(version) / 2 + 1 + offsetX, 1 + offsetY, version)
end

function HitCheck(p1, p2)
	if p1.looksLeft then
		if p1.isPunching then
			if p1.posX <= p2.posX + 10 and p1.posX > p2.posX + 5 then
				return true
			end
		end
	elseif p1.looksLeft == false then
		if p1.isPunching then
			if p1.posX + 10 >= p2.posX and p1.posX + 5 < p2.posX then
				return true
			end
		end
	else
		return false
	end
end

function DrawArms(player)	
	if player.isCharging then
		DrawAt(player.arm2, player.posX, player.posY, gpu)
	elseif player.isPunching then
		DrawAt(player.arm3, player.posX, player.posY, gpu)
	else
		DrawAt(player.arm1, player.posX, player.posY, gpu)
	end
end

function GameOver(name)
	LifeGui()
	
	if name ~= 0 then
		DrawAt({
		fillSize = 1, aFill = {},
		setSize = 4,
		aSet = {
			[1] = {28, 6, "########################", 0x500000, 0xba0000},
			[2] = {28, 7, "##     GameOver!      ##", 0x500000, 0xba0000},
			[3] = {28, 8, "##  " .. name .. " has won!  ##"},
			[4] = {28, 9, "########################", 0x500000, 0xba0000},
		}}, 1, 1, gpu)
	else
		DrawAt({
		fillSize = 1, aFill = {},
		setSize = 4,
		aSet = {
			[1] = {28, 6, "########################", 0x500000, 0xba0000},
			[2] = {28, 7, "##     GameOver!      ##", 0x500000, 0xba0000},
			[3] = {28, 8, "##       Tie!         ##"},
			[4] = {28, 9, "########################", 0x500000, 0xba0000},
		}}, 1, 1, gpu)
	end

	if blinkState then
		DrawResetText()
	end
	
	gameIsRunning = false
	lastLooser = name
end

function DrawResetText()
	DrawAt({
		fillSize = 1, aFill = {},
		setSize = 1,
		aSet = {
			[1] = {30, 12, " Press " .. unicode.upper(controls.game.reset) .. " to restart ", 0x705000, 0xee6000},
	}}, 1, 9, gpu)
end

function Reset() 
	player.posX = 5
	player.life = player.maxLife
	player.charge = 0
	player.TurnAround(false)
	
	player2.posX = 70
	player2.life = player2.maxLife
	player2.charge = 0
	player2.TurnAround(true)
	
	gameIsRunning = true
	
	blinkState = true
	
	ClearAt(player2.body, player2.oldPosX, player2.oldPosY, gpu)
	ClearAt(player.body, player.oldPosX, player.oldPosY, gpu)
	
	ClearAt(player.arm2, player.oldPosX, player.oldPosY, gpu)
	ClearAt(player.arm3, player.oldPosX, player.oldPosY, gpu)
	
	ClearAt(player2.arm2, player2.oldPosX, player2.oldPosY, gpu)
	ClearAt(player2.arm3, player2.oldPosX, player2.oldPosY, gpu)
	
end

function Reload() --For DEV
	ClearAt(background.street, 1, 17, gpu)
	package.loaded.background = nil
	background = require("background")
end
local devCount = 0

--=============== Main while ===============--
--term.clear()
--gpu.setResolution(resX, resY)


Start()
while SF1_isRunning do
	Update()
	--system.sleep(0.001)
	deltaTime = (computer.uptime() - previousDeltaTime) * 100 / 7
	realDeltaTime = computer.uptime() - previousDeltaTime
	previousDeltaTime = computer.uptime()
	
	if isDevVersion then
		if frameCounter >= fpsCheckInterval then
			frameCounter = 0
		end
		deltaTimeTable[frameCounter] = realDeltaTime
		local frameTimes = 0
		for i, c in pairs(deltaTimeTable) do
			frameTimes = frameTimes + c
		end
		frameCounter = frameCounter +1
		fps = 1 / (frameTimes / #deltaTimeTable)

		gpu.setForeground(0xaaaaaa)
		gpu.setBackground(0x000000)
		gpu.set(1, 1, "                              ")
		delta.Set()
		--gpu.set(1, 1, "Delta time: " .. deltaTime .. " | " .. (sleepTime - deltaTime) / 1000 .. " | " )
		gpu.set(1, 1, "FPS: " .. fps)
	end

	if usesDoubleBuffer then
		gpu.drawChanges()
	end
	
	if keyboard.isKeyDown(controls.game.quit) then
		gpu.setForeground(0xaaaaaa)
		gpu.setBackground(0x000000)
		--print("BREAK                       ")
		break
	elseif keyboard.isKeyDown(controls.game.reset) then
		Reset()
	end
	if keyboard.isKeyDown('t') then
		Reload()
		devCount = 0
	end

	os.sleep((sleepTime - deltaTime) / 1000)
end











