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

level = {level_num = 2,
         character_blueprint = {
             {"goal", 85, 64, "right", 0},
             {"player", 31, 64, "right", 1}
         },
         rotator_blueprint = {
             { "horiz", 31, 64 },
             { "vert", 61, 64 },
         },
         static_tile_blueprint = {
             { "corr_singleton", 46, 64 },
             { "corr_singleton", 76, 64 },
             { "corr_singleton", 85, 64 }
         }}

print(encode_level_as_string(level))


level1 = {level_num = 1,
          character_blueprint = {
              {"goal", 85, 64, "right", 0},
              {"player", 37, 64, "right", 1}
          },
          rotator_blueprint = {
              { "vert", 61, 64 },
          },
          static_tile_blueprint = {
              { "corrend_left", 37, 64 },
              { "corrend_right", 46, 64 },
              { "corr_singleton", 76, 64 },
              { "corr_singleton", 85, 64 }
          }}