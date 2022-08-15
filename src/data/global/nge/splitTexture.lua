--works with OCIF6

local global = ...

return function(orientation, texture, pos)
    local split1, split2 = {format = "pic", 0, 0, {}, {}, {}, {}}, {format = "pic", 0, 0, {}, {}, {}, {}}
    local resX, resY = texture[1], texture[2]
    


    if orientation == "v" then
        if pos >= resX then
            error("Split pos is >= vertical texture resolution.", 2)
        end

        split1[1], split1[2] = pos, resY
        split2[1], split2[2] = resX - pos, resY

        local counter = 1

        for y = 1, resY do
            for x = 1, resX do
                if x > resX then
                    break
                elseif x <= pos then
                    table.insert(split1[3], texture[3][counter])
                    table.insert(split1[4], texture[4][counter])
                    table.insert(split1[5], texture[5][counter])
                    table.insert(split1[6], texture[6][counter])
                elseif x > pos then
                    table.insert(split2[3], texture[3][counter])
                    table.insert(split2[4], texture[4][counter])
                    table.insert(split2[5], texture[5][counter])
                    table.insert(split2[6], texture[6][counter])
                else
                    global.fatal("dafuq?!")
                end
                counter = counter +1
            end
        end
    elseif orientation == "h" then
        if pos >= resX then
            error("Split pos is >= horizontal texture resolution.", 2)
        end

        split1[1], split1[2] = resX, pos
        split2[1], split2[2] = resX, resY - pos

        local counter = 1

        for y = 1, resY do
            for x = 1, resX do
                if y > resY then
                    break
                elseif y <= pos then
                    table.insert(split1[3], texture[3][counter])
                    table.insert(split1[4], texture[4][counter])
                    table.insert(split1[5], texture[5][counter])
                    table.insert(split1[6], texture[6][counter])
                elseif y > pos then
                    table.insert(split2[3], texture[3][counter])
                    table.insert(split2[4], texture[4][counter])
                    table.insert(split2[5], texture[5][counter])
                    table.insert(split2[6], texture[6][counter])
                else
                    global.fatal("dafuq?!")
                end
                counter = counter +1
            end
        end
    end

    global.log("ORG:", global.ut.tostring(texture))
    global.log("SPLIT1:", global.ut.tostring(split1))
    global.log("SPLIT2:", global.ut.tostring(split2))


    return split1, split2
    --return texture
end
