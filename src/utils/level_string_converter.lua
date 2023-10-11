function encode_level_as_string(level)
    lvl = tostring(level.level_num)
    chars = level.character_blueprint
    rots = level.rotator_blueprint
    statics = level.static_tile_blueprint
    char_string = build_blueprint_string(chars)
    rot_string = build_blueprint_string(rots)
    static_string = build_blueprint_string(statics)
    return lvl.."-"..char_string.."-"..rot_string.."-"..static_string
end

function build_blueprint_string(blueprint)
    blueprint_string=""
    for i=1,#blueprint do
        blueprint_string=blueprint_string..blueprint[i][1]..","..blueprint[i][2]..","..blueprint[i][3]
        if i<#blueprint then
            blueprint_string=blueprint_string.."|"
        end
    end
    return blueprint_string
end

function decode_level_from_string(level_string)
    level = {level_num = -1, character_blueprint = {}, rotator_blueprint = {}, static_tile_blueprint = {}}
    blueprint_strings = {}
    index = 1
    for i in string.gmatch(level_string, '([^-]+)') do
        table.insert(blueprint_strings, i)
    end
    return {
        level_num = tonumber(blueprint_strings[1]),
        character_blueprint = construct_blueprint_from_string(blueprint_strings[2]),
        rotator_blueprint = construct_blueprint_from_string(blueprint_strings[3]),
        static_tile_blueprint = construct_blueprint_from_string(blueprint_strings[4])
    }
end

function construct_blueprint_from_string(blueprint_string)
    blueprint = {}
    for tile_info in string.gmatch(blueprint_string,'([^|]+)') do
        tile_print={}
        index = 1
        for i in string.gmatch(tile_info, '([^,]+)') do
            if index == 1 then
                table.insert(tile_print, i)
            else
                table.insert(tile_print, tonumber(i))
            end
        end
        table.insert(blueprint, tile_print)
    end
    return blueprint
end

level = {level_num = 2,
         character_blueprint = {
             {"deathtile", 76, 70 },
             {"deathtile", 76, 32 },
             {"deathtile", 57, 89},
             {"goal", 95, 51},
             {"player", 31, 70 }
         },
         rotator_blueprint = {
             { "vert", 57, 70 },
             { "l2", 76, 51 }
         },
         static_tile_blueprint = {
             { "corrend_left", 31, 70 },
             { "corr_horiz", 38, 70 },
             { "corrend_right", 45, 70 },
             { "singleton_horiz", 69, 70 },
             { "singleton_horiz", 76, 70 },
             { "singleton_vert", 57, 82},
             { "singleton_vert", 57, 89},
             { "corrend_down", 57, 58},
             { "corr_turn_upleft", 57, 51 },
             { "corrend_right", 64, 51 },
             { "singleton_vert", 76, 39 },
             { "singleton_vert", 76, 32},
             { "singleton_horiz", 88, 51},
             { "singleton_horiz", 95, 51}
         }}

print(encode_level_as_string(level))
