pico-8 cartridge // http://www.pico-8.com
version 38
__lua__
--global
function _init()
  cls()
  max_distance = 7
  controlled_tile = 1
  rotators_to_draw = {}
  static_tiles_to_draw = {}
  characters_to_draw = {}
  waypoints = {}
  _init_rotators()
  _init_static_tiles()
  _init_characters()
  _init_waypoints()
  _init_character_details()
end

function _init_characters()
  add_char_to_list(
    "player",
    characters_to_draw,
    30, 63
  )
end

function _init_character_details()
  for i=1,count(characters_to_draw) do
    characters_to_draw[i].waypoint_from = get_starting_waypoint(characters_to_draw[i], waypoints)
  end
end

function _init_rotators()
  rotator_blueprint = {
    { "vert", 63, 63 },
    { "l1", 30, 30 },
    { "l2", 50, 30 },
    { "l3", 70, 30 },
    { "l4", 96, 51 },
    { "horiz", 30, 90 },
    { "plus", 50, 90 }
  }
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
  static_tile_blueprint = {
    { "corrend_left", 30, 63 },
    { "corr_horiz", 37, 63 },
    { "corr_horiz", 44, 63 },
    { "corrend_right", 51, 63 },
    { "corrend_left", 75, 63 },
    { "corr_horiz", 82, 63 },
    { "corr_horiz", 89, 63 },
    { "corrend_right", 96, 63 }
  }

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
  _handlerots()
  _handlerotends()
  _handlecharmovement()
end

function _handlecharmovement()
  for i = 1, count(characters_to_draw) do
    characters_to_draw[i] = move_character(characters_to_draw[i])
  end
end

function _handleinputs()
  if btnp(⬆️) then
    if controlled_tile
        == count(rotators_to_draw) then
      controlled_tile = 1
    else
      controlled_tile += 1
    end
  elseif btnp(⬇️) then
    if controlled_tile == 1 then
      controlled_tile = count(rotators_to_draw)
    else
      controlled_tile -= 1
    end
  end

  if btnp(0) or btnp(1) then
    i = controlled_tile
    if rotators_to_draw[i].rotating
        == false then
      rotators_to_draw[i].rotating = true
      rotators_to_draw[i] = set_origins(rotators_to_draw[i])
      if btnp(0) then
        rotators_to_draw[i].rotatedir = 1
      else
        rotators_to_draw[i].rotatedir = -1
      end
      rotators_to_draw[i].thetacounter = 0
    end
  end
end

function _handlerots()
  for i = 1, count(rotators_to_draw) do
    if rotators_to_draw[i].rotating then
      rotators_to_draw[i] = rotate_tile(rotators_to_draw[i], rotators_to_draw[i].center_x, rotators_to_draw[i].center_y)
    end
  end
end

function _handlerotends()
  for i = 1, count(rotators_to_draw) do
    if rotators_to_draw[i].rotating then
      rotators_to_draw[i].thetacounter += rotators_to_draw[i].theta
      if rotators_to_draw[i].thetacounter == 90 then
        rotators_to_draw[i] = fix_end_rot(rotators_to_draw[i], rotators_to_draw[i].draw_waypoints)
        rotators_to_draw[i] = fix_end_rot(rotators_to_draw[i], rotators_to_draw[i].draw_points)
        rotators_to_draw[i].rotating = false
        thetacounter = 0
      end
    end
  end
end

function _draw()
  cls()
  _draw_ui_elements()

  for i = 1, count(rotators_to_draw) do
    if i == controlled_tile then
      draw_tile(rotators_to_draw[i], true)
    else
      draw_tile(rotators_to_draw[i], false)
    end
  end

  for i = 1, count(static_tiles_to_draw) do
    draw_tile(static_tiles_to_draw[i], false)
    --_debug_draw_waypoints_for_tile(static_tiles_to_draw[i])
  end

  for i = 1, count(characters_to_draw) do
    draw_tile(characters_to_draw[i], false)
    get_next_waypoint(characters_to_draw[i], waypoints, max_distance)
  end

  _debug_drawwaypoints()
end

function _draw_ui_elements()
  rect(0, 0, 127, 127, 7)
end

function _debug_draw_waypoints_for_tile(tile)
  for i = 1,count(tile.draw_waypoints) do
    pset(tile.draw_waypoints[i].x, tile.draw_waypoints[i].y, 12)
  end
end

function _debug_drawwaypoints()
  tile_on = get_tile_on(characters_to_draw[1])
  for i = 1, count(tile_on.draw_waypoints) do
    pset(tile_on.draw_waypoints[i].x, tile_on.draw_waypoints[i].y, 12)
  end
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

function cast_tile_to_char(tile, char_type)
  tile.is_character = true
  tile.char_type = char_type
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

function rotate_tile(tile, cx, cy)
  for i = 1, count(tile.draw_points) do
    local newpoint = create_rotated_point(
      tile.draw_points[i],
      cx, cy, tile.theta * tile.rotatedir
    )
    tile.draw_points[i] = newpoint
  end
  return tile
end

function set_origins(tile)
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

