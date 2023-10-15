
function _init()
  system_init()
  cartdata("rotato_save")
  max_distance = 7 -- distance to check for a waypoint in a direction
  level_state = "menu" -- "playing", "win", "lose", "menu", "level_select"
  in_game_menu_option = -1
  main_menu_option = 1
  level_select_option = 1
  global_game_speed = 1
  level_num = 3 -- current level
  furthest_level_unlocked = get_furthest_level()
end

function _init_level(level_num)
  update_furthest_level(level_num)
  cls()
  level_state = "playing"
  in_game_menu_option = -1
  controlled_tile = 1 -- denotes the tile currently controlled on scene
  rotators_to_draw = {} -- holds all rotating tiles
  static_tiles_to_draw = {} -- holds all non-rotating tiles
  characters_to_draw = {} -- holds all 'characters' (incl. goal and death tiles)
  waypoints = {} -- holds all waypoints across all rotating/static tiles
  level_player = {} -- holds the player character
  level_goal = {} -- holds the goal tile
  level_enemies = {} -- holds all enemy tiles
  _init_tiles()
  _init_waypoints()
  _init_character_details()
end

function _init_tiles()
  if level_blueprints[level_num]["level_num"] == nil then
    character_blueprint = decode_level_from_string(level_blueprints[level_num])["character_blueprint"]
    rotator_blueprint = decode_level_from_string(level_blueprints[level_num])["rotator_blueprint"]
    static_tile_blueprint = decode_level_from_string(level_blueprints[level_num])["static_tile_blueprint"]
  else
    character_blueprint = level_blueprints[level_num]["character_blueprint"]
    rotator_blueprint = level_blueprints[level_num]["rotator_blueprint"]
    static_tile_blueprint = level_blueprints[level_num]["static_tile_blueprint"]
  end

  _init_characters(character_blueprint)
  _init_rotators(rotator_blueprint)
  _init_static_tiles(static_tile_blueprint)
end

function _init_characters(character_blueprint)
  print(character_blueprint)
  for i = 1, count(character_blueprint) do
    add_char_to_list(
            character_blueprint[i][1], characters_to_draw, character_blueprint[i][2], character_blueprint[i][3]
    )
  end
end

function _init_character_details()
  for i=1,count(characters_to_draw) do
    characters_to_draw[i].waypoint_from = get_starting_waypoint(characters_to_draw[i], waypoints)
    if characters_to_draw[i].char_type == "player" then
      level_player = characters_to_draw[i]
    elseif characters_to_draw[i].char_type == "goal" then
      level_goal = characters_to_draw[i]
    else
      add(level_enemies, characters_to_draw[i])
    end
  end
end

function _init_rotators(rotator_blueprint)
  for i = 1, count(rotator_blueprint) do
    add_rotator_to_list(
      rotator_blueprint[i][1],
      rotators_to_draw,
      rotator_blueprint[i][2],
      rotator_blueprint[i][3]
    )
  end
end

function _init_static_tiles(static_tile_blueprint)
  for i = 1, count(static_tile_blueprint) do
    add_static_tile_to_list(
      static_tile_blueprint[i][1],
      static_tiles_to_draw,
      static_tile_blueprint[i][2],
      static_tile_blueprint[i][3]
    )
  end
end

function _init_waypoints()
  for i = 1, count(rotators_to_draw) do
    for j = 1, count(rotators_to_draw[i].draw_waypoints) do
      local waypoint = {}
      waypoint.tile_on = rotators_to_draw[i]
      waypoint.draw_waypoint = rotators_to_draw[i].draw_waypoints[j]
      add(waypoints, waypoint)
    end
  end

  for i = 1, count(static_tiles_to_draw) do
    for j = 1, count(static_tiles_to_draw[i].draw_waypoints) do
      local waypoint = {}
      waypoint.tile_on = static_tiles_to_draw[i]
      waypoint.draw_waypoint = static_tiles_to_draw[i].draw_waypoints[j]
      add(waypoints, waypoint)
    end
  end
end

function _update()
  _handleinputs()
  if level_state == "playing" then
    _handlerots()
    _handlerotends()
    _handlecharmovement()
    _handlecharcollisions()
  end
