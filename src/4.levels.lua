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
    "3-goal,99,64|enemy_basic,90,64|player,21,64-horiz,45,64|horiz,75,64-corrend_left,21,64|corrend_right,30,64|corr_singleton,60,64|corr_singleton,90,64|corr_singleton,99,64|corrend_left,45,79|corr_horiz,54,79|corr_horiz,63,79|corr_horiz,72,79|corrend_right,75,79-right,0|left,1|right,1",
    "4-goal,84,30|enemy_basic,60,82|enemy_basic,60,30|player,29,61-vert,29,61|plus,60,61|horiz,60,30-corr_singleton,44,61|corrend_left,76,61|corrend_right,81,61|corrend_up,60,77|corrend_down,60,82|corr_singleton,60,45|corr_singleton,75,30|corr_singleton,84,30-right,0|right,1|right,1|right,1",
    "5-goal,101,60|enemy_basic,92,60|enemy_basic,69,60|player,19,87-plus,42,60|plus,76,60-corrend_down,19,87|corr_vert,19,78|corr_vert,19,69|corrend_right,26,60|corr_turn_upleft,19,60|corrend_left,58,60|corrend_right,60,60|corrend_down,42,44|corr_vert,42,41|corr_turn_upleft,42,32|corr_horiz,51,32|corr_horiz,60,32|corr_horiz,67,32|corr_turn_upright,76,32|corr_vert,76,41|corrend_down,76,44|corr_singleton,92,60|corr_singleton,101,60-right,0|left,1|left,1|right,1"
}

function draw_level_text()
    if level_num == 1 then
        sspr(106, 108, 23, 21, 51, 30)
    elseif level_num == 2 then
        sspr(71, 108, 35, 21, 44, 30)
    end
end
