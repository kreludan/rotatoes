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

level = {level_num = 1,
 character_blueprint = {
     {"goal", 104, 63 },
     {"player", 22, 63 },
 },
 rotator_blueprint = {
     { "vert", 48, 63 },
     { "vert", 78, 63 }
 },
 static_tile_blueprint = {
     { "corrend_left", 22, 63 },
     { "corr_horiz", 29, 63 },
     { "corrend_right", 36, 63 },
     { "corrend_left", 60, 63 },
     { "corrend_right", 66, 63 },
     { "corrend_left", 90, 63},
     { "corrend_right", 97, 63 },
     { "corrend_right", 104, 63 }
 }}

print(encode_level_as_string(level))