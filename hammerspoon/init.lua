spaces = require("hs._asm.undocumented.spaces")

-- Config
local mash = {
  split   = {"ctrl", "alt", "cmd"},
  corner  = {"ctrl", "alt", "shift"},
  utils   = {"ctrl", "alt", "cmd"}
}

local spacesModifier = "ctrl"

local gridSize = "2x2"
local gridMargins = {0, 0}
local animationDuration = 0

local winCenterRatios = {
  small = { w = 0.8, h = 0.8 },
  large = { w = 0.66, h = 0.66 }
}


-- Setup
hs.grid.setGrid(gridSize, nil)
hs.grid.setMargins(gridMargins)
hs.window.animationDuration = animationDuration
local logger = hs.logger.new("config", "verbose")


-- Resize windows
-- top half
hs.hotkey.bind(mash.split, "up", function()
  hs.grid.set(hs.window.focusedWindow(), "0,0 2x1")
end)

-- right half
hs.hotkey.bind(mash.split, "right", function()
  hs.grid.set(hs.window.focusedWindow(), "1,0 1x2")
end)

-- bottom half
hs.hotkey.bind(mash.split, "down", function()
  hs.grid.set(hs.window.focusedWindow(), "0,1 2x1")
end)

-- left half
hs.hotkey.bind(mash.split, "left", function()
  hs.grid.set(hs.window.focusedWindow(), "0,0 1x2")
end)

-- top left
hs.hotkey.bind(mash.corner, "up", function()
  hs.grid.set(hs.window.focusedWindow(), "0,0 1x1")
end)

-- top right
hs.hotkey.bind(mash.corner, "right", function()
  hs.grid.set(hs.window.focusedWindow(), "1,0 1x1")
end)

-- bottom right
hs.hotkey.bind(mash.corner, "down", function()
  hs.grid.set(hs.window.focusedWindow(), "0,1 1x1")
end)

-- bottom left
hs.hotkey.bind(mash.corner, "left", function()
  hs.grid.set(hs.window.focusedWindow(), "0,0 1x1")
end)

-- top center
hs.hotkey.bind(mash.split, ".", function()
  local win = hs.window.focusedWindow()
  if win == nil then return end

  local f = win:frame()
  local max = win:screen():frame()
  local size = max.w >= 2560 and "large" or "small"
  f.w = max.w * resetRatios[size].w
  f.h = max.h * resetRatios[size].h
  f.x = (max.w / 2) - (f.w / 2)
  f.y = max.y
  win:setFrame(f)
end)

-- top center
hs.hotkey.bind(mash.split, ".", function()
  local win = hs.window.focusedWindow()
  if win == nil then return end

  local f = win:frame()
  local max = win:screen():frame()
  local size = max.w >= 2560 and "large" or "small"
  f.w = max.w * winCenterRatios[size].w
  f.h = max.h * winCenterRatios[size].h
  f.x = (max.w / 2) - (f.w / 2)
  f.y = max.y
  win:setFrame(f)
end)

-- full screen
hs.hotkey.bind(mash.split, ",", function()
  local win = hs.window.focusedWindow()
  if win == nil then return end

  local f = win:frame()
  local max = win:screen():frame()
  f.w = max.w
  f.h = max.h
  f.x = max.x
  f.y = max.y
  win:setFrame(f)
end)


-- Spaces
local spacesCount = spaces.count()
local spacesModifiers = {"fn", spacesModifier}

-- infinitely cycle through spaces using ctrl+left/right to trigger cmd+[1..n]
hs.eventtap.new({hs.eventtap.event.types.keyDown}, function(o)
  local passed = hs.fnutils.every(o:getFlags(), function(_, flag)
    return hs.fnutils.contains(spacesModifiers, flag)
  end)

  if not passed then return end

  local keyCode = o:getKeyCode()

  if keyCode ~= 123 and keyCode ~= 124 then return end

  local currentSpace = spaces.currentSpace()
  local nextSpace

  -- left arrow
  if keyCode == 123 then
    nextSpace = currentSpace ~= 1 and currentSpace - 1 or spacesCount
   -- right arrow
  elseif keyCode == 124 then
    nextSpace = currentSpace ~= spacesCount and currentSpace + 1 or 1
  end

  hs.eventtap.keyStroke({spacesModifier}, string.format("%d", nextSpace))

  -- stop propagation
  return true
end):start()


-- Wifi
local wifiWatcher = nil
function ssidChangedCallback()
    local ssid = hs.wifi.currentNetwork()
    if ssid then
      hs.alert.show("Network connected: " .. ssid)
    end
end
wifiWatcher = hs.wifi.watcher.new(ssidChangedCallback)
wifiWatcher:start()

hs.hotkey.bind(mash.utils, "r", function()
  local ssid = hs.wifi.currentNetwork()
  if not ssid then return end

  hs.alert.show("Reconnecting to: " .. ssid)
  hs.execute("networksetup -setairportpower en0 off")
  hs.execute("networksetup -setairportpower en0 on")
end)