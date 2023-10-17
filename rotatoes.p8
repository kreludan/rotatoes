pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
--global

function _init()
  system_init()
  cartdata("rotato_save")
  max_distance = 7 -- distance to check for a waypoint in a direction
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
--tiles
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

function create_tile(points, center_x, center_y, spritestart_x, spritestart_y, selectedspritestart_x, selectedspritestart_y, waypoints)
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

function cast_tile_to_char(tile, char_type, char_speed)
  tile.is_character = true
  tile.char_type = char_type
  tile.char_speed = char_speed
  tile.movement_dir = "right"
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
--rotators
function add_rotator_to_list(rotator_type, rotators_list, x_origin, y_origin)
  tile_to_prep = {}
  if rotator_type == "l1" then
    tile_to_prep = create_l1_tile()
  elseif rotator_type == "l2" then
    tile_to_prep = create_l2_tile()
  elseif rotator_type == "l3" then
    tile_to_prep = create_l3_tile()
  elseif rotator_type == "l4" then
    tile_to_prep = create_l4_tile()
  elseif rotator_type == "horiz" then
    tile_to_prep = create_horiz_tile()
  elseif rotator_type == "vert" then
    tile_to_prep = create_vert_tile()
  elseif rotator_type == "plus" then
    tile_to_prep = create_plus_tile()
  else
    return
  end
  add(
    rotators_list,
    create_drawable_tile(
      tile_to_prep, x_origin,
      y_origin
    )
  )
end

function create_cross_tile()
  cross_points = create_cross_points()
  cross_tile = create_tile(
    cross_points, 2, 2, 0, 0, 0, 0
  )
  return cross_tile
end

function create_l1_tile()
  l1_points = create_l1_points()
  l1_tile = create_tile(
    l1_points, 3, 8, 8, 0, 8, 17,
    create_l1_waypoints()
  )
  return l1_tile
end

function create_l2_tile()
  l2_points = create_l2_points()
  l2_tile = create_tile(
    l2_points, 8, 8, 20, 0, 20, 17,
    create_l2_waypoints()
  )
  return l2_tile
end

function create_l3_tile()
  l3_points = create_l3_points()
  l3_tile = create_tile(
    l3_points, 8, 3, 32, 0, 32, 17,
    create_l3_waypoints()
  )
  return l3_tile
end

function create_l4_tile()
  l4_points = create_l4_points()
  l4_tile = create_tile(
    l4_points, 3, 3, 44, 0, 44, 17,
    create_l4_waypoints()
  )
  return l4_tile
end

function create_vert_tile()
  vert_points = create_vert_points()
  vert_tile = create_tile(
    vert_points, 3, 8, 56, 0, 56, 17,
    create_vert_waypoints()
  )
  return vert_tile
end

function create_horiz_tile()
  horiz_points = create_horiz_points()
  horiz_tile = create_tile(
    horiz_points, 8, 3, 63, 0, 63, 17,
    create_horiz_waypoints()
  )
  return horiz_tile
end

function create_plus_tile()
  plus_points = create_plus_points()
  plus_tile = create_tile(
    plus_points, 8, 8, 80, 0, 80, 17,
    create_plus_waypoints()
  )
  return plus_tile
end

function create_cross_points()
  cross_points = {}
  for i = 0, 4 do
    if i != 2 then
      add(
        cross_points,
        create_point(2, i, 1)
      )
    end
  end
  for i = 0, 4 do
    add(
      cross_points,
      create_point(i, 2, 1)
    )
  end
  return cross_points
end

function create_plus_waypoints()
  return {
    create_point(3, 8, 1),
    create_point(8, 3, 1),
    create_point(8, 8, 1),
    create_point(8, 13, 1),
    create_point(13, 8, 1)
  }
end

function create_plus_points()
  plus_points = {}
  for y = 5, 11 do
    for x = 0, 16 do
      add(
        plus_points,
        create_point(x, y, 1)
      )
    end
  end
  for x = 5, 11 do
    for y = 0, 4 do
      add(
        plus_points,
        create_point(x, y, 1)
      )
    end
    for y = 12, 16 do
      add(
        plus_points,
        create_point(x, y, 1)
      )
    end
  end
  return plus_points
