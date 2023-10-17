rotator_blueprint_strings = {
  l1 = "0,0:6,11|7,5:11,11-3,8-3,3|3,8|8,8-8,0-8,17-nil",
  l2 = "0,5:4,11|5,0:11,11-8,8-3,8|8,8|8,3-20,0-20,17-nil",
  l3 = "0,0:4,6|5,0:11,11-3,8-3,3|3,8|8,8-32,0-32,17-nil",
  l4 = "0,0:6,11|7,0:11,6-3,3-3,8|3,3|8,3-44,0-44,17-nil",
  vert = "0,0:6,16-3,8-3,3|3,8|3,13-56,0-56,17-nil",
  horiz = "0,0:16,6-8,3-3,3|8,3|13,3-63,0-63,17-nil",
  plus = "0,5:4,11|5,0:11,16|12,5:16,11-8,8-3,8|8,3|8,8|8,13|13,8-80,0-80,17-nil"
}

static_tile_blueprint_strings = {
  corrend_left = "0,0:6,6-3,3-3,3-97,0-nil-nil-nil",
  corrend_right = "0,0:6,6-3,3-3,3-121,0-nil-nil-nil",
  corrend_up = "0,0:6,6-3,3-3,3-97,16-nil-nil-nil",
  corrend_down = "0,0:6,6-3,3-3,3-105,16-nil-nil-nil",
  corr_horiz = "0,0:6,6-3,3-3,3-105,0-nil-nil-nil",
  corr_vert = "0,0:6,6-3,3-3,3-113,0-nil-nil-nil",
  corr_turn_upleft = "0,0:6,6-3,3-3,3-97,8-nil-nil-nil",
  corr_turn_upright = "0,0:6,6-3,3-3,3-121,8-nil-nil-nil",
  corr_turn_downleft = "0,0:6,6-3,3-3,3-105,8-nil-nil-nil",
  corr_turn_downright = "0,0:6,6-3,3-3,3-113,8-nil-nil-nil",
  corr_singleton = "0,0:6,6-3,3-3,3-97,24-nil-nil-nil",
}

character_blueprint_strings = {
  enemy_basic = "0,0|0,2|0,4|1,1:1,3|2,2-1,2-nil-0,3-nil-nil-nil",
  player = "0,0|0,2|0,4|1,1:1,3|2,2-1,2-nil-0,8-nil-nil-nil",
  goal = "0,0:6,6-3,3-3,3-113,16-nil-nil-nil",
  deathtile = "0,0:6,6-3,3-3,3-121,16-nil-nil-nil"
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
    print("buh")
    return {rotator_blueprint_strings, rotators_to_draw}
  end
end