end

function _handlecharcollisions()
  for i=1, count(level_player.draw_points) do
    if level_player.draw_points[i].x == level_goal.center_x and
    level_player.draw_points[i].y == level_goal.center_y then
      in_game_menu_option = 1
      level_state = "win"
      level_num = min(count(level_blueprints), level_num + 1)
    end

    for j=1, count(level_enemies) do
      if level_player.draw_points[i].x == level_enemies[j].center_x and
      level_player.draw_points[i].y == level_enemies[j].center_y then
        in_game_menu_option = 1
        level_state = "lose"
      end
    end
  end
end


function _handlecharmovement()
  for i = 1, count(characters_to_draw) do
    if characters_to_draw[i].rotating == false then
      get_next_waypoint(characters_to_draw[i], waypoints, max_distance)
      characters_to_draw[i].tile_on = get_tile_on(characters_to_draw[i])
      characters_to_draw[i] = move_character(characters_to_draw[i])
    end
  end
end

function _handleinputs()
  if level_state == "menu" then
    handle_menu_input()
  elseif level_state == "level_select" then
    handle_level_select_input()
  elseif level_state=="win" then
    handle_win_menu_input()
  elseif level_state=="lose" then
    handle_lose_menu_input()
  else
    handle_playing_input()
  end
end

function handle_playing_input()
  if btnp(🅾️) then
    if controlled_tile
        == count(rotators_to_draw) then
      controlled_tile = 1
    else
      controlled_tile += 1
    end
  elseif btnp(❎) then
    if controlled_tile == 1 then
      controlled_tile = count(rotators_to_draw)
    else
      controlled_tile -= 1
    end
  end

  if btnp(⬅️) or btnp(➡️) then
    i = controlled_tile
    if rotators_to_draw[i].rotating
        == false then
      local rotatedir = btnp(⬅️) and 1 or -1
      rotators_to_draw[i] = set_rotating(rotators_to_draw[i], rotatedir)
      for j = 1, count(characters_to_draw) do
        if characters_to_draw[j].tile_on == rotators_to_draw[i] then
          characters_to_draw[j] = set_rotating(characters_to_draw[j], rotatedir)
        end
      end
    end
  end
end

function _handlerots()
  for i = 1, count(rotators_to_draw) do
    if rotators_to_draw[i].rotating then
      rotators_to_draw[i] = rotate_tile(rotators_to_draw[i])
    end
  end
  for i = 1, count(characters_to_draw) do
    if characters_to_draw[i].rotating then
      characters_to_draw[i] = rotate_tile(characters_to_draw[i])
    end
  end
end

function _handlerotends()
  for i = 1, count(rotators_to_draw) do
    if rotators_to_draw[i].rotating then
      rotators_to_draw[i].thetacounter += rotators_to_draw[i].theta
      check_rotate_end(rotators_to_draw[i])
    end
  end
  for i = 1, count(characters_to_draw) do
    if characters_to_draw[i].rotating then
      characters_to_draw[i].thetacounter += characters_to_draw[i].theta
      check_rotate_end(characters_to_draw[i])
    end
  end
end

function _draw()
  adjust_for_colorblindness()
  _draw_ui_elements()
  if level_state == "menu" then
    generate_main_menu(main_menu_option)
  elseif level_state == "level_select" then
    generate_level_select(level_select_option)
  elseif level_state == "win" then
    generate_win_menu(in_game_menu_option)
  elseif level_state == "lose" then
    generate_lose_menu(in_game_menu_option)
  elseif level_state == "playing" then
    cls()
    _draw_ui_elements()
    print(tostring(level_num), 4, 4, 7)
    draw_level_text()
    for i = 1, count(rotators_to_draw) do
      if i == controlled_tile then
        draw_tile(rotators_to_draw[i], true)
      else
        draw_tile(rotators_to_draw[i], false)
      end
    end

    for i = 1, count(static_tiles_to_draw) do
      draw_tile(static_tiles_to_draw[i], false)
    end

    for i = 1, count(characters_to_draw) do
      draw_tile(characters_to_draw[i], false)
    end
  end


end

function _draw_ui_elements()
  rect(0, 0, 127, 127, 7)
end