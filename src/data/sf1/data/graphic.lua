--GraphicLib v0.1c

local resX, resY = require("component").gpu.getResolution()
local offsetX, offsetY = resX / 2 / 2, resY / 2 / 2

function ClearAt(t, posX, posY, gpu)
	posX, posY = posX + offsetX, posY + offsetY
	AddToTexture(t, posX, posY)
	ClearTexture(t, gpu)
	AddToTexture(t, -posX, -posY)
end

function ClearTexture(t, gpu) 
	gpu.setBackground(0x000000)
	for c = 1, t.fillSize, 1 do
		if t.aFill[c] ~= nil then
			if t.aFill[c][5] ~= nil then
				gpu.fill(t.aFill[c][1], t.aFill[c][2], t.aFill[c][3], t.aFill[c][4], " ")
			end		
		end
	end

	for c = 1, t.setSize, 1 do
		if t.aSet[c] ~= nil then
			if t.aSet[c][3] ~= nil then
				gpu.fill(t.aSet[c][1], t.aSet[c][2], string.len(t.aSet[c][3]), 1, " ")
			end
		end
	end
end

function DrawAt(t, posX, posY, gpu)
	posX, posY = posX + offsetX, posY + offsetY
	AddToTexture(t, posX, posY)
	DrawTexture(t, gpu)
	AddToTexture(t, -posX, -posY)
end

function DrawTexture(t, gpu) 
	local previousForeground = gpu.getForeground()
	local previousBackground = gpu.getBackground()
	for c = 1, t.fillSize, 1 do
		if t.aFill[c] ~= nil then
			if t.aFill[c][6] ~= nil then
				if previousForeground ~= t.aFill[c][6] then
					gpu.setForeground(t.aFill[c][6])
					previousForeground = t.aFill[c][6]
				end
				if previousBackground ~= t.aFill[c][7] then
					gpu.setBackground(t.aFill[c][7])
					previousBackground = t.aFill[c][7]
				end
				
				gpu.fill(t.aFill[c][1], t.aFill[c][2], t.aFill[c][3], t.aFill[c][4], t.aFill[c][5])
			elseif #t.aFill[c] == 2 then
				if previousForeground ~= t.aFill[c][1] then
					gpu.setForeground(t.aFill[c][1])
					previousForeground = t.aFill[c][1]
				end
				if previousBackground ~= t.aFill[c][2] then
					gpu.setBackground(t.aFill[c][2])
					previousBackground = t.aFill[c][2]
				end
			else
				gpu.fill(t.aFill[c][1], t.aFill[c][2], t.aFill[c][3], t.aFill[c][4], t.aFill[c][5])
			end
			
		end
	end

	for c = 1, t.setSize, 1 do
		if t.aSet[c] ~= nil then
			if t.aSet[c][4] ~= nil then
				if previousForeground ~= t.aSet[c][4] then
					gpu.setForeground(t.aSet[c][4])
					previousForeground = t.aSet[c][4]
				end
				if previousBackground ~= t.aSet[c][5] then
					gpu.setBackground(t.aSet[c][5])
					previousBackground = t.aSet[c][5]
				end
				
				gpu.set(t.aSet[c][1], t.aSet[c][2], t.aSet[c][3])
			elseif #t.aSet[c] == 2 then
				if previousForeground ~= t.aSet[c][1] then
					gpu.setForeground(t.aSet[c][1])
					previousForeground = t.aSet[c][1]
				end
				if previousBackground ~= t.aSet[c][2] then
					gpu.setBackground(t.aSet[c][2])
					previousBackground = t.aSet[c][2]
				end
			else
				gpu.set(t.aSet[c][1], t.aSet[c][2], t.aSet[c][3])
			end
			
		end
	end
end

function AddToTexture(t, x, y)
	for c = 0, t.fillSize, 1 do
		if t.aFill[c] ~= nil then
			t.aFill[c][1] = t.aFill[c][1] + x
			t.aFill[c][2] = t.aFill[c][2] + y
		end
	end
	for c = 0, t.setSize, 1 do
		if t.aSet[c] ~= nil then
			t.aSet[c][1] = t.aSet[c][1] + x
			t.aSet[c][2] = t.aSet[c][2] + y
		end
	end
end