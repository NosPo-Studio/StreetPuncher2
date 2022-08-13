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

--===== shared vars =====--
local test = {
}

--===== local vars =====--

--===== local functions =====--
local function print(...)
	global.log(...)
end

--===== shared functions =====--
function test.init()
	print("[test]: Start init.")
	
	--===== debug =====--
	
	--===== debug end =====--
	
	global.load({
		toLoad = {
			parents = true,
			testObjects = true,
			textures = true,
			animations = true,
			globalStructured = true,
		},
	})

	--=== make textures transparent ===--
	for i, t in pairs(global.texture.player) do
		if type(t) == "table" and t.format == "pic" then
			if t.format == "pic" then
				global.makeImageTransparent(t, 0x00ffff)
			end
		end
	end
	for i, t in pairs(global.animation.legs.frames) do
		if type(t) == "table" then
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

	
	--=== init test ===--
	global.clear()
	
	test.raMain = global.addRA({
		posX = 1, 
		posY = 1, 
		sizeX = global.resX, 
		sizeY = global.resY, 
		name = "TRA1", 
		drawBorders = true,
	})
	
    test.test = test.raMain:addGO("Test", {
        posX = 10,
        posY = 25,
        layer = 5,
        name = "test1",
		id = 1,
    })
	test.test2 = test.raMain:addGO("Test2", {
        posX = 10,
        posY = 25,
        layer = 3,
        name = "test2",
		id = 1,
    })
	test.test2 = test.raMain:addGO("Test3", {
        posX = 10,
        posY = 25,
        layer = 4,
        name = "test3",
		id = 1,
    })

	
	test.background = test.raMain:addGO("Background", {
        posX = 0,
        posY = 0,
        layer = 1,
        name = "background",
    })
	

end

function test.start()
	
	--===== debug =====--
	


	
	--===== debug end =====--
	
end

function test.update()
	
end

function test.draw()
	global.db.drawImage(50, 10, global.texture.player.head1)
	global.db.drawImage(45, 10, global.texture.player.body)
end

function test.ctrl_reset_key_down()
	
end

function test.stop()
	
end

return test





