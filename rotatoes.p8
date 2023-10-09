pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
--global

function _init()
  system_init()
  max_distance = 7 -- distance to check for a waypoint in a direction
  level_state = "menu" -- "playing", "win", "lose", "menu"
  in_game_menu_option = -1
  level_num = 1 -- current level
end

function _init_level(level_num)
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
  _init_rotators()
  _init_static_tiles()
  _init_characters()
  _init_waypoints()
  _init_character_details()
end

function _init_characters()
  character_blueprint = level_blueprints[level_num]["character_blueprint"]
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

function _init_rotators()
  rotator_blueprint = level_blueprints[level_num]["rotator_blueprint"]
  for i = 1, count(rotator_blueprint) do
    add_rotator_to_list(
      rotator_blueprint[i][1],
      rotators_to_draw,
      rotator_blueprint[i][2],
      rotator_blueprint[i][3]
    )
  end
end

function _init_static_tiles()
  static_tile_blueprint = level_blueprints[level_num]["static_tile_blueprint"]

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
    generate_main_menu()
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
    { "singleton_vert", 105, 24 }
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
  char_speed = char.char_speed
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
  player_tile = create_tile(player_points, 0, 1, 0, 9, 0, 9, nil)
  return cast_tile_to_char(player_tile, "player", 1)
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
  player_points = {}
  for y = 0, 2 do
    if y == 1 then
      for x = 0, 2 do
        add(
          player_points,
          create_point(x, y, 1)
        )
      end
    else
      add(
        player_points,
        create_point(0, y, 1)
      )
    end
  end
  return player_points
end
-->8
--menu
function generate_main_menu()
  cls()
  _draw_ui_elements()
  level_state = "menu"
  level_num = 1
  sspr(0, 37, 41, 10, 44, 30)
  print("[z]:play", 33, 45, 7)
end

function handle_menu_input()
  if btnp(🅾️) then
    _init_level(level_num)
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
      generate_main_menu()
    end
  end
end

function generate_win_menu(option_selected)
  rectfill(26, 35, 99, 75, 0)
  rect(26, 35, 99, 75, 7)
  print("complete :0", 42, 39, 11)
  y_locations = {47, 55, 63}
  option_text = {"next level", "replay lvl", "main menu"}
  for i=1,3 do
    print("[", 35, y_locations[i], 7)
    print("]", 41, y_locations[i], 7)
    print(option_text[i], 48, y_locations[i], 7)
  end
  print("x", 38, y_locations[option_selected], 12)
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
      generate_main_menu()
    end
  end
end

function generate_lose_menu(option_selected)
  rectfill(26, 35, 99, 65, 0)
  rect(26, 35, 99, 65, 7)
  print("lose :(", 51, 39, 8)
  y_locations = {47, 55}
  option_text = {"replay lvl", "main menu"}
  for i=1,2 do
    print("[", 35, y_locations[i], 7)
    print("]", 41, y_locations[i], 7)
    print(option_text[i], 48, y_locations[i], 7)
  end
  print("x", 38, y_locations[option_selected], 12)