end

function create_horiz_points()
  horiz_points = {}
  for y = 0, 6 do
    for x = 0, 16 do
      add(
        horiz_points,
        create_point(x, y, 1)
      )
    end
  end
  return horiz_points
end

function create_horiz_waypoints()
  return {
    create_point(3, 3, 1),
    create_point(8, 3, 1),
    create_point(13, 3, 1)
  }
end

function create_vert_points()
  vert_points = {}
  for y = 0, 16 do
    for x = 0, 6 do
      add(
        vert_points,
        create_point(x, y, 1)
      )
    end
  end
  return vert_points
end

function create_vert_waypoints()
  return {
    create_point(3, 3, 1),
    create_point(3, 8, 1),
    create_point(3, 13, 1)
  }
end

function create_l4_waypoints()
  return {
    create_point(3, 8, 1),
    create_point(3, 3, 1),
    create_point(8, 3, 1)
  }
end

function create_l4_points()
  l4_points = {}
  for y = 0, 6 do
    for x = 0, 11 do
      add(
        l4_points,
        create_point(x, y, 1)
      )
    end
  end
  for y = 7, 11 do
    for x = 0, 6 do
      add(
        l4_points,
        create_point(x, y, 1)
      )
    end
  end
  return l4_points
end

function create_l3_waypoints()
  return {
    create_point(3, 3, 1),
    create_point(8, 3, 1),
    create_point(8, 8, 1)
  }
end

function create_l3_points()
  l3_points = {}
  for y = 0, 6 do
    for x = 0, 11 do
      add(
        l3_points,
        create_point(x, y, 1)
      )
    end
  end
  for y = 7, 11 do
    for x = 5, 11 do
      add(
        l3_points,
        create_point(x, y, 1)
      )
    end
  end
  return l3_points
end

function create_l2_waypoints()
  return {
    create_point(3, 8, 1),
    create_point(8, 8, 1),
    create_point(8, 3, 1)
  }
end

function create_l2_points()
  l2_points = {}
  for y = 0, 4 do
    for x = 5, 11 do
      add(
        l2_points,
        create_point(x, y, 1)
      )
    end
  end
  for y = 5, 11 do
    for x = 0, 11 do
      add(
        l2_points,
        create_point(x, y, 1)
      )
    end
  end
  return l2_points
end

function create_l1_waypoints()
  return {
    create_point(3, 3, 1),
    create_point(3, 8, 1),
    create_point(8, 8, 1)
  }
end

function create_l1_points()
  l1_points = {}
  for y = 0, 4 do
    for x = 0, 6 do
      add(
        l1_points,
        create_point(x, y, 1)
      )
    end
  end
  for y = 5, 11 do
    for x = 0, 11 do
      add(
        l1_points,
        create_point(x, y, 1)
      )
    end
  end
  return l1_points
end
-->8
--static_tiles
function add_static_tile_to_list(statictile_type, statictile_list, x_origin, y_origin)
  tile_index = 1
  tile_types = {
    { "corrend_left", 97, 0 },
    { "corrend_right", 121, 0 },
    { "corrend_up", 97, 16 },
    { "corrend_down", 105, 16 },
    { "corr_horiz", 105, 0 },
    { "corr_vert", 113, 0 },
    { "corr_turn_upleft", 97, 8 },
    { "corr_turn_upright", 121, 8 },
    { "corr_turn_downleft", 105, 8 },
    { "corr_turn_downright", 113, 8 },
    { "singleton_horiz", 97, 24 },
    { "singleton_vert", 105, 24 },
    { "invisible_tile", 113, 24 }
  }
  tile_to_prep = {}
  while tileindex != count(tile_types) do
    if statictile_type
        == tile_types[tile_index][1] then
      tile_to_prep = create_square_tile(
        tile_types[tile_index][2],
        tile_types[tile_index][3]
      )
      add(
        statictile_list,
        create_drawable_tile(
          tile_to_prep,
          x_origin, y_origin
        )
      )
      return
    end
    tile_index += 1
  end
