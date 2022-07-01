#!/bin/lua

-- quik and dirty. just to ensure a smoother workflow for myself.

print(os.execute("cd tools/imageConverter; lua convertDir.lua -rwO in out 6 0 0 100"))
