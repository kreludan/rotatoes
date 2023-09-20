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

function rotate_tile(tile)
  cx = tile.center_x
  cy = tile.center_y
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