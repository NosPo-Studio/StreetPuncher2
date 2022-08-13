local Delta = {}
local computer = require("computer")

Delta.time = 0
Delta.previousDeltaTime = 0

function Delta:Set() 
	Delta.time = os.difftime(computer.uptime(), Delta.previousDeltaTime)
	Delta.time = Delta.time / 70 * 1000
	Delta.previousDeltaTime = computer.uptime()
end


return Delta