end

function create_square_tile(spritestart_x, spritestart_y)
  square_points = create_square_points()
  square_tile = create_tile(
    square_points, 3, 3,
    spritestart_x, spritestart_y,
    spritestart_x, spritestart_y,
    create_square_waypoints()
  )
  return square_tile
end

function create_square_waypoints()
  return { create_point(3, 3, 1) }
end

function create_square_points()
  square_points = {}
  for x = 0, 6 do
    for y = 0, 6 do
      add(
        square_points,
        create_point(x, y, 1)
      )
    end
  end
  return square_points
end
-->8
--characters
function add_char_to_list(char_type, char_list, x_origin, y_origin)
  if char_type == "player" then
    tile_to_prep = create_player()
  elseif char_type == "goal" then
    tile_to_prep = create_goal()
  elseif char_type == "deathtile" then
    tile_to_prep = create_deathtile()
  elseif char_type == "enemy_basic" then
    tile_to_prep = create_enemy_basic()
  end
  add(char_list, create_drawable_tile(tile_to_prep, x_origin, y_origin))
end

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

function create_player()
  player_points = create_player_points()
  player_tile = create_tile(player_points, 2, 2, 0, 8, 0, 8, nil)
  return cast_tile_to_char(player_tile, "player", 1)
end

function create_enemy_basic()
  basic_enemy_points = create_player_points()
  basic_enemy_tile = create_tile(basic_enemy_points, 2, 2, 0, 3, 0, 3, nil)
  return cast_tile_to_char(basic_enemy_tile, "enemy_basic", 1)
end

function create_goal()
  goal_points = create_square_points()
  goal_tile = create_tile(goal_points, 3, 3, 113, 16, 113, 16, nil)
  return cast_tile_to_char(goal_tile, "goal", 0)
end

function create_deathtile()
  deathtile_points = create_square_points()
  death_tile = create_tile(deathtile_points, 3, 3, 121, 16, 121, 16, nil)
  return cast_tile_to_char(death_tile, "deathtile", 0)
end

