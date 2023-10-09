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

function generate_win_menu()
  rectfill(36, 35, 92, 65, 0)
  rect(36, 35, 92, 65, 7)
  print("complete :0", 42, 39, 11)
  print("next lvl:[ ]", 41, 47, 7)
  print("main menu:[ ]", 39, 55, 7)
  print("z", 81, 47, 11)
  print("x", 83, 55, 8)
end

function generate_lose_menu()
  rectfill(36, 35, 92, 65, 0)
  rect(36, 35, 92, 65, 7)
  print("lose :(", 51, 39, 8)
  print("restart:[ ]", 43, 47, 7)
  print("main menu:[ ]", 39, 55, 7)
  print("z", 79, 47, 11)
  print("x", 83, 55, 8)
end
