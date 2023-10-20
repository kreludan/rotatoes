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
    "4-goal,101,60|enemy_basic,92,60|enemy_basic,42,67|player,55,78-plus,42,60|plus,76,60-corrend_right,55,78|corr_horiz,46,78|corr_horiz,37,78|corr_horiz,28,78|corr_turn_downleft,19,78|corr_vert,19,69|corrend_right,26,60|corr_turn_upleft,19,60|corrend_left,58,60|corrend_right,60,60|corrend_down,42,44|corr_vert,42,41|corr_turn_upleft,42,32|corr_horiz,51,32|corr_horiz,60,32|corr_horiz,67,32|corr_turn_upright,76,32|corr_vert,76,41|corrend_down,76,44|corr_singleton,92,60|corr_singleton,101,60-right,0|left,1|up,1|left,1",
    "5-goal,84,30|enemy_basic,60,82|enemy_basic,60,30|player,29,61-vert,29,61|plus,60,61|horiz,60,30-corr_singleton,44,61|corrend_left,76,61|corrend_right,81,61|corrend_up,60,77|corrend_down,60,82|corr_singleton,60,45|corr_singleton,75,30|corr_singleton,84,30-right,0|right,1|right,1|right,1",
    "6-goal,89,95|enemy_basic,89,77|enemy_basic,89,36|enemy_basic,41,86|player,41,27-l1,41,61|l3,89,61-corrend_up,41,27|corr_vert,41,36|corrend_down,41,45|corrend_left,57,61|corr_horiz,64,61|corrend_right,73,61|corrend_up,89,36|corrend_down,89,45|corrend_up,41,77|corrend_down,41,86|corrend_up,89,77|corrend_down,89,86|corr_singleton,89,95-right,0|up,1|down,1|up,1|down,1",
    "7-goal,63,60|enemy_basic,47,60|enemy_basic,79,60|enemy_basic,63,42|enemy_basic,63,76|player,32,27-vert,32,60|horiz,63,27|vert,94,60|horiz,63,91-corr_singleton,63,60|corrend_left,47,60|corrend_right,54,60|corrend_left,72,60|corrend_right,79,60|corrend_up,63,42|corrend_down,63,51|corrend_up,63,69|corrend_down,63,76|corrend_up,32,75|corr_vert,32,84|corr_turn_downleft,32,91|corr_horiz,40,91|corrend_right,48,91|corrend_left,78,91|corr_horiz,86,91|corr_turn_downright,94,91|corr_vert,94,83|corrend_up,94,75|corrend_down,32,45|corr_vert,32,36|corr_turn_upleft,32,27|corr_horiz,40,27|corrend_right,48,27|corrend_left,78,27|corr_horiz,86,27|corr_turn_upright,94,27|corr_vert,94,36|corrend_down,94,45-right,0|right,1|left,1|down,1|up,1|right,1",
    "8-goal,33,31|enemy_basic,42,31|enemy_basic,73,88|player,73,79-horiz,73,31-corr_singleton,33,31|corrend_left,42,31|corr_horiz,50,31|corrend_right,58,31|corrend_up,73,46|corr_vert,73,55|corr_vert,73,64|corr_vert,73,73|corr_vert,73,79|corrend_down,73,88-right,0|right,1|up,1|up,1"
}

function draw_level_text()
    if level_num == 1 then
        sspr(106, 108, 23, 21, 51, 30)
    elseif level_num == 2 then
        sspr(71, 108, 35, 21, 44, 30)
    end
end
