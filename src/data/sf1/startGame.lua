_G.gpuProxy = ...

local gpu = require("component").gpu
local shell = require("shell")
local currentWorkingDir = shell.getWorkingDirectory()
shell.setWorkingDirectory(currentWorkingDir .. "/data")

gpu.setBackground(0x0)
gpu.fill(0, 0, 1000, 1000, " ")


--_G.gpuProxy = loadfile("libs/dbgpu_api.lua")({directDraw = false})
local suc, err = xpcall(loadfile("game.lua"), debug.traceback, true)

if not suc then
    print(err, debug.traceback())
end

shell.setWorkingDirectory(currentWorkingDir)