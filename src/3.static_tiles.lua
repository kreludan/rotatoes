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