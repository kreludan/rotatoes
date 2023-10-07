function generate_main_menu()
  print("rotatoes", 48, 20)
  print("press ❎ to play", 33, 40)
end

function handle_menu_input()
  if btnp(❎) then
    _init_level(level_num)
  end
end

function generate_win_menu()
  print("you win :0", 45, 20)
  print("press ❎ to go to next level", 10, 40)
end

function generate_lose_menu()
  print("you lose :(", 44, 20)
  print("press ❎ to restart", 28, 40)
end
