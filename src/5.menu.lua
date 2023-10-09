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
