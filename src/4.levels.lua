function decode_level_from_string(level_string)
    blueprint_strings = split(level_string, "-", true)
    return {
        level_num = blueprint_strings[1],
        character_blueprint = construct_blueprint_from_string(blueprint_strings[2]),
        rotator_blueprint = construct_blueprint_from_string(blueprint_strings[3]),
        static_tile_blueprint = construct_blueprint_from_string(blueprint_strings[4]),
        character_info_blueprint = construct_blueprint_from_string(blueprint_strings[5])
    }
end

function construct_blueprint_from_string(blueprint_string)
    blueprint = {}
    tile_infos = split(blueprint_string, '|', false)
    for i=1,count(tile_infos) do
        add(blueprint, split(tile_infos[i], ',', true))
    end
    return blueprint
end

level_blueprints = {
    "1-goal,85,64|player,37,64-vert,61,64-corrend_left,37,64|corrend_right,46,64|corr_singleton,76,64|corr_singleton,85,64-right,0|right,1",
    "2-goal,85,64|player,31,64-horiz,31,64|vert,61,64-corr_singleton,46,64|corr_singleton,76,64|corr_singleton,85,64-right,0|right,1",
    "3-goal,99,64|enemy_basic,90,64|player,21,64-horiz,45,64|horiz,75,64-corrend_left,21,64|corrend_right,30,64|corr_singleton,60,64|corr_singleton,90,64|corr_singleton,99,64|corrend_left,45,79|corr_horiz,54,79|corr_horiz,63,79|corr_horiz,72,79|corrend_right,75,79-right,0|left,1|right,1"
}

function draw_level_text()
    if level_num == 1 then
        sspr(106, 108, 23, 21, 51, 30)
    elseif level_num == 2 then
        sspr(71, 108, 35, 21, 44, 30)
    end
end
