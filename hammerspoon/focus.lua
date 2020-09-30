-- Focus windows
hs.hotkey.bind(mash.focus, "up",  hs.window.frontmostWindow().focusWindowNorth)
hs.hotkey.bind(mash.focus, "right", hs.window.frontmostWindow().focusWindowEast)
hs.hotkey.bind(mash.focus, "down", hs.window.frontmostWindow().focusWindowSouth)
hs.hotkey.bind(mash.focus, "left", hs.window.frontmostWindow().focusWindowWest)