function create_player_points()
  player_points={}
  add(player_points, create_point(0,0,1))
  add(player_points, create_point(1,1,1))
  add(player_points, create_point(0,2,1))
  add(player_points, create_point(1,2,1))
  add(player_points, create_point(2,2,1))
  add(player_points, create_point(1,3,1))
  add(player_points, create_point(0,4,1))
  return player_points
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
      _init_level(level_num)
    elseif in_game_menu_option == 2 then
      level_num -= 1
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
--levels
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
    "3-goal,104,63|enemy_basic,90,63|player,22,63-horiz,48,63|horiz,78,63-corrend_left,22,63|corr_horiz,29,63|corrend_right,36,63|corrend_left,60,63|corrend_left,48,75|corr_horiz,55,75|corr_horiz,62,75|corr_horiz,69,75|corr_horiz,76,75|corrend_right,78,75|corrend_right,66,63|corrend_left,90,63|corrend_right,97,63|corrend_right,104,63",
    "4-goal,83,28|enemy_basic,40,47|player,40,85-horiz,45,85|plus,59,47|horiz,83,47-corrend_down,45,73|corr_turn_upleft,45,66|corr_horiz,52,66|corr_turn_downright,59,66|corrend_up,59,59|corrend_right,47,47|corrend_left,40,47|corrend_down,59,35|corrend_up,59,28|singleton_horiz,71,47|singleton_vert,83,35|invisible_tile,83,28",
    "5-goal,104,63|player,22,63-vert,48,63|vert,78,63-corrend_left,22,63|corr_horiz,29,63|corrend_right,36,63|corrend_left,60,63|corrend_right,66,63|corrend_left,90,63|corrend_right,97,63|corrend_right,104,63",
    "6-goal,104,63|player,22,63-vert,48,63|vert,78,63-corrend_left,22,63|corr_horiz,29,63|corrend_right,36,63|corrend_left,60,63|corrend_right,66,63|corrend_left,90,63|corrend_right,97,63|corrend_right,104,63",
    "7-goal,104,63|player,22,63-vert,48,63|vert,78,63-corrend_left,22,63|corr_horiz,29,63|corrend_right,36,63|corrend_left,60,63|corrend_right,66,63|corrend_left,90,63|corrend_right,97,63|corrend_right,104,63",
    "8-goal,104,63|player,22,63-vert,48,63|vert,78,63-corrend_left,22,63|corr_horiz,29,63|corrend_right,36,63|corrend_left,60,63|corrend_right,66,63|corrend_left,90,63|corrend_right,97,63|corrend_right,104,63",
    "9-goal,104,63|player,22,63-vert,48,63|vert,78,63-corrend_left,22,63|corr_horiz,29,63|corrend_right,36,63|corrend_left,60,63|corrend_right,66,63|corrend_left,90,63|corrend_right,97,63|corrend_right,104,63",
    "10-goal,104,63|player,22,63-vert,48,63|vert,78,63-corrend_left,22,63|corr_horiz,29,63|corrend_right,36,63|corrend_left,60,63|corrend_right,66,63|corrend_left,90,63|corrend_right,97,63|corrend_right,104,63",
    "11-goal,104,63|player,22,63-vert,48,63|vert,78,63-corrend_left,22,63|corr_horiz,29,63|corrend_right,36,63|corrend_left,60,63|corrend_right,66,63|corrend_left,90,63|corrend_right,97,63|corrend_right,104,63",
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
        print("rotate", 38, 45, 0)
        sspr(0, 30, 5, 7, 72, 36)
        sspr(6, 30, 5, 7, 80, 36)
        print("swap", 71, 45, 0)
    end
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
-->8
--level_select
function generate_level_select()
    rectfill(26, 65, 99, 85, 0)
    rect(26, 65, 99, 85, 7)
end

function handle_level_select_input()

