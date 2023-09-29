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
    get_next_waypoint(characters_to_draw[i], waypoints, max_distance)
    characters_to_draw.tile_on = get_tile_on(characters_to_draw[i])
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