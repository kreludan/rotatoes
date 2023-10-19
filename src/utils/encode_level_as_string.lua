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

level = {level_num = 5,
         character_blueprint = {
             {"goal", 101, 60, "right", 0},
             {"enemy_basic", 92, 60, "left", 1},
             {"enemy_basic", 69, 60, "left", 1},
             {"player", 19, 87, "right", 1}
         },
         rotator_blueprint = {
             { "plus", 42, 60 },
             { "plus", 76, 60 },
         },
         static_tile_blueprint = {
             {"corrend_down", 19, 87 },
             {"corr_vert", 19, 78},
             {"corr_vert", 19, 69},
             {"corrend_right", 26, 60},
             {"corr_turn_upleft", 19, 60},
             {"corrend_left", 58, 60},
             {"corrend_right", 60, 60},
             {"corrend_down", 42, 44},
             {"corr_vert", 42, 41},
             {"corr_turn_upleft", 42, 32},
             {"corr_horiz", 51, 32},
             {"corr_horiz", 60, 32},
             {"corr_horiz", 67, 32},
             {"corr_turn_upright", 76, 32},
             {"corr_vert", 76, 41},
             {"corrend_down", 76, 44},
             {"corr_singleton", 92, 60},
             {"corr_singleton", 101, 60}
         }}

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


level2 = {level_num = 2,
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

level3 = {level_num = 3,
          character_blueprint = {
              {"goal", 99, 64, "right", 0},
              {"enemy_basic", 90, 64, "left", 1},
              {"player", 21, 64, "right", 1}
          },
          rotator_blueprint = {
              { "horiz", 45, 64 },
              { "horiz", 75, 64 },
          },
          static_tile_blueprint = {
              { "corrend_left", 21, 64 },
              { "corrend_right", 30, 64 },
              { "corr_singleton", 60, 64 },
              { "corr_singleton", 90, 64 },
              { "corr_singleton", 99, 64 },
              { "corrend_left", 45, 79 },
              { "corr_horiz", 54, 79 },
              { "corr_horiz", 63, 79 },
              { "corr_horiz", 72, 79 },
              { "corrend_right", 75, 79 }
          }}

level4 = {level_num = 4,
          character_blueprint = {
              {"goal", 84, 30, "right", 0},
              {"enemy_basic", 60, 82, "right", 1},
              {"enemy_basic", 60, 30, "right", 1},
              {"player", 29, 61, "right", 1}
          },
          rotator_blueprint = {
              { "vert", 29, 61 },
              { "plus", 60, 61 },
              { "horiz", 60, 30}
          },
          static_tile_blueprint = {
              {"corr_singleton", 44, 61},
              {"corrend_left", 76, 61 },
              {"corrend_right", 81, 61 },
              {"corrend_up", 60, 77},
              {"corrend_down", 60, 82 },
              {"corr_singleton", 60, 45},
              {"corr_singleton", 75, 30},
              {"corr_singleton", 84, 30}
          }}

unused_level_1 = {level_num = 999,
                  character_blueprint = {
                      {"goal", 96, 30, "right", 0},
                      {"enemy_basic", 60, 45, "right", 1},
                      {"enemy_basic", 72, 30, "right", 1},
                      {"player", 35, 94, "right", 1}
                  },
                  rotator_blueprint = {
                      { "horiz", 35, 94 },
                      { "plus", 60, 61 },
                      { "horiz", 72, 30}
                      --{ "horiz", 75, 64 },
                  },
                  static_tile_blueprint = {
                      {"corrend_down", 35, 79},
                      {"corr_vert", 35, 70 },
                      {"corr_turn_upleft", 35, 61},
                      {"corrend_right", 44, 61},
                      {"corrend_left", 76, 61 },
                      {"corrend_right", 81, 61 },
                      {"corrend_up", 60, 77},
                      {"corrend_down", 60, 82 },
                      {"corrend_left", 60, 45},
                      {"corr_horiz", 69, 45},
                      {"corrend_right", 72, 45},
                      {"corr_singleton", 87, 30},
                      {"corr_singleton", 96, 30}
                  }}

levels = {level1, level2, level3, level4}

print(encode_level_as_string(level))
