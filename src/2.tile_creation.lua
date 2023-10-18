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