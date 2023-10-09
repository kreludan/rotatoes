level_blueprints = {
    {level_num = 1,
     character_blueprint = {
         {"goal", 96, 63},
         {"player", 30, 63}
     },
     rotator_blueprint = {
         { "vert", 63, 63 },
     },
     static_tile_blueprint = {
         { "corrend_left", 30, 63 },
         { "corr_horiz", 37, 63 },
         { "corr_horiz", 44, 63 },
         { "corrend_right", 51, 63 },
         { "corrend_left", 75, 63 },
         { "corr_horiz", 82, 63 },
         { "corrend_right", 89, 63 },
         { "corrend_right", 96, 63 },
     }},
    {level_num = 2,
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
     }},
    {level_num = 3,
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
}

function draw_level_text()
    if level_num == 1 then
        sspr(0, 16, 8, 5, 54, 38)
        sspr(0, 24, 8, 5, 65, 38)
        print("rotate", 52, 45)
    elseif level_num == 2 then
        sspr(0, 30, 5, 7, 57, 36)
        sspr(6, 30, 5, 7, 65, 36)
        print("tileswap", 48, 45)
    end
end
