function decode_level_from_string(level_string)
    blueprint_strings = split(level_string, "-", true)
    return {
        level_num = blueprint_strings[1],
        character_blueprint = construct_blueprint_from_string(blueprint_strings[2]),
        rotator_blueprint = construct_blueprint_from_string(blueprint_strings[3]),
        static_tile_blueprint = construct_blueprint_from_string(blueprint_strings[4])
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
    "1-goal,104,63|player,22,63-vert,48,63|vert,78,63-corrend_left,22,63|corr_horiz,29,63|corrend_right,36,63|corrend_left,60,63|corrend_right,66,63|corrend_left,90,63|corrend_right,97,63|corrend_right,104,63",
    "2-deathtile,76,70|deathtile,76,32|deathtile,57,89|goal,95,51|player,31,70-vert,57,70|l2,76,51-corrend_left,31,70|corr_horiz,38,70|corrend_right,45,70|singleton_horiz,69,70|singleton_horiz,76,70|singleton_vert,57,82|singleton_vert,57,89|corrend_down,57,58|corr_turn_upleft,57,51|corrend_right,64,51|singleton_vert,76,39|singleton_vert,76,32|singleton_horiz,88,51|singleton_horiz,95,51",
    "3-goal,104,63|player,22,63|enemy_basic,90,63-horiz,48,63|horiz,78,63-corrend_left,22,63|corr_horiz,29,63|corrend_right,36,63|corrend_left,60,63|corrend_left,48,75|corr_horiz,55,75|corr_horiz,62,75|corr_horiz,69,75|corr_horiz,76,75|corrend_right,78,75|corrend_right,66,63|corrend_left,90,63|corrend_right,97,63|corrend_right,104,63",
    {level_num = 4,
     character_blueprint = {
         {"player", 45, 80 },
     },
     rotator_blueprint = {
         { "horiz", 50, 80 },
         { "plus", 64, 42 }
     },
     static_tile_blueprint = {
         { "corrend_down", 50, 68 },
         { "corr_turn_upleft", 50, 61 },
         { "corr_horiz", 57, 61 },
         { "corr_turn_downright", 64, 61 },
         { "corrend_up", 64, 54 }
     }},
    "4-goal,104,63|player,22,63-vert,48,63|vert,78,63-corrend_left,22,63|corr_horiz,29,63|corrend_right,36,63|corrend_left,60,63|corrend_right,66,63|corrend_left,90,63|corrend_right,97,63|corrend_right,104,63",
    "5-goal,104,63|player,22,63-vert,48,63|vert,78,63-corrend_left,22,63|corr_horiz,29,63|corrend_right,36,63|corrend_left,60,63|corrend_right,66,63|corrend_left,90,63|corrend_right,97,63|corrend_right,104,63",
    "6-goal,104,63|player,22,63-vert,48,63|vert,78,63-corrend_left,22,63|corr_horiz,29,63|corrend_right,36,63|corrend_left,60,63|corrend_right,66,63|corrend_left,90,63|corrend_right,97,63|corrend_right,104,63",
    "7-goal,104,63|player,22,63-vert,48,63|vert,78,63-corrend_left,22,63|corr_horiz,29,63|corrend_right,36,63|corrend_left,60,63|corrend_right,66,63|corrend_left,90,63|corrend_right,97,63|corrend_right,104,63",
    "8-goal,104,63|player,22,63-vert,48,63|vert,78,63-corrend_left,22,63|corr_horiz,29,63|corrend_right,36,63|corrend_left,60,63|corrend_right,66,63|corrend_left,90,63|corrend_right,97,63|corrend_right,104,63",
    "9-goal,104,63|player,22,63-vert,48,63|vert,78,63-corrend_left,22,63|corr_horiz,29,63|corrend_right,36,63|corrend_left,60,63|corrend_right,66,63|corrend_left,90,63|corrend_right,97,63|corrend_right,104,63",
    "10-goal,104,63|player,22,63-vert,48,63|vert,78,63-corrend_left,22,63|corr_horiz,29,63|corrend_right,36,63|corrend_left,60,63|corrend_right,66,63|corrend_left,90,63|corrend_right,97,63|corrend_right,104,63",
    {level_num = 11,
     character_blueprint = {
         {"goal", 104, 63 },
         {"player", 22, 63 },
     },
     rotator_blueprint = {
         { "horiz", 48, 63 },
         { "horiz", 78, 63 }
     },
     static_tile_blueprint = {
         { "corrend_left", 22, 63 },
         { "corr_horiz", 29, 63 },
         { "corrend_right", 36, 63 },
         { "corrend_left", 60, 63 },
         { "corrend_left", 48, 75},
         { "corrend_right", 78, 75},
         { "corrend_right", 66, 63 },
         { "corrend_left", 90, 63},
         { "corrend_right", 97, 63 },
         { "corrend_right", 104, 63 }
     }},
}

function draw_level_text()
    if level_num == 1 then
        sspr(0, 16, 8, 5, 39, 37)
        sspr(0, 24, 8, 5, 50, 37)
        print("rotate", 38, 45)
        sspr(0, 30, 5, 7, 72, 36)
        sspr(6, 30, 5, 7, 80, 36)
        print("swap", 71, 45)
    end
end
