
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

function create_tile_blueprint_from_name(tile_name)
  blueprint_strings = split(static_tile_blueprint_strings[tile_name], "-", false)
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
    if #point_strings[i] == 3 then
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

function add_static_tile_to_list(statictile_type, statictile_list, x_origin, y_origin)
  tile_index = 1
  tile_info = create_tile_blueprint_from_name(statictile_type)
  tile_to_prep = create_tile(
          tile_info.points, tile_info.center.x, tile_info.center.y, tile_info.spritestart_general.x,
          tile_info.spritestart_general.y, nil, nil, tile_info.waypoints)
  add(statictile_list, create_drawable_tile(tile_to_prep, x_origin, y_origin))
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