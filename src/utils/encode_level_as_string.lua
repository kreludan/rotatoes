function encode_level_as_string(level)
    lvl = tostring(level.level_num)
    chars = level.character_blueprint
    rots = level.rotator_blueprint
    statics = level.static_tile_blueprint
    char_string = build_blueprint_string(chars)
    rot_string = build_blueprint_string(rots)
    static_string = build_blueprint_string(statics)
    char_info_string = build_char_info_blueprint_string(chars)
    return lvl.."-"..char_string.."-"..rot_string.."-"..static_string.."-"..char_info_string
end

function build_char_info_blueprint_string(blueprint)
    blueprint_string = ""
    for i=1,#blueprint do
        blueprint_string=blueprint_string..blueprint[i][4]..","..blueprint[i][5]
        if i<#blueprint then
            blueprint_string=blueprint_string.."|"
        end
    end
    return blueprint_string
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

level = {level_num = 1,
         character_blueprint = {
             {"goal", 88, 64, "right", 0},
             {"player", 40, 64, "right", 1}
         },
         rotator_blueprint = {
             { "horiz", 64, 64 },
         },
         static_tile_blueprint = {
             { "corrend_left", 40, 64 },
             { "corrend_right", 49, 64 },
             { "corr_singleton", 79, 64 },
             { "corr_singleton", 88, 64 }
         }}

print(encode_level_as_string(level))