
function generate_main_menu(option_selected)
  cls(7) -- clear screen, set as white
  palt(15, true) -- beige color as transparency is true
  palt(0, false) -- black color as transparency is false

  _draw_ui_elements()
  sspr(0, 37, 41, 10, 44, 30)
  y_locations = {45, 53, 61}
  descriptions = {"new game", "level select", "settings"}
  x_colors = {14, 8, 2}
  for i=1,count(descriptions) do
    print("[", 36, y_locations[i], 0)
    print("]", 42, y_locations[i], 0)
    print(descriptions[i], 49, y_locations[i], 0)
  end
  print("x", 39, y_locations[option_selected], x_colors[option_selected])
end

function init_main_menu()
  level_num = 1
  main_menu_option = 1
  level_state = "menu"
end

function handle_menu_input()
  if btnp(⬆️) then
    main_menu_option = max(1, main_menu_option-1)
  elseif btnp(⬇️) then
    main_menu_option = min(3, main_menu_option+1)
  elseif btnp(❎) or btnp(🅾️) then
    if main_menu_option == 1 then
      _init_level(level_num)
    else
      level_select_option = 1
      level_state = "level_select"
    end
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
      init_main_menu()
    end
  end
end

function generate_win_menu(option_selected)
  rectfill(26, 35, 99, 75, 7)
  rect(26, 35, 99, 75, 0)
  print("complete :0", 42, 39, 11)
  y_locations = {47, 55, 63}
  option_text = {"next level", "replay level", "main menu"}
  x_colors = {11, 12, 8}
  for i=1,3 do
    print("[", 35, y_locations[i], 0)
    print("]", 41, y_locations[i], 0)
    print(option_text[i], 48, y_locations[i], 0)
  end
  print("x", 38, y_locations[option_selected], x_colors[option_selected])
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
      init_main_menu()
    end
  end
end

function generate_lose_menu(option_selected)
  rectfill(26, 35, 99, 65, 7)
  rect(26, 35, 99, 65, 0)
  print("lose :(", 51, 39, 8)
  y_locations = {47, 55}
  option_text = {"replay lvl", "main menu"}
  x_colors = {12, 8}
  for i=1,2 do
    print("[", 35, y_locations[i], 0)
    print("]", 41, y_locations[i], 0)
    print(option_text[i], 48, y_locations[i], 0)
  end
  print("x", 38, y_locations[option_selected], x_colors[option_selected])
end