end
__gfx__
ffffffff5555555ffffffffff5555555555555555555555555555555555555555555555555555555fffff5555555fffff6666666f6666666f6777776f6666666
ffffffff5777775ffffffffff5777775577777777775577777777775577777557777777777777775fffff5777775fffff6777777f7777777f6777776f7777776
ffffffff5777775ffffffffff5777775577777777775577777777775577777557777777777777775fffff5777775fffff6777777f7777777f6777776f7777776
8fffffff5777775ffffffffff5777775577777777775577777777775577777557777777777777775fffff5777775fffff6777777f7777777f6777776f7777776
f8ffffff5777775ffffffffff5777775577777777775577777777775577777557777777777777775fffff5777775fffff6777777f7777777f6777776f7777776
888fffff577777555555555555777775577777777775577777777775577777557777777777777775555555777775555556777777f7777777f6777776f7777776
f8ffffff577777777775577777777775555555777775577777555555577777555555555555555555577777777777777756666666f6666666f6777776f6666666
8fffffff577777777775577777777775fffff57777755777775fffff5777775fffffffffffffffff57777777777777775fffffffffffffffffffffffffffffff
dfffffff577777777775577777777775fffff57777755777775fffff5777775fffffffffffffffff577777777777777756666666f6777776f6777776f6666666
fdffffff577777777775577777777775fffff57777755777775fffff5777775fffffffffffffffff577777777777777756777777f6777777f7777776f7777776
dddfffff577777777775577777777775fffff57777755777775fffff5777775fffffffffffffffff577777777777777756777777f6777777f7777776f7777776
fdffffff555555555555555555555555fffff55555555555555fffff5777775fffffffffffffffff555555777775555556777777f6777777f7777776f7777776
dfffffffffffffffffffffffffffffffffffffffffffffffffffffff5777775ffffffffffffffffffffff5777775fffff6777777f6777777f7777776f7777776
ffffffffffffffffffffffffffffffffffffffffffffffffffffffff5777775ffffffffffffffffffffff5777775fffff6777777f6777777f7777776f7777776
ffffffffffffffffffffffffffffffffffffffffffffffffffffffff5777775ffffffffffffffffffffff5777775fffff6777776f6666666f6666666f6777776
ffffffffffffffffffffffffffffffffffffffffffffffffffffffff5777775ffffffffffffffffffffff5777775ffffffffffffffffffffffffffffffffffff
ff0fffffffffffffffffffffffffffffffffffffffffffffffffffff5555555ffffffffffffffffffffff5555555fffff6666666f6777776f0000000f0000000
f0ffffff0000000ffffffffff0000000000000000000000000000000000000000000000000000000fffff0000000fffff6777776f6777776f0bbbbb0f0888880
000000000666660ffffffffff0666660066666666660066666666660066666006666666666666660fffff0666660fffff6777776f6777776f0bbbbb0f0888880
f0ffffff0677760ffffffffff0677760067777777760067777777760067776006777777777777760fffff0677760fffff6777776f6777776f0bbbbb0f0888880
ff0fffff0677760ffffffffff0677760067777777760067777777760067776006777777777777760fffff0677760fffff6777776f6777776f0bbbbb0f0888880
ffffffff0677760ffffffffff0677760067777777760067777777760067776006777777777777760fffff0677760fffff6777776f6777776f0bbbbb0f0888880
ffffffff067776000000000000677760066666677760067776666660067776006666666666666660000000677760000006777776f6666666f0000000f0000000
ffffffff06777666666006666667776000000067776006777600000006777600000000000000000006666667776666660fffffffffffffffffffffffffffffff
fffff0ff067777777760067777777760fffff06777600677760fffff0677760fffffffffffffffff067777777777777606666666f6666666f7777777ffffffff
ffffff0f067777777760067777777760fffff06777600677760fffff0677760fffffffffffffffff067777777777777606777776f6777776f7777777ffffffff
00000000067777777760067777777760fffff06777600677760fffff0677760fffffffffffffffff067777777777777606777776f6777776f7777777ffffffff
ffffff0f066666666660066666666660fffff06666600666660fffff0677760fffffffffffffffff066666677766666606777776f6777776f7777777ffffffff
fffff0ff000000000000000000000000fffff00000000000000fffff0677760fffffffffffffffff000000677760000006777776f6777776f7777777ffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffff0677760ffffffffffffffffffffff0677760fffff6777776f6777776f7777777ffffffff
00000f0fff0fffffffffffffffffffffffffffffffffffffffffffff0677760ffffffffffffffffffffff0677760fffff6666666f6666666f7777777ffffffff
ffff0f0fff0fffffffffffffffffffffffffffffffffffffffffffff0677760ffffffffffffffffffffff0677760ffffffffffffffffffffffffffffffffffff
fff0fff0f0ffffffffffffffffffffffffffffffffffffffffffffff0666660ffffffffffffffffffffff0666660ffffffffffffffffffffffffffffffffffff
ff0fffff0fffffffffffffffffffffffffffffffffffffffffffffff0000000ffffffffffffffffffffff0000000ffffffffffffffffffffffffffffffffffff
f0fffff0f0ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
0fffff0fff0fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
00000f0fff0fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
0000010000000000000000000000000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
0fff00fff0ff0fff0fff0ff0fff0fff00fff0fff0fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
0fff00fff0ff0fff0fff0ff0fff0fff00fff0fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
0fff00fff0ff0fff0fff0ff0fff0fff00ffff0ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
000000fff0ff0fff00000ff0fff0fff0000fff0fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
00fff0fff0ff0fff0fff0ff0fff0fff00ffffff0ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
0f0ff0fff0ff0fff0fff0ff0fff0fff00fffffff0fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
0ff0f0fff0ff0fff0fff0ff0fff0fff00fffffff0fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
0fff00fff0ff0fff0fff0ff0fff0fff00fff0fff0fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
0fff000000ff0fff0fff0ff0fff0000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
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
