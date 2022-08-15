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
		{"CopyArea",
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
	args.deco = true
	
	--===== default stuff =====--
	--Inheritance from the GameObject main class.
	local this = global.core.GameObject.new(args) 
	this = setmetatable(this, GameObjectsTemplate) 
	
	--===== init =====--
	this.bloodContainer = global.state.game.raMain:addGO("BloodContainer", {
		layer = 5,
	})

	--=== textures / animations ===--
	this.head = this.gameObject:addSprite({texture = global.texture.player.head1, x = 8, y = 1})
	this.body = this.gameObject:addSprite({texture = global.texture.player.body, x = 7, y = 6})
	this.arm = this.gameObject:addSprite({texture = global.texture.player.arm1, x = 11, y = 6})

	
	this.legs = this.gameObject:addSprite({texture = global.animation.legs, x = 7, y = 13})
	this.legs:stop()

	if args.id == 2 then
		this.hat = this.gameObject:addSprite({texture = global.texture.player.hat, x = 8, y = 0})
	end


	this.bloodJet = global.state.game.raMain:addGO("BloodJet", {
		parent = this,
		width = 5,
		height = 1,
		offsetX = 9,
		offsetY = 5,
		smokeRate = 0,
		sideForceRandom = 10,
	})

	--=== conf ===--
	this.hitFaceTime = .5
	this.punchArmTime = .5
	this.headLooseDelay = 0
	
	this.bloodPunchAmountMultiplier = .2
	this.bloodPunchForceMultiplier = .4
	
	this.bloodJetMultiplier = 100
	this.bloodJetForce = 60
	this.bloodJetTime = 6
	this.sideForceRange = 20
	this.upForceRange = 20

	this.speed = 30
	this.maxCharge = 100 --has to be 100
	this.chargeMultiplier = .5
	this.chargePerSecond = 70

	this.width = 10
	this.armRange = 10
	this.fistWidth = 2

	this.playerID = args.id

	this.name = args.name


	--=== runtime vars ===--
	this.lookingLeft = false

	this.punchStatus = 0 --0 == normal, 1 == chargin, 2 == punching
	this.charge = 0

	this.life = 100 --has to be 100
	this.actualSpeed = this.speed
	
	this.lastHitTime = 0
	this.chargeStartTime = uptime()
	this.punchTime = uptime()
	this.deathTime = uptime()
	this.bloodJetStartTime = uptime()
	
	--===== custom functions =====--
	this.ctrl_test_key_down = function(this)
		this:hit()
	end

	this.hit = function(this, charge)
		this.lastHitTime = uptime()
		this.life = this.life - charge * this.chargeMultiplier

		if this.life <= 0 then
			if this.lookingLeft then
				this.head.texture = global.texture.player.head3_flipped
			else
				this.head.texture = global.texture.player.head3
			end
			this.deathTime = uptime()
		end
	end

	this.left = function(this)
		if this.life <= 0 and uptime() - this.bloodJetStartTime > this.bloodJetTime then
			return true
		end
		this:move(-this.actualSpeed * global.dt, 0)
		this.lookingLeft = true
		this.legs:play(-1)
	end
	this.right = function(this)
		if this.life <= 0 and uptime() - this.bloodJetStartTime > this.bloodJetTime then
			return true
		end
		this:move(this.actualSpeed * global.dt, 0)
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
				local posX, posY = this:getPos()
				local enemyPosX
				local fistPosX
				
				if this.playerID == 1 then
					enemy = global.state.game.player2
				else
					enemy = global.state.game.player1
				end

				enemyPosX = enemy:getPos()

				if this.lookingLeft then
					fistPosX = posX + 4 - this.armRange
				else
					fistPosX = posX + 6 + this.armRange
				end

				if fistPosX >= enemyPosX and fistPosX <= enemyPosX + this.width then
					local addedBloodForce = 0
					local particleAmount = this.charge * this.bloodPunchAmountMultiplier

					enemy:hit(math.min(this.charge, this.maxCharge))

					if this.lookingLeft then
						addedBloodForce = - this.charge * this.bloodPunchForceMultiplier
					else
						addedBloodForce = this.charge * this.bloodPunchForceMultiplier
					end

					global.sfx.explosion(this.bloodContainer, fistPosX + 5, posY +5, "Blood", particleAmount, 3, {rng = 100}, addedBloodForce * .2)
					global.sfx.explosion(this.bloodContainer, fistPosX + 5, posY +5, "Blood", particleAmount, 6, {rng = 100}, addedBloodForce * .5)
					global.sfx.explosion(this.bloodContainer, fistPosX + 5, posY +5, "Blood", particleAmount, 10, {rng = 100}, addedBloodForce * .7)
				end
			end

		end
	end

	this.reset = function(this)
		local _, posY = this:getPos()
		
		this.life = 100
		this.charge = 0
		this.actualSpeed = this.speed

		this.bloodJet.smokeRate = 0

		if this.head.posY > 1000 then
			this.head:move(0, -1000)
		end
		if this.hat and this.hat.posY > 1000 then
			this.hat:move(0, -1000)
		end
		
		if this.playerID == 1 then
			this:moveTo(10, posY)

			this.lookingLeft = false
		else
			this:moveTo(130, posY)

			this.lookingLeft = true
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
		if this.life <= 0 then
			return true
		end
		
		if this.playerID == 1 then
			this:startCharging()
		end
	end
	this.ctrl_player1_punch_key_up = function()
		if this.life <= 0 then
			return true
		end

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
		if this.life <= 0 then
			return true
		end

		if this.playerID == 2 then
			this:startCharging()
		end
	end
	this.ctrl_player2_punch_key_up = function()
		if this.life <= 0 then
			return true
		end
		
		if this.playerID == 2 then
			this:punch()
		end
	end

	this.ctrl_reset_key_down = function()
		this:reset()
	end

	
	--===== default functions =====--
	--Called when this GameObject is added to a RenderArea.
	this.start = function(this) 
		
	end
	
	--Called up to once a frame.
	this.update = function(this, dt, ra) 
		--global.log(args.name, this.charge)

		local posX, posY = this:getPos()

		if this.life <= 0 and uptime() - this.bloodJetStartTime > this.bloodJetTime then
			this.legs:stop(1)
		end

		if this.life <= 0 and uptime() - this.deathTime > this.headLooseDelay then
			local timeSinceJetStart = uptime() - this.bloodJetStartTime
			local bloodMultiplier = (this.bloodJetTime - timeSinceJetStart) / this.bloodJetTime

			if this.head.posY < 1000 then
				this.head:move(0, 1000)
				if this.hat then
					this.hat:move(0, 1000)
				end
				this.bloodJetStartTime = uptime()
			end

			this.bloodJet.smokeRate = math.max(this.bloodJetMultiplier * bloodMultiplier, 0)
			this.bloodJet.upForce = math.max(this.bloodJetForce * bloodMultiplier, 0)
			this.bloodJet.sideForceRange = math.max(this.sideForceRange * bloodMultiplier, 0)
			this.bloodJet.upForceRange = math.max(this.upForceRange * bloodMultiplier, 0)

			this.actualSpeed = this.speed * bloodMultiplier
		end

		if select(1, this:getLastPos()) == select(1, this:getPos()) then
			this.legs:stop()
		end

		if this.punchStatus == 2 and uptime() - this.punchTime > this.punchArmTime then
			this.punchStatus = 0
			this.charge = 0
		end
		if this.punchStatus == 1 then
			this.charge = math.min(this.charge + this.chargePerSecond * global.dt, this.maxCharge)
		end
		if this.punchStatus == 1 and this.charge >= this.maxCharge then
			this:punch()
		end


		if this.punchStatus == 0 then
			if this.lookingLeft then
				this.arm.texture = global.texture.player.arm1_flipped
				this.arm:moveTo(posX + 10, posY + 6)
			else
				this.arm.texture = global.texture.player.arm1
				this.arm:moveTo(posX + 11, posY + 6)
			end
		elseif this.punchStatus == 1 then
			if this.lookingLeft then
				this.arm.texture = global.texture.player.arm2_flipped
				this.arm:moveTo(posX + 11, posY + 6)
			else
				this.arm.texture = global.texture.player.arm2
				this.arm:moveTo(posX + 4, posY + 6)
			end
		elseif this.punchStatus == 2 then
			if this.lookingLeft then
				this.arm.texture = global.texture.player.arm3_flipped
				this.arm:moveTo(posX, posY + 6)
			else
				this.arm.texture = global.texture.player.arm3
				this.arm:moveTo(posX + 11, posY + 6)
			end
		end

		if this.life > 0 then
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
		end

		if this.life > 0 and this.playerID == 2 then
			if this.lookingLeft then
				this.hat.texture = global.texture.player.hat_flipped
			else
				this.hat.texture = global.texture.player.hat
			end
		end

		if posX < -300 or posX > 490 then
			if not this.easter then
				local currentWorkingDir = global.shell.getWorkingDirectory()
				this.easter = true
				os.execute("cd data/sf1; ./startGame.lua")
				global.shell.setWorkingDirectory(currentWorkingDir)
			end
		elseif posX > -30 and posX < 190 then
			this.easter = false
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
