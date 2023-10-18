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
}

function draw_level_text()
    if level_num == 1 then
        sspr(106, 108, 23, 21, 51, 30)
    elseif level_num == 2 then
        sspr(71, 108, 35, 21, 44, 30)
    end
end
