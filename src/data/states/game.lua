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

global.gameVersion = "v0.0.1"

--===== shared vars =====--
local game = {
	
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
		for i, t in pairs(global.texture.player) do
			print(i, t)
			if type(t) == "table" and t.format == "pic" then
				local flippedTexture = image.flipHorizontally(t)
				flippedTexture.format = "pic"
				global.log(flippedTexture)
				global.texture.player[i .. "_flipped"] = flippedTexture
			end
		end
	end

	--print(global.)

end

function game.start()
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
        posX = 60,
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
	
	--===== debug =====--
	


	
	--===== debug end =====--
	
end

function game.update()	
	
end

function game.draw()
	
end

function game.stop()
	
end

return game





