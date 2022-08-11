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


--Calles on the bject creation of the class. Here you define/initiate the class.
function GameObjectsTemplate.new(args) 
	--===== gameObject definition =====--
	--Take given GameObject args if present and prevents it from being nil if not.
	args = args or {} 

	args.sizeX = 24
	args.sizeY = 19
	args.components = { --Define the GameObjects components.
		{"ClearArea",
			x = 4,
			y = 0,
			sizeX = 13,
			sizeY = 17,
		}
		--[[{"Sprite", 
			x = 0, 
			y = 0, 
			--texture = "exampleTexture",
			texture = global.texture.player.head1,
		},]]
	}
	args.usesAnimation = true
	args.noSizeArea = true
	
	--===== default stuff =====--
	--Inheritance from the GameObject main class.
	local this = global.core.GameObject.new(args) 
	this = setmetatable(this, GameObjectsTemplate) 
	
	--===== init =====--
	--=== textures / animations ===--
	this.head = this.gameObject:addSprite({texture = global.texture.player.head1, x = 7, y = 1})
	this.body = this.gameObject:addSprite({texture = global.texture.player.body, x = 4, y = 0})
	this.arm = this.gameObject:addSprite({texture = global.texture.player.arm1, x = 2, y = 0})

	
	this.legs = this.gameObject:addSprite({texture = global.animation.legs, x = 6, y = 14})
	this.legs:stop()

	if args.id == 2 then
		this.hat = this.gameObject:addSprite({texture = global.texture.player.hat, x = 7, y = 0})
	end

	--=== conf ===--
	this.hitFaceTime = .5
	this.punchArmTime = .5
	this.speed = 10
	this.maxCharge = 100
	this.chargePerSecond = 30

	this.width = 10
	this.armRange = 10
	this.fistWidth = 2

	this.playerID = args.id


	--=== runtime vars ===--
	this.lastHitTime = uptime()
	this.lookingLeft = false

	this.punchStatus = 0 --0 == normal, 1 == chargin, 2 == punching
	this.charge = 0
	
	this.chargeStartTime = uptime()
	this.punchTime = uptime()
	
	--===== custom functions =====--
	this.ctrl_test_key_down = function(this)
		this:hit()
	end

	this.hit = function(this)
		this.lastHitTime = uptime()
	end

	this.left = function(this)
		if not this.lookingLeft then
			this.arm:move(-2, 0)
		end
		this:move(-this.speed * global.dt, 0)
		this.lookingLeft = true
		this.legs:play(-1)
	end
	this.right = function(this)
		if this.lookingLeft then
			this.arm:move(2, 0)
		end
		this:move(this.speed * global.dt, 0)
		this.lookingLeft = false
		this.legs:play(1)
	end

	this.startCharging = function(this)
		this.charge = 0
		this.punchStatus = 1
		this.chargeStartTime = uptime()
	end
	this.punch = function(this)
		if this.punchStatus == 1 then
			this.punchStatus = 2
			this.punchTime = uptime()

			do
				local enemy
				
				if this.playerID == 1 then
					enemy = global.state.game.player2
				else
					enemy = global.state.game.player1
				end

				
			end

		end
	end


	this.ctrl_player1_left_key_pressed = function()
		if this.playerID == 1 then
			this:left()
		end
	end
	this.ctrl_player1_right_key_pressed = function()
		if this.playerID == 1 then
			this:right()
		end
	end

	this.ctrl_player1_punch_key_down = function()
		if this.playerID == 1 then
			this:startCharging()
		end
	end
	this.ctrl_player1_punch_key_up = function()
		if this.playerID == 1 then
			this:punch()
		end
	end

	this.ctrl_player2_left_key_pressed = function()
		if this.playerID == 2 then
			this:left()
		end
	end
	this.ctrl_player2_right_key_pressed = function()
		if this.playerID == 2 then
			this:right()
		end
	end

	this.ctrl_player2_punch_key_down = function()
		if this.playerID == 2 then
			this:startCharging()
		end
	end
	this.ctrl_player2_punch_key_up = function()
		if this.playerID == 2 then
			this:punch()
		end
	end

	
	--===== default functions =====--
	--Called when this GameObject is added to a RenderArea.
	this.start = function(this) 
		
	end
	
	--Called up to once a frame.
	this.update = function(this, dt, ra) 
		--global.log(args.name, this.charge)

		if select(1, this:getLastPos()) == select(1, this:getPos()) then
			this.legs:stop(1)
		end

		if this.punchStatus == 2 and uptime() - this.punchTime > this.punchArmTime then
			this.punchStatus = 0
		end
		if this.punchStatus == 1 then
			this.charge = this.charge + this.chargePerSecond * global.dt
		end
		if this.punchStatus == 1 and this.charge > this.maxCharge then
			this:punch()
		end

		if this.punchStatus == 0 then
			if this.lookingLeft then
				this.arm.texture = global.texture.player.arm1_flipped
			else
				this.arm.texture = global.texture.player.arm1
			end
		elseif this.punchStatus == 1 then
			if this.lookingLeft then
				this.arm.texture = global.texture.player.arm2_flipped
			else
				this.arm.texture = global.texture.player.arm2
			end
		elseif this.punchStatus == 2 then
			if this.lookingLeft then
				this.arm.texture = global.texture.player.arm3_flipped
			else
				this.arm.texture = global.texture.player.arm3
			end
		end


		if uptime() - this.lastHitTime > this.hitFaceTime then
			if this.lookingLeft then
				this.head.texture = global.texture.player.head1_flipped
			else
				this.head.texture = global.texture.player.head1
			end
		else
			if this.lookingLeft then
				this.head.texture = global.texture.player.head2_flipped
			else
				this.head.texture = global.texture.player.head2
			end
		end

		if this.playerID == 2 then
			if this.lookingLeft then
				this.hat.texture = global.texture.player.hat_flipped
			else
				this.hat.texture = global.texture.player.hat
			end
		end
	end
	
	--[[Called every time the GameObject is drawed. 
		That can happen multiple times a frame if the GameObject is visible in multiple RenderAreas.
	]]
	this.draw = function(this) 
		
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
