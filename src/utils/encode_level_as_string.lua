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

level = {level_num = 7,
         character_blueprint = {
             {"goal", 63, 60, "right", 0},
             {"enemy_basic", 47, 60, "right", 1},
             {"enemy_basic", 79, 60, "left", 1},
             {"enemy_basic", 63, 42, "down", 1},
             {"enemy_basic", 63, 76, "up", 1},
             {"player", 32, 27, "right", 1},
         },
         rotator_blueprint = {
             { "vert", 32, 60 },
             { "horiz", 63, 27},
             { "vert", 94, 60},
             { "horiz", 63, 91}
         },
         static_tile_blueprint = {
             {"corr_singleton", 63, 60},
             {"corrend_left", 47, 60},
             {"corrend_right", 54, 60},
             {"corrend_left", 72, 60},
             {"corrend_right", 79, 60},
             {"corrend_up", 63, 42},
             {"corrend_down", 63, 51},
             {"corrend_up", 63, 69},
             {"corrend_down", 63, 76},

             {"corrend_up", 32, 75},
             {"corr_vert", 32, 84},
             {"corr_turn_downleft", 32, 91},

             {"corr_horiz", 40, 91},
             {"corrend_right", 48, 91},

             {"corrend_left", 78, 91},
             {"corr_horiz", 86, 91},
             {"corr_turn_downright", 94, 91},

             {"corr_vert", 94, 83},
             {"corrend_up", 94, 75},

             {"corrend_down", 32, 45},
             {"corr_vert", 32,36},
             {"corr_turn_upleft", 32,27},

             {"corr_horiz", 40, 27},
             {"corrend_right", 48, 27},

             {"corrend_left", 78, 27},
             {"corr_horiz", 86, 27},
             {"corr_turn_upright", 94, 27},

             {"corr_vert", 94, 36},
             {"corrend_down", 94, 45}
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
              {"goal", 101, 60, "right", 0},
              {"enemy_basic", 92, 60, "left", 1},
              {"enemy_basic", 42, 67, "up", 1},
              {"player", 55, 78, "left", 1}
          },
          rotator_blueprint = {
              { "plus", 42, 60 },
              { "plus", 76, 60 },
          },
          static_tile_blueprint = {
              {"corrend_right", 55, 78},
              {"corr_horiz", 46, 78},
              {"corr_horiz", 37, 78},
              {"corr_horiz", 28, 78},
              {"corr_turn_downleft", 19, 78},
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

level5 = {level_num = 5,
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

level6 = {level_num = 6,
          character_blueprint = {
              {"goal", 89, 95, "right", 0},
              {"enemy_basic", 89, 77, "up", 1},
              {"enemy_basic", 89, 36, "down", 1},
              {"enemy_basic", 41, 86, "up", 1},
              {"player", 41, 27, "down", 1},
          },
          rotator_blueprint = {
              { "l1", 41, 61 },
              { "l3", 89, 61 }
          },
          static_tile_blueprint = {
              {"corrend_up", 41, 27},
              {"corr_vert", 41, 36},
              {"corrend_down", 41, 45},

              {"corrend_left", 57, 61},
              {"corr_horiz", 64, 61},
              {"corrend_right", 73, 61},

              {"corrend_up", 89, 36},
              {"corrend_down", 89, 45},

              {"corrend_up", 41, 77},
              {"corrend_down", 41, 86},

              {"corrend_up", 89, 77},
              {"corrend_down", 89, 86},
              {"corr_singleton", 89, 95}
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

levels = {level1, level2, level3, level4, level5, level6}

print(encode_level_as_string(level))
