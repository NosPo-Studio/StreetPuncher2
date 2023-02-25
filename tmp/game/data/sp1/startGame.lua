local shell = require("shell")
local currentWorkingDir = shell.getWorkingDirectory()
shell.setWorkingDirectory(currentWorkingDir .. "/data")

_G.gpuProxy = loadfile("libs/dbgpu_api.lua")({directDraw = false})
local suc, err = xpcall(loadfile("game.lua"), debug.traceback, true)

if not suc then
    print(err, debug.traceback())
end

shell.setWorkingDirectory(currentWorkingDir)