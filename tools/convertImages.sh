#!/bin/lua

-- quik and dirty. just to ensure a smoother workflow for myself.

print(os.execute("cd tools/imageConverter; lua convertDir.lua -vrwO in out 6 0 1 100"))
