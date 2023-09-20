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
      add_to_points(
        cross_points,
        create_point(2, i, 1)
      )
    end
  end
  for i = 0, 4 do
    add_to_points(
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
      add_to_points(
        plus_points,
        create_point(x, y, 1)
      )
    end
  end
  for x = 5, 11 do
    for y = 0, 4 do
      add_to_points(
        plus_points,
        create_point(x, y, 1)
      )
    end
    for y = 12, 16 do
      add_to_points(
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
      add_to_points(
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
      add_to_points(
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
      add_to_points(
        l4_points,
        create_point(x, y, 1)
      )
    end
  end
  for y = 7, 11 do
    for x = 0, 6 do
      add_to_points(
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
      add_to_points(
        l3_points,
        create_point(x, y, 1)
      )
    end
  end
  for y = 7, 11 do
    for x = 5, 11 do
      add_to_points(
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
      add_to_points(
        l2_points,
        create_point(x, y, 1)
      )
    end
  end
  for y = 5, 11 do
    for x = 0, 11 do
      add_to_points(
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
      add_to_points(
        l1_points,
        create_point(x, y, 1)
      )
    end
  end
  for y = 5, 11 do
    for x = 0, 11 do
      add_to_points(
        l1_points,
        create_point(x, y, 1)
      )
    end
  end
  return l1_points
end