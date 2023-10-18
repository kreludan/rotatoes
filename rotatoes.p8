pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
--global

function _init()
  system_init()
  cartdata("rotato_save")
  max_distance = 9 -- distance to check for a waypoint in a direction
  level_state = "menu" -- "playing", "win", "lose", "menu", "level_select"
  in_game_menu_option = -1
  main_menu_option = 1
  level_select_option = 1
  global_game_speed = 1
  level_num = 1 -- current level
  furthest_level_unlocked = get_furthest_level()
end

function _init_level(level_num)
  update_furthest_level(level_num)
  cls(7) -- clear screen, set as white
  palt(15, true) -- beige color as transparency is true
  palt(0, false) -- black color as transparency is false

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
    character_info_blueprint = decode_level_from_string(level_blueprints[level_num])["character_info_blueprint"]
  else
    character_blueprint = level_blueprints[level_num]["character_blueprint"]
    rotator_blueprint = level_blueprints[level_num]["rotator_blueprint"]
    static_tile_blueprint = level_blueprints[level_num]["static_tile_blueprint"]
    character_info_blueprint = nil
  end

  _init_characters(character_blueprint)
  _init_rotators(rotator_blueprint)
  _init_static_tiles(static_tile_blueprint)
  _init_character_orientations()
end

function _init_characters(character_blueprint)
  for i = 1, count(character_blueprint) do
    add_tile_to_list(
            character_blueprint[i][1], character_blueprint[i][2], character_blueprint[i][3]
    )
  end
end

function _init_character_orientations()
  if character_info_blueprint == nil or count(characters_to_draw) > count(character_info_blueprint) then
    for i=1, count(characters_to_draw) do
      initialize_moving_right(characters_to_draw[i])
      characters_to_draw[i].char_speed = 0
    end
  end

  for i = 1, count(characters_to_draw) do
    characters_to_draw[i].char_speed = character_info_blueprint[i][2]
    dir = character_info_blueprint[i][1]
    if dir == "right" then
      initialize_moving_right(characters_to_draw[i])
    elseif dir == "left" then
      initialize_moving_left(characters_to_draw[i])
    elseif dir == "up" then
      initialize_moving_up(characters_to_draw[i])
    else
      initialize_moving_down(characters_to_draw[i])
    end
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
    add_tile_to_list(
      rotator_blueprint[i][1],
      rotator_blueprint[i][2],
      rotator_blueprint[i][3]
    )
  end
end

