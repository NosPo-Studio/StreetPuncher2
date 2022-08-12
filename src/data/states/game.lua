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

global.gameVersion = "v0.0.2"

--===== shared vars =====--
local game = {
	gameIsRunning = true,
	winner = "",

	blinkDelay = 1,
	lastBlinkTime = global.computer.uptime(),
	blinkStatus = true,
}

--===== local vars =====--

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

	for i, t in pairs(global.texture.player) do
		if type(t) == "table" and t.format == "pic" then
			if t.format == "pic" then
				global.makeImageTransparent(t, 0x00ffff)
			end
		end
	end
	for i, t in pairs(global.animation.legs.frames) do
		global.log(i, t)
		if type(t) == "table" then
			--global.log("TT")
			global.makeImageTransparent(t, 0x00ffff)
		end
	end

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
        name = "player1",
		id = 1,
    })

	game.player2 = game.raMain:addGO("Player", {
        posX = 22,
        posY = 25,
        layer = 3,
        name = "player2",
		id = 2,
    })

	

	game.background = game.raMain:addGO("Background", {
        posX = 0,
        posY = 0,
        layer = 1,
        name = "player1",
    })

	do --add GUI
		local gui = global.gui
		game.gui = gui.application()
		local container = game.gui:addChild(gui.container(1, 1, 160, 30))
		
		game.lifeBar1 = container:addChild(gui.progressBar(3, 2, 50, 0x990000, 0x666666, 0xffffff, 50))
		game.lifeBar2 = container:addChild(gui.progressBar(56, 2, 50, 0x990000, 0x666666, 0xffffff, 50))
		
		game.chargeBar1 = container:addChild(gui.progressBar(3, 4, 50, 0x000099, 0x666666, 0xffffff, 50))
		game.chargeBar2 = container:addChild(gui.progressBar(56, 4, 50, 0x000099, 0x666666, 0xffffff, 50))



		game.gui:draw(true)
		game.gui:start()
	end

	game.bloodContainer = game.raMain:addGO("BloodContainer", {
		layer = 5,
	})

end

function game.start()
	game.bloodContainer:bloodExplosion(50, 10)
	
	--===== debug =====--
	


	
	--===== debug end =====--
	
end

function game.update()	
	game.lifeBar1.value = game.player1.life
	game.lifeBar2.value = game.player2.life
	game.chargeBar1.value = game.player1.charge
	game.chargeBar2.value = game.player2.charge

	if game.gameIsRunning and game.player1.life <= 0 and game.player1.life <= 0 then
		game.gameIsRunning = false

		if game.player1.life <= 0 and game.player1.life <= 0 then
			game.winner = "Tie!"
		elseif game.player1.life <= 0 then
			game.winner = game.player1.name
		elseif game.player2.life <= 0 then
			game.winner = game.player2.name
		end
	end

end

function game.draw()
	
end

function game.ctrl_reset_key_down()
	game.gameIsRunning = true
end

function game.stop()
	game.gui:stop()
end

return game





