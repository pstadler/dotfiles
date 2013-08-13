require '/Applications/Zephyros.app/Contents/Resources/libs/zephyros.rb'

margin        = 5
mash_main     = ['ctrl', 'alt', 'cmd']
mash_corners  = ['ctrl', 'alt', 'shift']
mash_focus    = ['alt', 'shift']

API.update_settings :alert_should_animate => false


# reset to top center
API.bind '.', mash_main do
  ratio = 1.3
  win = API.focused_window
  frame = win.screen.frame_without_dock_or_menu
  frame.x = (frame.w / 2) - (frame.w / 2 / ratio)
  frame.h /= ratio
  frame.w /= ratio
  win.frame = frame
end


# push to top half of screen
API.bind 'UP', mash_main do
  win = API.focused_window
  frame = win.screen.frame_without_dock_or_menu
  frame.h /= 2
  frame.inset! margin, margin
  win.frame = frame
end

# push to bottom half of screen
  API.bind 'DOWN', mash_main do
  win = API.focused_window
  frame = win.screen.frame_without_dock_or_menu
  frame.y += frame.h / 2
  frame.h /= 2
  frame.inset! margin, margin
  win.frame = frame
end

# push to left half of screen
API.bind 'LEFT', mash_main do
  win = API.focused_window
  frame = win.screen.frame_without_dock_or_menu
  frame.w /= 2
  frame.inset! margin, margin
  win.frame = frame
end

# push to right half of screen
API.bind 'RIGHT', mash_main do
  win = API.focused_window
  frame = win.screen.frame_without_dock_or_menu
  frame.x += frame.w / 2
  frame.w /= 2
  frame.inset! margin, margin
  win.frame = frame
end


# push to top left of screen
API.bind 'LEFT', mash_corners do
  win = API.focused_window
  frame = win.screen.frame_without_dock_or_menu
  frame.w /= 2
  frame.h /= 2
  frame.inset! margin, margin
  win.frame = frame
end

# push to top right of screen
API.bind 'UP', mash_corners do
  win = API.focused_window
  frame = win.screen.frame_without_dock_or_menu
  frame.x += frame.w / 2
  frame.w /= 2
  frame.h /= 2
  frame.inset! margin, margin
  win.frame = frame
end

# push to bottom left of screen
API.bind 'DOWN', mash_corners do
  win = API.focused_window
  frame = win.screen.frame_without_dock_or_menu
  frame.y += frame.h / 2
  frame.w /= 2
  frame.h /= 2
  frame.inset! margin, margin
  win.frame = frame
end

# push to bottom right of screen
API.bind 'RIGHT', mash_corners do
  win = API.focused_window
  frame = win.screen.frame_without_dock_or_menu
  frame.x += frame.w / 2
  frame.y += frame.h / 2
  frame.w /= 2
  frame.h /= 2
  frame.inset! margin, margin
  win.frame = frame
end

# focus bindings
API.bind 'LEFT', mash_focus do
  API.focused_window.focus_window_left()
end

API.bind 'UP', mash_focus do
  API.focused_window.focus_window_up()
end

API.bind 'RIGHT', mash_focus do
  API.focused_window.focus_window_right()
end

API.bind 'DOWN', mash_focus do
  API.focused_window.focus_window_down()
end

API.bind '-', mash_main do
  str = API.clipboard_contents
  API.alert str if str
end

wait_on_callbacks