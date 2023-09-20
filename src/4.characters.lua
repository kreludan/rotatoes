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
        add_to_points(
          player_points,
          create_point(x, y, 1)
        )
      end
    else
      add_to_points(
        player_points,
        create_point(0, y, 1)
      )
    end
  end
  return player_points
end