end
-->8
--levels
level_blueprints = {
    {level_num = 1,
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
    {level_num = 2,
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
     }},
    {level_num = 4,
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
    {level_num = 1,
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
    {level_num = 5,
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
    {level_num = 6,
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
    {level_num = 7,
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
    {level_num = 8,
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
    {level_num = 9,
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
    {level_num = 10,
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
-->8
--colorblind_mode
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
    menuitem(1, "colorblind: "..system.settings.colorblind, menuitem_colorblind)
end

function adjust_for_colorblindness()
    if (system.settings.colorblind == "off") then
        pal()
    elseif (system.settings.colorblind == "on") then
        pal({[3]=13, [8]=9, [9]=6, [10]=15, [11]=12, [13]=5, [14]=15}, 0)
    end
    map()
end
__gfx__
00600000111d1110000000000111d11111111111d111111d11111111111d11111111111d1111111100000111d111000005555555055555550566766505555555
006000001dd6dd100000000001dd6dd11ddddddd6dd11dd6ddddddd11dd6dd11ddddddd6ddddddd1000001dd6dd1000005666666066666660566766506666665
666660001dd6dd100000000001dd6dd11ddddddd6dd11dd6ddddddd11dd6dd11ddddddd6ddddddd1000001dd6dd1000005666666066666660566766506666665
006000001dd6dd100000000001dd6dd1d6666666666dd6666666666d1dd6dd1d666666666666666d000001dd6dd100000d77777707777777056676650777777d
006000001dd6dd100000000001dd6dd11ddddddd6dd11dd6ddddddd11dd6dd11ddddddd6ddddddd1000001dd6dd1000005666666066666660566766506666665
000000001dd6dd111111111111dd6dd11ddddddd6dd11dd6ddddddd11dd6dd11ddddddd6ddddddd1111111dd6dd1111115666666066666660566766506666665
000000001dd6ddddddd11ddddddd6dd1111111dd6dd11dd6dd1111111dd6dd111111111d111111111ddddddd6ddddddd15555555055555550566766505555555
000000001dd6ddddddd11ddddddd6dd1000001dd6dd11dd6dd1000001dd6dd1000000000000000001ddddddd6ddddddd10000000000000000000000000000000
00000000d6666666666dd6666666666d000001dd6dd11dd6dd100000d66666d00000000000000000d666666666666666d5555555056676650566766505555555
100000001dd6ddddddd11ddddddd6dd1000001dd6dd11dd6dd1000001dd6dd1000000000000000001ddddddd6ddddddd15666666056676660666766506666665
111000001dd6ddddddd11ddddddd6dd1000001dd6dd11dd6dd1000001dd6dd1000000000000000001ddddddd6ddddddd15666666056676660666766506666665
10000000111d1111111111111111d11100000111d111111d111000001dd6dd100000000000000000111111dd6dd1111115667777056677770777766507777665
000000000000000000000000000000000000000000000000000000001dd6dd100000000000000000000001dd6dd1000005667666056666660666666506667665
000000000000000000000000000000000000000000000000000000001dd6dd100000000000000000000001dd6dd1000005667666056666660666666506667665
000000000000000000000000000000000000000000000000000000001dd6dd100000000000000000000001dd6dd1000005667665055555550555555505667665
000000000000000000000000000000000000000000000000000000001dd6dd100000000000000000000001dd6dd1000000000000000000000000000000000000
00600000000000000000000000000000000000000000000000000000111d1110000000000000000000000111d11100000555d555056676650333d3330222d222
06000000222d2220000000000222d22222222222d222222d22222222222d22222222222d2222222200000222d2220000056676650566766503bb6bb302886882
677777762ee7ee200000000002ee7ee22eeeeeee7ee22ee7eeeeeee22ee7ee22eeeeeee7eeeeeee2000002ee7ee20000056676650566766503bbabb30288e882
060000002ee7ee200000000002ee7ee22eeeeeee7ee22ee7eeeeeee22ee7ee22eeeeeee7eeeeeee2000002ee7ee2000005667665056676650d6aaa6d0d6eee6d
006000002ee7ee200000000002ee7ee2d7777777777dd7777777777d2ee7ee2d777777777777777d000002ee7ee20000056676650566766503bbabb30288e882
000000002ee7ee200000000002ee7ee22eeeeeee7ee22ee7eeeeeee22ee7ee22eeeeeee7eeeeeee2000002ee7ee20000056676650566766503bb6bb302886882
000000002ee7ee222222222222ee7ee22eeeeeee7ee22ee7eeeeeee22ee7ee22eeeeeee7eeeeeee2222222ee7ee22222256676650555d5550333d3330222d222
000000002ee7eeeeeee22eeeeeee7ee2222222ee7ee22ee7ee2222222ee7ee222222222d222222222eeeeeee7eeeeeee20000000000000000000000000000000
000009002ee7eeeeeee22eeeeeee7ee2000002ee7ee22ee7ee2000002ee7ee2000000000000000002eeeeeee7eeeeeee255555550555d5550000000000000000
00000090d7777777777dd7777777777d000002ee7ee22ee7ee200000d77777d00000000000000000d777777777777777d5666665056676650000000000000000
9ffffff92ee7eeeeeee22eeeeeee7ee2000002ee7ee22ee7ee2000002ee7ee2000000000000000002eeeeeee7eeeeeee25666665056676650000000000000000
000000902ee7eeeeeee22eeeeeee7ee2000002ee7ee22ee7ee2000002ee7ee2000000000000000002eeeeeee7eeeeeee2d77777d056676650000000000000000
00000900222d2222222222222222d22200000222d222222d222000002ee7ee200000000000000000222222ee7ee2222225666665056676650000000000000000
000000000000000000000000000000000000000000000000000000002ee7ee200000000000000000000002ee7ee2000005666665056676650000000000000000
3bbb30200020000000000000000000000000000000000000000000002ee7ee200000000000000000000002ee7ee20000055555550555d5550000000000000000
0000b0800080000000000000000000000000000000000000000000002ee7ee200000000000000000000002ee7ee2000000000000000000000000000000000000
000b00080800000000000000000000000000000000000000000000002ee7ee200000000000000000000002ee7ee2000000000000000000000000000000000000
00b00000800000000000000000000000000000000000000000000000222d2220000000000000000000000222d222000000000000000000000000000000000000
0b000008080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b0000080008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3bbb3020002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d666d1ccc1eeeee228882999994bbbb34fff466d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
60006c000c00e00080008009000b000bf0006000d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
60006c000c00e00080008009000b000bf00060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
60006c000c00e00080008009000b000bf0000d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6666dc000c00e00088882009000b000bff4000600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6d000c000c00e00080008009000b000bf000000d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
60d00c000c00e00080008009000b000bf00000006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
60060c000c00e00080008009000b000bf00000006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
60006c000c00e00080008009000b000bf00060006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d000d1ccc1002000200020040003bbb34fff4d660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

