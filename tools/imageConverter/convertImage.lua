package.path = package.path .. ";libs/?.lua"

local lfs = require("lfs")
local argparse = require("argparse")

local args, options

do --parse args
    local parser = argparse("Image converter", "A CLI tool to convert PNG and JPG images to OCFI images")

    parser:argument("input", "Input file path")
    parser:argument("output", "Output file path")
    parser:argument("resX", "The output width resolution in OC pixels.")
    parser:argument("resY", "The output height resolution in OC pixels")
    parser:argument("OCIF", "(6-8) The OCIF version")
    parser:argument("brialle", "(0-1) If brialle is used to indirectly double up output resolution")
    parser:argument("dithering", " (0-1) If dithering is enabled")
    parser:argument("opacity", " (0-100) Opacity value")

    parser:flag("-O --overwrite"):target("overwrite")
    parser:flag("-w --no-warn", "Dont print warning messages."):target("noWarn")
    

    args, options = parser:parse()
end

if tonumber(args.OCIF) < 6 or tonumber(args.OCIF) > 8 then
    print("ERROR: OCIF version out of range.")
    os.exit(10)
end
if args.brialle ~= "0" and args.brialle ~= "1" then
    print("ERROR: brialle version out of range.")
    os.exit(11)
end
if args.dithering ~= "0" and args.dithering ~= "1" then
    print("ERROR: dithering version out of range.")
    os.exit(12)
end
if tonumber(args.opacity) < 0 or tonumber(args.opacity) > 100 then
    print("ERROR: opacity version out of range.")
    os.exit(13)
end

if not lfs.attributes(args.input) then
    print("ERROR: Can not find input file")
    os.exit(1)
end

if lfs.attributes(args.output) and args.overwrite then
    if not args.noWarn then
        print("WARN: Overweite file '" .. args.output .. "'")
    end
elseif lfs.attributes(args.output) then
    print("ERROR: Output file already exists. Use -O to overwrite.")
    os.exit(2)
end

os.exit(select(3, os.execute("java -jar bin/converter.jar " .. args.input .. " " .. args.output .. " " .. args.resX .. " " .. math.floor(args.resY / 2 + .5) .. " " .. args.OCIF .. " " .. args.brialle .. " " .. args.dithering .. " " .. args.opacity)))