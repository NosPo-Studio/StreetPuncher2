--[[
    This file is a GameObject example for the NosGa Engine.
	
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

local global = ... --Here we get global.

GameObjectsTemplate = {}
GameObjectsTemplate.__index = GameObjectsTemplate

--Called once when the class is loaded by the engine.
function GameObjectsTemplate.init(this) 
	
end

--local aliaces 
local uptime = global.computer.uptime
local game = global.state.game


--Calles on the bject creation of the class. Here you define/initiate the class.
function GameObjectsTemplate.new(args) 
	--===== gameObject definition =====--
	--Take given GameObject args if present and prevents it from being nil if not.
	args = args or {} 

	args.sizeX = 32
	args.sizeY = 37
	args.components = { --Define the GameObjects components.
		--[[{"Sprite", 
			x = 0, 
			y = 0, 
			--texture = "exampleTexture",
			texture = global.texture.player.head1,
		},]]
	}
	args.usesAnimation = false
	args.noSizeArea = false
	
	--===== default stuff =====--
	--Inheritance from the GameObject main class.
	local this = global.core.GameObject.new(args) 
	this = setmetatable(this, GameObjectsTemplate) 
	
	--===== init =====--
	game = global.state.game
	
	--=== conf ===--
	this.startPosX = args.posX
	this.startPosY = args.posY


	--=== runtime vars ===--
	this.blinkDelay = 1
	this.lastBlinkTime = uptime()
	this.blinkStatus = true
	
	--===== custom functions =====--

	
	--===== default functions =====--
	--Called when this GameObject is added to a RenderArea.
	this.start = function(this) 
		
	end
	
	--Called up to once a frame.
	this.update = function(this, dt, ra) 
		--global.log(game.gameIsRunning)
		if game.gameIsRunning then
			this:moveTo(1000, 1000)
		else
			this:moveTo(this.startPosX, this.startPosY)
		end

		if not game.gameIsRunning and uptime() - this.lastBlinkTime > this.blinkDelay then
			if this.blinkStatus then
				this.blinkStatus = false
			else
				this.blinkStatus = true
			end
			this.lastBlinkTime = uptime()
			this:rerender()
		end
	end
	
	--[[Called every time the GameObject is drawed. 
		That can happen multiple times a frame if the GameObject is visible in multiple RenderAreas.
	]]
	this.draw = function(this) 
		local posX, posY = this:getPos()

		if not game.gameIsRunning then
			local text = "Game Over!"
			local name = ">> " .. tostring(game.winner) .. " <<"
			local endText = "Is the Winner!"
			local width = 30

			local resetKeys = "R"
			local resetText = ">> Press " .. resetKeys .. " to restart <<"

			global.oclrl:draw(posX +1, posY +1, global.oclrl.generateTexture({
				{"b", 0x500000},
				{"f", 0xba5500},
				
				{2, 1, width - 2, 5, " "},
				{0, 0, width, 1, "#"},
				{0, 6, width, 1, "#"},
				{0, 0, 2, 6, "#"},
				{width, 0, 2, 7, "#"},

				{width / 2 - global.unicode.len(text) / 2, 2, text},
				{width / 2 - global.unicode.len(name) / 2, 3, name},
				{width / 2 - global.unicode.len(endText) / 2, 4, endText},
			}))

			if this.blinkStatus then
				global.oclrl:draw(posX +1, posY + 36, global.oclrl.generateTexture({
					{"b", 0xee6000},
					{"f", 0x705000},
					
					{width / 2 - global.unicode.len(resetText) / 2, 0, resetText}
				}))
			end
		end
	end
	
	--[[Called every time the GameObject graphics are removed from the screen. 
		That can happen multiple times a frame if the GameObject is visible in multiple RenderAreas.
	]]
	this.clear = function(this, acctual) 
		
	end
	
	--Called when this GameObject is removed from a RenderArea.
	this.stop = function(this) 
	end
	
	return this
end

return GameObjectsTemplate
