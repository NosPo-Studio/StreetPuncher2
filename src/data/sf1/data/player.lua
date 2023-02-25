local Player = {}

Player.left = nil
Player.right = nil
Player.punch = nil

Player.posX = 0
Player.posY = 13

Player.life = 32
Player.maxLife = 32
Player.charge = 0
Player.maxCharge = 32

Player.oldPosX = Player.posX
Player.oldPosY = Player.posY

Player.keyboard = require("keyboard")

Player.looksLeft = false
Player.isPunching = false
Player.isCharging = false

Player.face = 10
Player.punchTime = 2
Player.punchCount = 0

Player.clearArm2 = false
Player.clearArm3 = false

function Player:Start()

end

function Player:Update()
	Player.oldPosX = Player.posX
	Player.oldPosX = Player.posX
	
	if Player.keyboard.isKeyDown(Player.right) and Player.isPunching == false then
		Player.posX = Player.posX +1
		Player.TurnAround(false)
	end
	
	if Player.keyboard.isKeyDown(Player.left) and Player.isPunching == false then
		Player.posX = Player.posX -1
		Player.TurnAround(true)
	end
	
	if Player.keyboard.isKeyDown(Player.punch) and Player.isPunching == false and Player.charge < Player.maxCharge then --Charge
		Player.isCharging = true
		if Player.charge < Player.maxCharge then
			Player.charge = Player.charge +2
		end
	elseif Player.isCharging then --Activate punch
		Player.isCharging = false
		Player.clearArm2 = true
		Player.isPunching = true
	end
	
	if Player.isPunching and Player.punchCount == Player.punchTime then --Reset punch
		Player.isPunching = false
		Player.clearArm3 = true
		Player.punchCount = 0
		Player.charge = 0
	elseif Player.isPunching then
		Player.punchCount = Player.punchCount +1
	end

	if Player.posX < -100 or Player.posX > 180 then
		SF1_isRunning = false
	end
end

function Player.TurnAround(lookLeft) 
	if lookLeft then
		Player.looksLeft = true
		
		Player.body.aSet[Player.face][3] = "o  "
		Player.arm1.aSet = {
			[1] = {2, 6, "B", 0x000000, 0xbbbb00},
		}
		Player.arm2.aSet = {
			[1] = {4, 4, "B", 0x000000, 0xbbbb00},
			[2] = {6, 4, "  ", 0x000000, 0x0000ff},
		}
		Player.arm3.aSet = {
			[2] = {-4, 3, "     ", 0x000000, 0x0000ff},
			[3] = {-5, 3, "B", 0x000000, 0xbbbb00},
		}
	else
		Player.looksLeft = false
		
		Player.body.aSet[Player.face][3] = "  o"
		Player.arm1.aSet = {
			[1] = {4, 6, "B", 0x000000, 0xbbbb00},
		}
		Player.arm2.aSet = {
			[1] = {2, 4, "B", 0x000000, 0xbbbb00},
			[2] = {-1, 4, "  ", 0x000000, 0x0000ff},
		}
		Player.arm3.aSet = {
			[2] = {6, 3, "     ", 0x000000, 0x0000ff},
			[3] = {11, 3, "B", 0x000000, 0xbbbb00},
		}
	end
end

Player.body = {
	fillSize = 100,
	aFill = {
		[1] = {1, 3, 5, 3, " ", 0x000000, 0x0000ff}, --Body
		
		[2] = {2, 7, 1, 3, " ", 0x000000, 0x00aa00}, --Legs
		[3] = {4, 7, 1, 3, " "},
		
	},
	
	setSize = 100,
	aSet = {
		[1] = {2, 1, "   ", 0x000000, 0x7f2f11}, --Head
		--[2] = {} Payer2
		
		[10] = {2, 2, "  o", 0x000000, 0xbbbb00}, --Face
		
		[3] = {1, 6, "     ", 0x000000, 0x00aa00}, --Leg
		
		[11] = {2, 9, " ", 0x000000, 0x4f1f01}, --Shoe
		[12] = {4, 9, " "}, --Shoe
		
	},
}

Player.arm1 = {
	fillSize = 1,
	aFill = {
		
	},
	
	setSize = 1,
	aSet = {
		[1] = {4, 6, "B", 0x000000, 0xbbbb00},
	},
}

Player.arm2 = {
	fillSize = 1,
	aFill = {
		
	},
	
	setSize = 2,
	aSet = {
		
	},
}

Player.arm3 = {
	fillSize = 1,
	aFill = {
		
	},
	
	setSize = 3,
	aSet = {
		[2] = {6, 3, "    ", 0x000000, 0x0000ff},
		[3] = {10, 3, "B", 0x000000, 0xbbbb00},
	},
}


return Player