function fix_end_rot(tile, tile_points)
  for i = 1, count(tile_points) do
    tpx0 = tile_points[i].x0 - tile.center_x
    tpy0 = tile_points[i].y0 - tile.center_y
    if tile.rotatedir == 1 then
      tile_points[i].x = tpy0 + tile.center_x
      tile_points[i].y = -tpx0 + tile.center_y
    elseif tile.rotatedir == -1 then
      tile_points[i].x = -tpy0 + tile.center_x
      tile_points[i].y = tpx0 + tile.center_y
    end
  end
  return tile
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
    { "corr_turn_downright", 113, 8 }
  }
  tile_to_prep = {}
  while tileindex
      != count(tile_types) do
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
  tile_to_prep = create_player()
  add(
    char_list,
    create_drawable_tile(
      tile_to_prep,
      x_origin, y_origin
    )
  )
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
      else
        add(eligible_waypoints_vertical, waypoints[i])
      end
    elseif waypoints[i].draw_waypoint.y == curr_y then
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
  if char.movement_dir == "right" then
    char.movement_dir = "up"
  elseif char.movement_dir == "up" then
    char.movement_dir = "left"
  elseif char.movement_dir == "left" then
    char.movement_dir = "down"
  else
    char.movement_dir = "right"
  end

  x_origin = char.center_x
  y_origin = char.center_y
  for i=1,count(char.draw_points) do
    zeroed_x = char.draw_points[i].x0 - char.center_x
    zeroed_y = char.draw_points[i].y0 - char.center_y
    char.draw_points[i].x = zeroed_y  + char.center_x
    char.draw_points[i].y = (zeroed_x * -1) + char.center_y
  end
end

function turn_clockwise(char)
  if char.movement_dir == "right" then
    char.movement_dir = "down"
  elseif char.movement_dir == "up" then
    char.movement_dir = "right"
  elseif char.movement_dir == "left" then
    char.movement_dir = "up"
  else
    char.movement_dir = "left"
  end

  x_origin = char.center_x
  y_origin = char.center_y
  for i=1,count(char.draw_points) do
    zeroed_x = char.draw_points[i].x0 - char.center_x
    zeroed_y = char.draw_points[i].y0 - char.center_y
    char.draw_points[i].x = (zeroed_y * -1)  + char.center_x
    char.draw_points[i].y = zeroed_x + char.center_y
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
  char_speed = 1
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
  player_tile = create_tile(
    player_points, 0, 1, 0, 9, 0, 9
  )
  player_tile = cast_tile_to_char(
    player_tile, "player"
  )
  return player_tile
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
800000001dd6ddddddd11ddddddd6dd1000001dd6dd11dd6dd1000001dd6dd1000000000000000001ddddddd6ddddddd15666666056676660666766506666665
888000001dd6ddddddd11ddddddd6dd1000001dd6dd11dd6dd1000001dd6dd1000000000000000001ddddddd6ddddddd15666666056676660666766506666665
80000000111d1111111111111111d11100000111d111111d111000001dd6dd100000000000000000111111dd6dd1111115667777056677770777766507777665
000000000000000000000000000000000000000000000000000000001dd6dd100000000000000000000001dd6dd1000005667666056666660666666506667665
080000000000000000000000000000000000000000000000000000001dd6dd100000000000000000000001dd6dd1000005667666056666660666666506667665
080000000000000000000000000000000000000000000000000000001dd6dd100000000000000000000001dd6dd1000005667665055555550555555505667665
888000000000000000000000000000000000000000000000000000001dd6dd100000000000000000000001dd6dd1000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000111d1110000000000000000000000111d11100000555d555056676650333333305555555
00800000222d2220000000000222d22222222222d222222d22222222222d22222222222d2222222200000222d2220000056676650566766503bbbbb305888885
888000002ee7ee200000000002ee7ee22eeeeeee7ee22ee7eeeeeee22ee7ee22eeeeeee7eeeeeee2000002ee7ee20000056676650566766503bbbbb305888885
008000002ee7ee200000000002ee7ee22eeeeeee7ee22ee7eeeeeee22ee7ee22eeeeeee7eeeeeee2000002ee7ee20000056676650566766503bbbbb305888885
000000002ee7ee200000000002ee7ee2d7777777777dd7777777777d2ee7ee2d777777777777777d000002ee7ee20000056676650566766503bbbbb305888885
888000002ee7ee200000000002ee7ee22eeeeeee7ee22ee7eeeeeee22ee7ee22eeeeeee7eeeeeee2000002ee7ee20000056676650566766503bbbbb305888885
080000002ee7ee222222222222ee7ee22eeeeeee7ee22ee7eeeeeee22ee7ee22eeeeeee7eeeeeee2222222ee7ee22222256676650555d5550333333305555555
080000002ee7eeeeeee22eeeeeee7ee2222222ee7ee22ee7ee2222222ee7ee222222222d222222222eeeeeee7eeeeeee20000000000000000000000000000000
000000002ee7eeeeeee22eeeeeee7ee5000002ee7ee22ee7ee2000002ee7ee2000000000000000002eeeeeee7eeeeeee20000000000000000000000000000000
00000000d7777777777dd7777777777d000002ee7ee22ee7ee200000d77777d00000000000000000d777777777777777d0000000000000000000000000000000
000000002ee7eeeeeee22eeeeeee7ee2000002ee7ee22ee7ee2000002ee7ee2000000000000000002eeeeeee7eeeeeee20000000000000000000000000000000
000000002ee7eeeeeee22eeeeeee7ee2000002ee7ee22ee7ee2000002ee7ee2000000000000000002eeeeeee7eeeeeee20000000000000000000000000000000
00000000222d2222222222222222d22200000222d222222d222000002ee7ee200000000000000000222222ee7ee2222220000000000000000000000000000000
000000000000000000000000000000000000000000000000000000002ee7ee200000000000000000000002ee7ee2000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000002ee7ee200000000000000000000002ee7ee2000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000002ee7ee200000000000000000000002ee7ee2000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000002ee7ee200000000000000000000002ee7ee2000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000222d2220000000000000000000000222d222000000000000000000000000000000000000

