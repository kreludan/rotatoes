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

level = {level_num = 4,
         character_blueprint = {
             {"goal", 83, 28 },
             {"enemy_basic", 40, 47},
             {"enemy_basic", 47, 47},
             {"player", 40, 85 }
         },
         rotator_blueprint = {
             { "horiz", 45, 85 },
             { "plus", 59, 47 },
             { "horiz", 83, 47 }
         },
         static_tile_blueprint = {
             { "corrend_down", 45, 73 },
             { "corr_turn_upleft", 45, 66 },
             { "corr_horiz", 52, 66 },
             { "corr_turn_downright", 59, 66 },
             { "corrend_up", 59, 59 },
             { "corrend_right", 47, 47 },
             { "corrend_left", 40, 47 },
             { "corrend_down", 59, 35},
             { "corrend_up", 59, 28 },
             { "corr_singleton", 71, 47 },
             { "corr_singleton", 83, 35 },
             { "invisible_tile", 83, 28 }
         }}

print(encode_level_as_string(level))