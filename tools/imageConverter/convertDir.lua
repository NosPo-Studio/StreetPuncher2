--===== var declaration =====--
package.path = package.path .. ";libs/?.lua"

local lfs = require("lfs")
local argparse = require("argparse")

local ut = require("UT")

--===== local functions =====--
local function getImageResolution(file)
    local output = io.popen("identify -format '%w\n%h' " .. file)
    local resX = output:read()
    local resY = output:read()
    return resX, resY
end

local function createDirStructure(path)
    local parsedPath = ""

    if args.verbose then
        print("Creating dir structure '" .. path .. "'")
    end

    for dir in string.gmatch(path, "([^/]+)") do
        parsedPath = parsedPath .. dir .. "/"

        if not lfs.attributes(parsedPath) then
            if args.verbose then
                print("Create dir '" .. parsedPath .. "'")
            end
            lfs.mkdir(parsedPath)
        end
    end
end

local function convert(input, output)
    local resX, resY = getImageResolution(input)
    local inputPath, file, ending = ut.seperatePath(input)
    local outputFile = args.output .. string.sub(input, #args.input +1, -#ending) .. "pic"
    local suc
    local execString = "lua convertImage.lua " .. input .. " " .. outputFile .. " "  .. resX .. " "  .. resY .. " " .. args.OCIF .. " " .. args.brialle  .. " " .. args.dithering .. " " .. args.opacity

    if args.verbose then
        print("Convert '" .. input .. "'")
    end

    if args.overwrite then
        execString = execString .. " -O"
    end
    if args.noWarn then
        execString = execString .. " -w"
    end

    if args.verbose then
        print("EXEC: " .. execString)
    end

    suc = os.execute(execString)

    if not suc and not args.ignoreErrors then
        print("ERROR: An error occured while converting the file '" .. input .. "'")
        print("Aborting conversion.")
        os.exit(10)
    elseif not suc then
        print("ERROR: error occured while converting the file '" .. input .. "'")
        print("-i is given. Continue conversion.")
    end 
end

local function parseDir(path)
    local outputDir = args.output .. string.sub(path, #args.input +1) 

    if not lfs.attributes(outputDir) then
        createDirStructure(outputDir)
    end

    for file in lfs.dir(path) do
        local fileType = lfs.attributes(path .. "/" .. file, "mode")
        if file ~= "." and file ~= ".." then
            if args.recursive and fileType == "directory" then
                if args.verbose then
                    print("Parsing sub dir '" .. file .. "'")
                end
                parseDir(path .. "/" .. file)
            elseif fileType == "file" then
                convert(path .. "/" .. file)
            end
        end
    end
end

--===== parse args =====--
do
    local parser = argparse("Convert dir", "Converts a whole dir of PNGs and JPGs to OCIF images keeping the original resolution.")

    parser:argument("input", "Input dir")
    parser:argument("output", "Output dir")
    parser:argument("OCIF", "(6-8) The OCIF version")
    parser:argument("brialle", "(0-1) If brialle is used to indirectly double up output resolution")
    parser:argument("dithering", " (0-1) If dithering is enabled")
    parser:argument("opacity", " (0-100) Opacity value")

    parser:flag("-O --overwrite"):target("overwrite")
    parser:flag("-w --no-warn", "Dont print warning messages"):target("noWarn")
    parser:flag("-r --recursive", "Convert all sub dirs as well")
    parser:flag("-v --verbose", "Print anything the converter does."):target("verbose")
    parser:flag("-i --ignore-errors", "Continues converting images even if an error occures."):target("ignoreErrors")
    parser:flag("-w --no-warn", "Dont print warning messages."):target("noWarn")

    args, options = parser:parse()
end

--===== init =====--
if not lfs.attributes(args.input) then
    print("ERROR: Can not find input dir")
    os.exit(1)
end

--===== execute order =====--
parseDir(args.input)