function _init_static_tiles(static_tile_blueprint)
  for i = 1, count(static_tile_blueprint) do
    add_tile_to_list(
      static_tile_blueprint[i][1],
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
  if btnp(❎) then
    if controlled_tile
        == count(rotators_to_draw) then
      controlled_tile = 1
    else
      controlled_tile += 1
    end
  elseif btnp(🅾️) then
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
    cls(7) -- clear screen, set as white
    palt(15, true) -- beige color as transparency is true
    palt(0, false) -- black color as transparency is false

    _draw_ui_elements()
    print(tostring(level_num), 4, 4, 0)
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
  rect(1, 1, 126, 126, 0)
end
-->8
--tile_operations
function create_point(x, y, c)
  point = {}
  point.x = x
  point.y = y
  point.x0 = 0
  point.y0 = 0
  point.color = c
  return point
end

function create_point_w_0s(x, y, x0, y0, c)
  point = {}
  point.x = x
  point.y = y
  point.x0 = x0
  point.y0 = y0
  point.color = c
  return point
end

function create_tile(points, center_x, center_y, spritestart_x, spritestart_y, selectedspritestart_x, selectedspritestart_y, lockedspritestart_x, lockedspritestart_y, waypoints)
  local tile = {}
  tile.points = points
  tile.draw_points = {}
  tile.center_x = center_x
  tile.center_y = center_y
  tile.center_x0 = 0
  tile.center_y0 = 0
  if waypoints == nil then
    tile.waypoints = {}
  else
    tile.waypoints = waypoints
  end
  tile.draw_waypoints = {}
  tile.spritestart_x = spritestart_x
  tile.spritestart_y = spritestart_y
  tile.selectedspritestart_x = selectedspritestart_x
  tile.selectedspritestart_y = selectedspritestart_y
  tile.lockedspritestart_x = lockedspritestart_x
  tile.lockedspritestart_y = lockedspritestart_y
  tile.theta = 15
  tile.rotating = false
  tile.rotatedir = 0
  tile.thetacounter = 0
  tile.is_character = false
  tile.char_type = nil
  tile.parent_tile = nil
  tile.movement_dir = nil
  tile.char_speed = nil
  tile.tile_on = nil
  tile.waypoint_from = nil
  tile.waypoint_to = nil
  return tile
end

function cast_tile_to_char(tile, char_type)
  tile.is_character = true
  tile.char_type = char_type
  return tile
end

function create_drawable_tile(tile, x, y)
  --translate the center
  centered_x = x - tile.center_x
  centered_y = y - tile.center_y

  --translate the waypoints
  for i = 1, count(tile.waypoints) do
    add(
      tile.draw_waypoints,
      create_point(
        tile.waypoints[i].x
            + centered_x,
        tile.waypoints[i].y
            + centered_y,
        tile.waypoints[i].color
      )
    )
  end

  --generate each draw point
  for i = 1, count(tile.points) do
    add(
      tile.draw_points,
      create_point(
        tile.points[i].x + centered_x,
        tile.points[i].y + centered_y,
        tile.points[i].color
      )
    )
  end

  --adjust the center
  tile.center_x = x
  tile.center_y = y
  return tile
end

function draw_tile(tile, is_selected)
  if is_selected then
    startdraw_x = tile.selectedspritestart_x
    startdraw_y = tile.selectedspritestart_y
  else
    startdraw_x = tile.spritestart_x
    startdraw_y = tile.spritestart_y
  end

  for i = 1, count(tile.points) do
    --pset(
    -- tile.draw_points[i].x,
    -- tile.draw_points[i].y,
    --tile.draw_points[i].color)
    sspr(
      startdraw_x
          + tile.points[i].x,
      startdraw_y
          + tile.points[i].y,
      1, 1,
      tile.draw_points[i].x,
      tile.draw_points[i].y
    )
  end
end

function sp2xy(sp)
  sx, sy = sp % 16 * 8, flr(sp \ 16) * 8
  return sx, sy
end

function create_rotated_point(point, x0, y0, theta)
  sina = sin(theta / 360)
  cosa = cos(theta / 360)
  x = point.x - x0
  y = point.y - y0
  rotx = cosa * x - sina * y
  roty = sina * x + cosa * y
  newx = rotx + x0
  newy = roty + y0
  newpoint = create_point_w_0s(
    newx, newy, point.x0, point.y0,
    point.color
  )
  return newpoint
end

function get_rotation_cx_cy(tile)
  local cx = tile.center_x
  local cy = tile.center_y
  if tile.is_character then
    cx = tile.tile_on.center_x
    cy = tile.tile_on.center_y
  end
  return cx, cy
end

function rotate_tile(tile)
  local cx, cy = get_rotation_cx_cy(tile)
  for i = 1, count(tile.draw_points) do
    local newpoint = create_rotated_point(
      tile.draw_points[i],
      cx, cy, tile.theta * tile.rotatedir
    )
    tile.draw_points[i] = newpoint
  end
  return tile
end

function set_rotating(tile, rotatedir)
  tile.rotating = true
  set_origins(tile)
  tile.rotatedir = rotatedir
  tile.thetacounter = 0
  return tile
end

function set_origins(tile)
  tile.center_x0 = tile.center_x
  tile.center_y0 = tile.center_y
  for i = 1, count(tile.draw_points) do
    tile.draw_points[i].x0 = tile.draw_points[i].x
    tile.draw_points[i].y0 = tile.draw_points[i].y
  end
  for i = 1, count(tile.draw_waypoints) do
    tile.draw_waypoints[i].x0 = tile.draw_waypoints[i].x
    tile.draw_waypoints[i].y0 = tile.draw_waypoints[i].y
  end
  return tile
end

function check_rotate_end(tile)
  if tile.thetacounter == 90 then
    tile = fix_end_rot(tile, tile.draw_waypoints)
    tile = fix_end_rot(tile, tile.draw_points)
    if tile.is_character then
      fix_end_rot_char(tile)
    end
    tile.rotating = false
    tile.thetacounter = 0
  end
end

function fix_end_rot(tile, tile_points)
  local cx, cy = get_rotation_cx_cy(tile)
  for i = 1, count(tile_points) do
    tpx0 = tile_points[i].x0 - cx
    tpy0 = tile_points[i].y0 - cy
    if tile.rotatedir == 1 then
      tile_points[i].x = tpy0 + cx
      tile_points[i].y = -tpx0 + cy
    elseif tile.rotatedir == -1 then
      tile_points[i].x = -tpy0 + cx
      tile_points[i].y = tpx0 + cy
    end
  end
  return tile
end

function fix_end_rot_char(tile)
  local cx, cy = get_rotation_cx_cy(tile)
  tpx0 = tile.center_x0 - cx
  tpy0 = tile.center_y0 - cy
  if tile.rotatedir == 1 then
    tile.center_x = tpy0 + cx
    tile.center_y = -tpx0 + cy
    turn_movement_counterclockwise(tile)
  elseif tile.rotatedir == -1 then
    tile.center_x = -tpy0 + cx
    tile.center_y = tpx0 + cy
    turn_movement_clockwise(tile)
  end
end

function translate_tile(tile, x_translate, y_translate)
  --translate the center
  tile.center_x += x_translate
  tile.center_y += y_translate

  --translate each draw point
  for i = 1, count(tile.draw_points) do
    tile.draw_points[i].x += x_translate
    tile.draw_points[i].y += y_translate
  end

  return tile
end
-->8
--tile_creation
rotator_blueprint_strings = {
  l1 = "0,0:8,15|9,7:15,15-4,11-4,4|4,11|11,11-32,10-32,27-32,44",
  l2 = "0,0:8,15|9,0:15,8-4,4-4,11|4,4|11,4-49,10-49,27-49,44",
  l3 = "0,0:6,8|7,0:15,15-11,4-4,4|11,4|11,11-66,10-66,27-66,44",
  l4 = "0,7:6,15|7,0:15,15-11,11-4,11|11,11|11,4-83,10-83,27-83,44",
  plus = "0,7:6,15|7,0:15,22|16,7:22,15-11,11-4,11|11,4|11,11|11,18|18,11-100,10-100,34-100,58",
  horiz = "0,0:20,8-10,4-4,4|10,4|16,4-0,10-0,20-0,30",
  vert = "0,0:8,20-4,10-4,4|4,10|4,16-22,10-22,32-12,40"
}

static_tile_blueprint_strings = {
  corr_singleton = "0,0:8,8-4,4-4,4-0,0-nil-nil",
  corrend_left = "0,0:8,8-4,4-4,4-10,0-nil-nil",
  corrend_up = "0,0:8,8-4,4-4,4-20,0-nil-nil",
  corrend_right = "0,0:8,8-4,4-4,4-30,0-nil-nil",
  corrend_down = "0,0:8,8-4,4-4,4-40,0-nil-nil",
  corr_turn_downleft = "0,0:8,8-4,4-4,4-50,0-nil-nil",
  corr_turn_upleft = "0,0:8,8-4,4-4,4-60,0-nil-nil",
  corr_turn_upright = "0,0:8,8-4,4-4,4-70,0-nil-nil",
  corr_turn_downright = "0,0:8,8-4,4-4,4-80,0-nil-nil",
  corr_horiz = "0,0:8,8-4,4-4,4-90,0-nil-nil",
  corr_vert = "0,0:8,8-4,4-4,4-100,0-nil-nil"
}

character_blueprint_strings = {
  goal = "0,0:8,8-4,4-4,4-110,0-nil-nil",
  deathtile = "0,0:8,8-4,4-4,4-119,0-nil-nil",
  player = "0,2:5,2|3,0|4,1|4,3|3,4-2,2-nil-0,123-nil-nil",
  enemy_basic = "0,2:3,2|1,0|2,1|2,3|1,4-2,2-nil-7,123-nil-nil",
  tilelocker_enemy = "0,2:3,2|2,0|3,1|3,3|2,4-1,2-nil-12,123-nil-nil",
  stopstart_enemy = "0,0:0,4|1,2:3,2|2,1|2,3-1,2-nil-17,123-nil-nil"
}

function create_tile_blueprint_from_name(tile_name, blueprint_string_set)
  blueprint_strings = split(blueprint_string_set[tile_name], "-", false)
  return {
    name = tile_name,
    points = generate_point_list_from_blueprint(blueprint_strings[1]),
    waypoints = generate_point_list_from_blueprint(blueprint_strings[3]),
    center = generate_xy_struct_from_blueprint(blueprint_strings[2]),
    spritestart_general = generate_xy_struct_from_blueprint(blueprint_strings[4]),
    spritestart_selected = generate_xy_struct_from_blueprint(blueprint_strings[5]),
    spritestart_locked = generate_xy_struct_from_blueprint(blueprint_strings[6])
  }
end

function generate_point_list_from_blueprint(blueprint_string)
  if blueprint_string == "nil" then
    return nil
  end
  points_list = {}
  point_strings = split(blueprint_string, "|", false)
  for i=1, count(point_strings) do
    if #point_strings[i] < 7 then
      point_info = split(point_strings[i], ",", true)
      add(points_list, create_point(point_info[1], point_info[2], 1))
    else
      rect_coords = split(point_strings[i], ":", false)
      x0y0 = split(rect_coords[1], ",", true)
      x0, y0 = x0y0[1], x0y0[2]
      x1y1 = split(rect_coords[2], ",", true)
      x1, y1 = x1y1[1], x1y1[2]
      for j=x0,x1 do
        for k=y0,y1 do
          add(points_list, create_point(j, k, 1))
        end
      end
    end
  end
  return points_list
end

function generate_xy_struct_from_blueprint(blueprint_string)
  if blueprint_string == "nil" then
    return nil
  end
  xy_values = split(blueprint_string, ",", true)
  return {x = xy_values[1], y = xy_values[2]}
end

function add_tile_to_list(tile_type, x_origin, y_origin)
  list_info = determine_list_to_add_to_and_search(tile_type)
  blueprint_strings = list_info[1]
  list_to_add_to = list_info[2]
  tile_info = create_tile_blueprint_from_name(tile_type, blueprint_strings)
  if tile_info.spritestart_locked == nil then
    tile_info.spritestart_locked = { x = tile_info.spritestart_general.x, y = tile_info.spritestart_general.y }
  end
  if tile_info.spritestart_selected == nil then
    tile_info.spritestart_selected = { x = tile_info.spritestart_general.x, y = tile_info.spritestart_general.y }
  end
  tile_to_prep = create_tile(
          tile_info.points, tile_info.center.x, tile_info.center.y, tile_info.spritestart_general.x,
          tile_info.spritestart_general.y, tile_info.spritestart_selected.x, tile_info.spritestart_selected.y,
          tile_info.spritestart_locked.x, tile_info.spritestart_locked.y, tile_info.waypoints)
  if list_to_add_to == characters_to_draw then
    cast_tile_to_char(tile_to_prep, tile_type)
  end
  add(list_to_add_to, create_drawable_tile(tile_to_prep, x_origin, y_origin))
end

function determine_list_to_add_to_and_search(tile_type)
  if static_tile_blueprint_strings[tile_type] != nil then
    return {static_tile_blueprint_strings, static_tiles_to_draw}
  elseif character_blueprint_strings[tile_type] != nil then
    return {character_blueprint_strings, characters_to_draw}
  else
    return {rotator_blueprint_strings, rotators_to_draw}
  end
end
-->8
--character_movement
function get_starting_waypoint(char, waypoints)
  for i=1, count(waypoints) do
    if char.center_x == waypoints[i].draw_waypoint.x and char.center_y == waypoints[i].draw_waypoint.y then
      return waypoints[i]
    end
  end
  return nil
end

function get_tile_on(char)
  waypoint_to = char.waypoint_to
  waypoint_from = char.waypoint_from
  -- case 1: the waypoints are on the same tile
  if waypoint_to.tile_on == waypoint_from.tile_on then
    return waypoint_to.tile_on
  end
  -- case 2: vertical travel. x-axes of the two waypoints are the same.
  if waypoint_to.x == waypoint_from.x then
    if abs(waypoint_to.draw_waypoint.y - char.center_y) <= abs(waypoint_from.draw_waypoint.y - char.center_y) then
      return waypoint_to.tile_on
    else
      return waypoint_from.tile_on
    end
    -- case 3: horizontal travel. y-axes of the two waypoints are the same.
  elseif waypoint_to.y == waypoint_from.y then
    if abs(waypoint_to.x - char.center_x) <= abs(waypoint_from.x - char.center_x) then
      return waypoint_to.tile_on
    else
      return waypoint_from.tile_on
    end
  end
  -- this should never happen :koyoriWao:
  return nil
end

function get_next_waypoint(char, waypoints, max_distance)
  curr_x = char.center_x
  curr_y = char.center_y
  eligible_waypoints_horizontal = {}
  eligible_waypoints_vertical = {}
  for i=1,count(waypoints) do
    if waypoints[i].draw_waypoint.x == curr_x then
      if waypoints[i].draw_waypoint.y == curr_y then
        char.waypoint_from = waypoints[i]
        char.tile_on = waypoints[i].tile_on
      elseif not waypoints[i].tile_on.rotating then
        add(eligible_waypoints_vertical, waypoints[i])
      end
    elseif waypoints[i].draw_waypoint.y == curr_y and not waypoints[i].tile_on.rotating then
      add(eligible_waypoints_horizontal, waypoints[i])
    end
  end

  x_forward, y_forward = get_unitvector_ahead(char)
  potential_next_waypoint = search_for_waypoint_in_direction(
          char, eligible_waypoints_horizontal, eligible_waypoints_vertical, x_forward, y_forward, max_distance)
  if potential_next_waypoint != nil then
    char.waypoint_to = potential_next_waypoint
    return
  end

  x_forward, y_forward = get_unitvector_clockwise(char)
  potential_next_waypoint = search_for_waypoint_in_direction(
  char, eligible_waypoints_horizontal, eligible_waypoints_vertical, x_forward, y_forward, max_distance)
  if potential_next_waypoint != nil then
    set_origins(char)
    turn_clockwise(char)
    char.waypoint_to = potential_next_waypoint
    return
  end

  x_forward, y_forward = get_unitvector_counterclockwise(char)
  potential_next_waypoint = search_for_waypoint_in_direction(
          char, eligible_waypoints_horizontal, eligible_waypoints_vertical, x_forward, y_forward, max_distance)
  if potential_next_waypoint != nil then
    set_origins(char)
    turn_counterclockwise(char)
    char.waypoint_to = potential_next_waypoint
    return
  end

  x_forward, y_forward = get_unitvector_behind(char)
  potential_next_waypoint = search_for_waypoint_in_direction(
          char, eligible_waypoints_horizontal, eligible_waypoints_vertical, x_forward, y_forward, max_distance)
  if potential_next_waypoint != nil then
    set_origins(char)
    turn_180_degrees(char)
    char.waypoint_to = potential_next_waypoint
    return
  end
  return
end

function search_for_waypoint_in_direction(char, waypoints_horiz, waypoints_vert, x_dir, y_dir, max_distance)
  prospective_x = char.center_x
  prospective_y = char.center_y
  prospective_waypoints = {}
  if x_dir != 0 then
    prospective_waypoints = waypoints_horiz
  else
    prospective_waypoints = waypoints_vert
  end
  for i=1,max_distance do
    prospective_x = prospective_x + x_dir
    prospective_y = prospective_y + y_dir
    for j=1,count(prospective_waypoints) do
      if prospective_waypoints[j].draw_waypoint.x == prospective_x and
              prospective_waypoints[j].draw_waypoint.y == prospective_y then
        return prospective_waypoints[j]
      end
    end
  end
end



function get_unitvector_counterclockwise(char)
  x_ahead = 0
  if char.movement_dir == "up" then
    x_ahead = -1
  elseif char.movement_dir == "down" then
    x_ahead = 1
  end
  y_ahead = 0
  if char.movement_dir == "right" then
    y_ahead = -1
  elseif char.movement_dir == "left" then
    y_ahead = 1
  end
  return x_ahead, y_ahead
end

function get_unitvector_clockwise(char)
  x_ahead = 0
  if char.movement_dir == "up" then
    x_ahead = 1
  elseif char.movement_dir == "down" then
    x_ahead = -1
  end
  y_ahead = 0
  if char.movement_dir == "right" then
    y_ahead = 1
  elseif char.movement_dir == "left" then
    y_ahead = -1
  end
  return x_ahead, y_ahead
end

function get_unitvector_behind(char)
  x_ahead = 0
  if char.movement_dir == "right" then
    x_ahead = -1
  elseif char.movement_dir == "left" then
    x_ahead = 1
  end
  y_ahead = 0
  if char.movement_dir == "up" then
    y_ahead = 1
  elseif char.movement_dir == "down" then
    y_ahead = -1
  end
  return x_ahead, y_ahead
end

function get_unitvector_ahead(char)
  x_ahead = 0
  if char.movement_dir == "right" then
    x_ahead = 1
  elseif char.movement_dir == "left" then
    x_ahead = -1
  end
  y_ahead = 0
  if char.movement_dir == "up" then
    y_ahead = -1
  elseif char.movement_dir == "down" then
    y_ahead = 1
  end
  return x_ahead, y_ahead
end

function initialize_moving_right(char)
  char.movement_dir = "right"
end

function initialize_moving_left(char)
  char.movement_dir = "left"
  x_origin = char.center_x
  y_origin = char.center_y
  for i=1,count(char.draw_points) do
    char.draw_points[i].x = (x_origin*2) - char.draw_points[i].x
    char.draw_points[i].y = (y_origin*2) - char.draw_points[i].y
  end
end

function initialize_moving_up(char)
  char.movement_dir = "up"
  x_origin = char.center_x
  y_origin = char.center_y
  for i=1,count(char.draw_points) do
    zeroed_x = char.draw_points[i].x - char.center_x
    zeroed_y = char.draw_points[i].y - char.center_y
    char.draw_points[i].x = zeroed_y  + char.center_x
    char.draw_points[i].y = (zeroed_x * -1) + char.center_y
  end
end

function initialize_moving_down(char)
  char.movement_dir = "up"
  x_origin = char.center_x
  y_origin = char.center_y
  for i=1,count(char.draw_points) do
    zeroed_x = char.draw_points[i].x - char.center_x
    zeroed_y = char.draw_points[i].y - char.center_y
    char.draw_points[i].x = (zeroed_y * -1)  + char.center_x
    char.draw_points[i].y = zeroed_x + char.center_y
  end
end

function turn_counterclockwise(char)
  turn_movement_counterclockwise(char)

  x_origin = char.center_x
  y_origin = char.center_y
  for i=1,count(char.draw_points) do
    zeroed_x = char.draw_points[i].x0 - char.center_x
    zeroed_y = char.draw_points[i].y0 - char.center_y
    char.draw_points[i].x = zeroed_y  + char.center_x
    char.draw_points[i].y = (zeroed_x * -1) + char.center_y
  end
end

function turn_movement_counterclockwise(char)
  if char.movement_dir == "right" then
    char.movement_dir = "up"
  elseif char.movement_dir == "up" then
    char.movement_dir = "left"
  elseif char.movement_dir == "left" then
    char.movement_dir = "down"
  else
    char.movement_dir = "right"
  end
end


function turn_clockwise(char)
  turn_movement_clockwise(char)

  x_origin = char.center_x
  y_origin = char.center_y
  for i=1,count(char.draw_points) do
    zeroed_x = char.draw_points[i].x0 - char.center_x
    zeroed_y = char.draw_points[i].y0 - char.center_y
    char.draw_points[i].x = (zeroed_y * -1)  + char.center_x
    char.draw_points[i].y = zeroed_x + char.center_y
  end
end

function turn_movement_clockwise(char)
  if char.movement_dir == "right" then
    char.movement_dir = "down"
  elseif char.movement_dir == "up" then
    char.movement_dir = "right"
  elseif char.movement_dir == "left" then
    char.movement_dir = "up"
  else
    char.movement_dir = "left"
  end
end

function turn_180_degrees(char)
  if char.movement_dir == "right" then
    char.movement_dir = "left"
  elseif char.movement_dir == "left" then
    char.movement_dir = "right"
  elseif char.movement_dir == "up" then
    char.movement_dir = "down"
  else
    char.movement_dir = "up"
  end

  x_origin = char.center_x
  y_origin = char.center_y
  for i=1,count(char.draw_points) do
    char.draw_points[i].x = (x_origin*2) - char.draw_points[i].x0
    char.draw_points[i].y = (y_origin*2) - char.draw_points[i].y0
  end
end

function move_character(char)
  char_speed = char.char_speed * global_game_speed
  if char.movement_dir == "right" then
    return translate_tile(char, char_speed, 0)
  elseif char.movement_dir == "left" then
    return translate_tile(char, char_speed * -1, 0)
  elseif char.movement_dir == "up" then
    return translate_tile(
      char, 0, char_speed * -1
    )
  elseif char.movement_dir == "down" then
    return translate_tile(
      char, 0, char_speed
    )
  else
    return char
  end
end
-->8
--levels
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
-->8
--menu

function generate_main_menu(option_selected)
  cls(7) -- clear screen, set as white
  palt(15, true) -- beige color as transparency is true
  palt(0, false) -- black color as transparency is false

  _draw_ui_elements()
  sspr(0, 37, 41, 10, 44, 30)
  y_locations = {45, 53, 61}
  descriptions = {"new game", "level select", "settings"}
  x_colors = {14, 8, 2}
  for i=1,count(descriptions) do
    print("[", 36, y_locations[i], 0)
    print("]", 42, y_locations[i], 0)
    print(descriptions[i], 49, y_locations[i], 0)
  end
  print("x", 39, y_locations[option_selected], x_colors[option_selected])
end

function init_main_menu()
  level_num = 1
  main_menu_option = 1
  level_state = "menu"
end

function handle_menu_input()
  if btnp(⬆️) then
    main_menu_option = max(1, main_menu_option-1)
  elseif btnp(⬇️) then
    main_menu_option = min(3, main_menu_option+1)
  elseif btnp(❎) or btnp(🅾️) then
    if main_menu_option == 1 then
      _init_level(level_num)
    else
      level_select_option = 1
      level_state = "level_select"
    end
  end
end

function handle_win_menu_input()
  if btnp(⬆️) then
    in_game_menu_option = max(1, in_game_menu_option-1)
  elseif btnp(⬇️) then
    in_game_menu_option = min(3, in_game_menu_option+1)
  elseif btnp(❎) or btnp(🅾️) then
    if in_game_menu_option == 1 then
      level_num = min(count(level_blueprints), level_num + 1)
      _init_level(level_num)
    elseif in_game_menu_option == 2 then
      _init_level(level_num)
    else
      init_main_menu()
    end
  end
end

function generate_win_menu(option_selected)
  rectfill(26, 35, 99, 75, 7)
  rect(26, 35, 99, 75, 0)
  print("complete :0", 42, 39, 11)
  y_locations = {47, 55, 63}
  option_text = {"next level", "replay level", "main menu"}
  x_colors = {11, 12, 8}
  for i=1,3 do
    print("[", 35, y_locations[i], 0)
    print("]", 41, y_locations[i], 0)
    print(option_text[i], 48, y_locations[i], 0)
  end
  print("x", 38, y_locations[option_selected], x_colors[option_selected])
end

function handle_lose_menu_input()
  if btnp(⬆️) then
    in_game_menu_option = 1
  elseif btnp(⬇️) then
    in_game_menu_option = 2
  elseif btnp(❎) or btnp(🅾️) then
    if in_game_menu_option == 1 then
      _init_level(level_num)
    else
      init_main_menu()
    end
  end
end

function generate_lose_menu(option_selected)
  rectfill(26, 35, 99, 65, 7)
  rect(26, 35, 99, 65, 0)
  print("lose :(", 51, 39, 8)
  y_locations = {47, 55}
  option_text = {"replay lvl", "main menu"}
  x_colors = {12, 8}
  for i=1,2 do
    print("[", 35, y_locations[i], 0)
    print("]", 41, y_locations[i], 0)
    print(option_text[i], 48, y_locations[i], 0)
  end
  print("x", 38, y_locations[option_selected], x_colors[option_selected])
end
-->8
--system
local system

function system_init()
    system = {
        settings = {
            colorblind = "off" --off, on
        },
        toggle_colorblind_mode = function(self)
            if (self.settings.colorblind == "off") then
                self.settings.colorblind = "on"
            else
                self.settings.colorblind = "off"
            end
        end
    }
    function menuitem_colorblind(b)
        if (b&112 > 0) then
            system:toggle_colorblind_mode()
            menuitem(_, "colorblind: "..system.settings.colorblind)
        end
        return true -- stay open
    end
    function clear_save()
        dset(0, 0)
    end
    menuitem(1, "colorblind: "..system.settings.colorblind, menuitem_colorblind)
    menuitem(2, "clear save", clear_save)
end

function adjust_for_colorblindness()
    if (system.settings.colorblind == "off") then
        pal()
    elseif (system.settings.colorblind == "on") then
        pal({[3]=13, [8]=9, [9]=6, [10]=15, [11]=12, [13]=5, [14]=15}, 0)
    end
    map()
end
-->8
--level_select
function generate_level_select()
    rectfill(26, 65, 99, 85, 0)
    rect(26, 65, 99, 85, 7)
end

function handle_level_select_input()

end
-->8
--save_data
function get_furthest_level()
    if dget(0) == nil then return 1 end
    return dget(0)
end

function update_furthest_level(level_number)
    if level_number > get_furthest_level() then
        dset(0, level_number)
    end
end

-- settings: (1) colorblind mode (2) game speed (3) clear save [clear furthest level]
__gfx__
666666666f666666666f666666666f666666666f677777776f677777776f666666666f666666666f677777776f666666666f677777776f000000000000000000
677777776f677777777f677777776f777777776f677777776f677777777f677777777f777777776f777777776f777777777f677777776f0bbbbbbb0088888880
677777776f677777777f677777776f777777776f677777776f677777777f677777777f777777776f777777776f777777777f677777776f0bbbbbbb0088888880
677777776f677777777f677777776f777777776f677777776f677777777f677777777f777777776f777777776f777777777f677777776f0bbbbbbb0088888880
677777776f677777777f677777776f777777776f677777776f677777777f677777777f777777776f777777776f777777777f677777776f0bbbbbbb0088888880
677777776f677777777f677777776f777777776f677777776f677777777f677777777f777777776f777777776f777777777f677777776f0bbbbbbb0088888880
677777776f677777777f677777776f777777776f677777776f677777777f677777777f777777776f777777776f777777777f677777776f0bbbbbbb0088888880
677777776f677777777f677777776f777777776f677777776f677777777f677777777f777777776f777777776f777777777f677777776f0bbbbbbb0088888880
666666666f666666666f677777776f666666666f666666666f666666666f677777776f677777776f666666666f666666666f677777776f000000000000000000
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
555555555555555555555f555555555f555555555ffffffff5555555555555555f5555555555555555ffffffff555555555ffffffff555555555ffffffffffff
577777777777777777775f577777775f577777775ffffffff5777777777777775f5777777777777775ffffffff577777775ffffffff577777775ffffffffffff
577777777777777777775f577777775f577777775ffffffff5777777777777775f5777777777777775ffffffff577777775ffffffff577777775ffffffffffff
577777777777777777775f577777775f577777775ffffffff5777777777777775f5777777777777775ffffffff577777775ffffffff577777775ffffffffffff
577777777777777777775f577777775f577777775ffffffff5777777777777775f5777777777777775ffffffff577777775ffffffff577777775ffffffffffff
577777777777777777775f577777775f577777775ffffffff5777777777777775f5777777777777775ffffffff577777775ffffffff577777775ffffffffffff
577777777777777777775f577777775f577777775ffffffff5777777777777775f5777777777777775ffffffff577777775ffffffff577777775ffffffffffff
577777777777777777775f577777775f5777777755555555f5777777777777775f5777777777777775f5555555577777775f55555555777777755555555fffff
555555555555555555555f577777775f5777777777777775f5777777755555555f5555555577777775f5777777777777775f57777777777777777777775fffff
ffffffffffffffffffffff577777775f5777777777777775f577777775fffffffffffffff577777775f5777777777777775f57777777777777777777775fffff
000000000000000000000f577777775f5777777777777775f577777775fffffffffffffff577777775f5777777777777775f57777777777777777777775fffff
066666666666666666660f577777775f5777777777777775f577777775fffffffffffffff577777775f5777777777777775f57777777777777777777775fffff
067777777777777777760f577777775f5777777777777775f577777775fffffffffffffff577777775f5777777777777775f57777777777777777777775fffff
067777777777777777760f577777775f5777777777777775f577777775fffffffffffffff577777775f5777777777777775f57777777777777777777775fffff
067777777777777777760f577777775f5777777777777775f577777775fffffffffffffff577777775f5777777777777775f57777777777777777777775fffff
067777777777777777760f577777775f5555555555555555f555555555fffffffffffffff555555555f5555555555555555f55555555777777755555555fffff
067777777777777777760f577777775ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff577777775ffffffffffff
066666666666666666660f577777775f000000000ffffffff0000000000000000f0000000000000000ffffffff000000000ffffffff577777775ffffffffffff
000000000000000000000f577777775f066666660ffffffff0666666666666660f0666666666666660ffffffff066666660ffffffff577777775ffffffffffff
ffffffffffffffffffffff577777775f067777760ffffffff0677777777777760f0677777777777760ffffffff067777760ffffffff577777775ffffffffffff
555555555555555555555f555555555f067777760ffffffff0677777777777760f0677777777777760ffffffff067777760ffffffff577777775ffffffffffff
567767767767767767765fffffffffff067777760ffffffff0677777777777760f0677777777777760ffffffff067777760ffffffff577777775ffffffffffff
576776776776776776775f000000000f067777760ffffffff0677777777777760f0677777777777760ffffffff067777760ffffffff555555555ffffffffffff
577677677677677677675f066666660f067777760ffffffff0677777777777760f0677777777777760ffffffff067777760fffffffffffffffffffffffffffff
567767767767767767765f067777760f0677777600000000f0677777666666660f0666666667777760f0000000067777760ffffffff000000000ffffffffffff
576776776776776776775f067777760f0677777666666660f0677777600000000f0000000067777760f0666666667777760ffffffff066666660ffffffffffff
577677677677677677675f067777760f0677777777777760f067777760fffffffffffffff067777760f0677777777777760ffffffff067777760ffffffffffff
567767767767767767765f067777760f0677777777777760f067777760fffffffffffffff067777760f0677777777777760ffffffff067777760ffffffffffff
555555555555555555555f067777760f0677777777777760f067777760fffffffffffffff067777760f0677777777777760ffffffff067777760ffffffffffff
ffffffffffffffffffffff067777760f0677777777777760f067777760fffffffffffffff067777760f0677777777777760ffffffff067777760ffffffffffff
001122330fff555555555f067777760f0677777777777760f067777760fffffffffffffff067777760f0677777777777760ffffffff067777760ffffffffffff
001122330fff567767765f067777760f0666666666666660f066666660fffffffffffffff066666660f0666666666666660f00000000677777600000000fffff
445566770fff577677675f067777760f0000000000000000f000000000fffffffffffffff000000000f0000000000000000f06666666677777666666660fffff
445566770fff576776775f067777760fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff06777777777777777777760fffff
8899aabb0fff567767765f067777760f555555555ffffffff5555555555555555f5555555555555555ffffffff555555555f06777777777777777777760fffff
8899aabb0fff577677675f067777760f577677675ffffffff5767767767767765f5776776776776775ffffffff567767765f06777777777777777777760fffff
ccddeeff0fff576776775f067777760f576776775ffffffff5677677677677675f5767767767767765ffffffff577677675f06777777777777777777760fffff
ccddeeff0fff567767765f067777760f567767765ffffffff5776776776776775f5677677677677675ffffffff576776775f06777777777777777777760fffff
000000000fff577677675f067777760f577677675ffffffff5767767767767765f5776776776776775ffffffff567767765f06666666677777666666660fffff
ffffffffffff576776775f067777760f576776775ffffffff5677677677677675f5767767767767765ffffffff577677675f00000000677777600000000fffff
ffffffffffff567767765f067777760f567767765ffffffff5776776776776775f5677677677677675ffffffff576776775ffffffff067777760ffffffffffff
ffffffffffff577677675f066666660f5776776755555555f5767767767767765f5776776776776775f5555555567767765ffffffff067777760ffffffffffff
ffffffffffff576776775f000000000f5767767767767765f5677677655555555f5555555567767765f5677677677677675ffffffff067777760ffffffffffff
ffffffffffff567767765fffffffffff5677677677677675f577677675fffffffffffffff577677675f5776776776776775ffffffff067777760ffffffffffff
ffffffffffff577677675fffffffffff5776776776776775f576776775fffffffffffffff576776775f5767767767767765ffffffff067777760ffffffffffff
ffffffffffff576776775fffffffffff5767767767767765f567767765fffffffffffffff567767765f5677677677677675ffffffff066666660ffffffffffff
ffffffffffff567767765fffffffffff5677677677677675f577677675fffffffffffffff577677675f5776776776776775ffffffff000000000ffffffffffff
ffffffffffff577677675fffffffffff5776776776776775f576776775fffffffffffffff576776775f5767767767767765fffffffffffffffffffffffffffff
ffffffffffff576776775fffffffffff5767767767767765f567767765fffffffffffffff567767765f5677677677677675ffffffff555555555ffffffffffff
ffffffffffff567767765fffffffffff5555555555555555f555555555fffffffffffffff555555555f5555555555555555ffffffff567767765ffffffffffff
ffffffffffff555555555ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff577677675ffffffffffff
fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff576776775ffffffffffff
fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff567767765ffffffffffff
fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff577677675ffffffffffff
fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff576776775ffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff55555555677677655555555fffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff56776776776776776776775fffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff57767767767767767767765fffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff57677677677677677677675fffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff56776776776776776776775fffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff57767767767767767767765fffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff57677677677677677677675fffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff56776776776776776776775fffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff55555555767767755555555fffff
fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff567767765ffffffffffff
fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff577677675ffffffffffff
fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff576776775ffffffffffff
fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff567767765ffffffffffff
fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff577677675ffffffffffff
fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff576776775ffffffffffff
fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff555555555ffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0fff0f00fffffffffffffffffffffffffffffffffff0ffffff0fffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0fff0ff0fffffffffffffffffffffffffffffffffff0ffffff0fffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0ffffff0fffffffffffffffffffffffffffffffffff0ffffff0fffff
fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff000f00ff0ff00fff000f0fff0f00ff000ff0f00f00f000f00f000f00f
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0fff0ff0f0ff0f0ffff0f0f0fff0f0ff0f00ff0ff0f0ffff0f0f0ff0
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0fff0ff0f0000ff00ff0f0f0f000f0ff0f0fff0ff0f0ff000f0f0000
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0fff0ff0f0fffffff0ff0f0f0ff0f0ff0f0fff0ff0f0f0ff0f0f0fff
ffffffffffffffffffffffffffffff555555555555555555555555555555555555555ffff0ff0ff0ff00ff000fff0f0ff000f000ff0ffff00fff0f000ff0f00f
fffffffffffffffffffffffffffff55777777777777777777777777777777777777755fffffffffffffffffffffffffffffff0ffffffffffffffffffffffffff
fffffffffffffffffffffffffffff57777777777770777777770777777777777777775ffffffffff66666666666666666ffff0ffffff66666666666666666fff
fffffffffffffffffffffffffffff57777777777770777777770777777777777777775fffffffff6677777777777777766fffffffff6677777777777777766ff
fffffffffffffffffffffffffffff57070077007700077007700077007770077700075fffffffff67788888777b777b776fffffffff6777777777777777776ff
fffffffffffffffffffffffffffff57007770770770777770770770770707707077775fffffffff67777778777b777b776fffffffff6777177777777797776ff
fffffffffffffffffffffffffffff57077770770770777000770770770700007700775fffffffff677777877777b7b7776fffffffff6771777777777779776ff
fffffffffffffffffffffffffffff57077770770770770770770770770707777777075fffffffff6777787770777b77776fffffffff6711111170799999976ff
fff0ffff8fffff2ffefffffffffff57077770770770770770770770770707777777075fffffffff677787777777b7b7776fffffffff6771777777777779776ff
ffff0ffff8fffff2fefefffffffff57077777007777077000777077007770007000775fffffffff67787777777b777b776fffffffff6777177777777797776ff
f00000f8888f2222feeeeffffffff57777777777777777777777777777777777777775fffffffff67788888777b777b776fffffffff6777777777777777776ff
ffff0ffff8fffff2fefefffffffff55777777777777777777777777777777777777755fffffffff6677777777777777766fffffffff6677777777777777766ff
fff0ffff8fffff2ffeffffffffffff555555555555555555555555555555555555555fffffffffff66666666666666666fffffffffff66666666666666666fff

