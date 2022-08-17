--[[
    This file is part of the NosGa Engine.
	
	NosGa Engine Copyright (c) 2019-2020 NosPo Studio

    The NosGa Engine is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    The NosGa Engine is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with the NosGa Engine.  If not, see <https://www.gnu.org/licenses/>.
]]

local global = ...

global.gameName = "StreetPuncher2"
global.gameVersion = "v1.0"

--===== shared vars =====--
local game = {
	gameIsRunning = true,
	winner = "",
	framesSinceDeath = 0,
}

--===== local vars =====--
local unicode = require("unicode")

--===== local functions =====--
local function print(...)
	global.log(...)
end

--===== shared functions =====--
function game.init()
	print("[game]: Start init.")
	
	--===== debug =====--
	
	--===== debug end =====--
	
	global.load({
		toLoad = {
			parents = true,
			gameObjects = true,
			textures = true,
			animations = true,
			globalStructured = true,
		},
	})

	--=== make textures transparent ===--

	--=== mirror plyaer textures ===--
	if not global.texture.player.head1_flipped then
		local image = require("libs/thirdParty/image")
		local flippedTextures = {}

		for i, t in pairs(global.texture.player) do
			if type(t) == "table" and t.format == "pic" and not t.flippedHorizontaly then
				local flippedTexture = image.flipHorizontally(t)
				flippedTexture.format = "pic"
				flippedTexture.flippedHorizontaly = true
				
				flippedTextures[i .. "_flipped"] = flippedTexture
			end
		end
		for i, t in pairs(flippedTextures) do 
			global.texture.player[i] = t
		end
	end

	
	--=== init game ===--
	global.clear()


	game.raMain = global.addRA({
		posX = 1, 
		posY = 1, 
		sizeX = global.resX, 
		sizeY = global.resY, 
		name = "TRA1", 
		drawBorders = true,
	})
	
    game.player1 = game.raMain:addGO("Player", {
        posX = 10,
        posY = 25,
        layer = 3,
        name = "Player1",
		id = 1,
    })

	game.player2 = game.raMain:addGO("Player", {
        posX = 52,
        posY = 25,
        layer = 3,
        name = "Player2",
		id = 2,
    })
	
	
	--=== generate background ===--

	if true then
		local width = 50
		local upperTextureHeight = 25
		local bottomTextureHeight = 5
		local upperTexture, bottomTexture = nil, nil
		local middleTextures = {}
		local tmpTexture = nil

		upperTexture, tmpTexture = global.splitTexture("h", global.texture.background, upperTextureHeight)
		tmpTexture, bottomTexture = global.splitTexture("h", tmpTexture, tmpTexture.resY - bottomTextureHeight)
		
		

		for c = 0, math.floor(global.resX / width) do
			local middleTextureSplit
			
			if tmpTexture.resX > width then
				middleTextureSplit, tmpTexture = global.splitTexture("v", tmpTexture, width)
			else
				middleTextureSplit = tmpTexture
			end
			
			game.raMain:addGO("BackgroundTile", {
				layer = 1, 
				posX = width * c,
				posY = upperTextureHeight,
				texture = middleTextureSplit,
				name = "BGMiddle" .. tostring(c + 1),
			})
		end

		game.raMain:addGO("BackgroundTile", {
			layer = 1, 
			posX = 0,
			posY = 0,
			texture = upperTexture,
			name = "BGUpper",
		})
		game.raMain:addGO("BackgroundTile", {
			layer = 1, 
			posX = 0,
			posY = global.resY - bottomTextureHeight,
			texture = bottomTexture,
			name = "BGBottom",
		})

	else
		game.background = game.raMain:addGO("Background", {
			posX = 0,
			posY = 0,
			layer = 1,
			name = "background",
		})
	end



	--=== GUI ===--
	game.overlay = game.raMain:addGO("GameOverOverlay", {
        posX = 64,
        posY = 8,
        layer = 5,
        name = "overlay",
    })
	
	do --add GUI
		local gui = global.gui
		game.gui = gui.application()
		local container = game.gui:addChild(gui.container(1, 1, 160, 30))
		
		game.lifeBar1 = container:addChild(gui.progressBar(13, 3, 64, 0x990000, 0x666666, 0xffffff, 50))
		game.lifeBar2 = container:addChild(gui.progressBar(85, 3, 64, 0x990000, 0x666666, 0xffffff, 50))
		
		game.chargeBar1 = container:addChild(gui.progressBar(13, 5, 64, 0x0055bb, 0x666666, 0xffffff, 50))
		game.chargeBar2 = container:addChild(gui.progressBar(85, 5, 64, 0x0000bb, 0x666666, 0xffffff, 50))

		game.gui:draw(true)
		game.gui:start()
	end

	game.bloodContainer = game.raMain:addGO("BloodContainer", {
		layer = 5,
	})


	

end

function game.start()
	--game.bloodContainer:bloodExplosion(50, 10)

	game.player1:reset()
	game.player2:reset()
	
	--===== debug =====--
	


	
	--===== debug end =====--
	
end

function game.update()
	
	game.lifeBar1.value = game.player1.life
	game.lifeBar2.value = game.player2.life
	game.chargeBar1.value = game.player1.charge
	game.chargeBar2.value = game.player2.charge

	if game.gameIsRunning and game.framesSinceDeath <= 3 then
		if 
			(game.player1.life <= 0 and global.computer.uptime() - game.player1.bloodJetStartTime > game.player1.bloodJetTime) or 
			(game.player2.life <= 0 and global.computer.uptime() - game.player2.bloodJetStartTime > game.player2.bloodJetTime)
		then
			if game.framesSinceDeath < 3 then
				game.framesSinceDeath = game.framesSinceDeath + 1
			else
				game.gameIsRunning = false
				
				if game.player1.life <= 0 and game.player2.life <= 0 then
					game.winner = "No one"
				elseif game.player1.life <= 0 then
					game.winner = game.player1.name
				elseif game.player2.life <= 0 then
					game.winner = game.player2.name
				end
			end
		end
	end
end

function game.draw()
	local backgroundColor = global.db.get(math.floor(global.resX / 2 - unicode.len(global.gameVersion) / 2 + 1), 1)
	global.gpu.setBackground(backgroundColor)
	global.gpu.setForeground(0xaaaaaa)
	global.gpu.set(global.resX / 2 - unicode.len(global.gameVersion) / 2 + 1, 1, global.gameVersion)
end

function game.ctrl_test2_key_down()
	global.log("TEST2")
	

	local function resolve(action)
		local key
		for i, k in pairs(global.controls.k) do
			if k[1] == action then
				key = i
				break
			end
		end
		return key
	end


	global.log(resolve("player1_left"))

	--global.realGPU.setBackground(0x0)
	--global.realGPU.fill(0, 0, 160, 50, " ")
end

function game.ctrl_reset_key_down()
	game.gameIsRunning = true
	game.framesSinceDeath = 0
	
	--quick and dirty bug fix
	game.player1.life = 100
	game.player2.life = 100

	game.raMain:rerenderAll()
end

function game.stop()
	--game.gui:stop()
end

return game





