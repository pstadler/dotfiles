spaces = require("hs._asm.undocumented.spaces")

-- Config
local mash = {
  split   = {"ctrl", "alt", "cmd"},
  corner  = {"ctrl", "alt", "shift"},
  utils   = {"ctrl", "alt", "cmd"}
}

local spacesModifier = "ctrl"

local animationDuration = 0

local centeredWindowRatios = {
  small = { w = 0.8, h = 0.8 },
  large = { w = 0.66, h = 0.66 }
}


-- Setup
hs.window.animationDuration = animationDuration
local logger = hs.logger.new("config", "verbose")


-- Resize windows
local function adjust(x, y, w, h)
  local win = hs.window.focusedWindow()
  if not win then return end

  local f = win:frame()
  local max = win:screen():frame()

  f.w = math.floor(max.w * w)
  f.h = math.floor(max.h * h)
  f.x = math.floor((max.w * x) + max.x)
  f.y = math.floor((max.h * y) + max.y)

  win:setFrame(f)
end

local function adjustCenterTop(w, h)
  local win = hs.window.focusedWindow()
  if not win then return end

  local f = win:frame()
  local max = win:screen():frame()

  f.w = math.floor(max.w * w)
  f.h = math.floor(max.h * h)
  f.x = math.floor((max.w / 2) - (f.w / 2))
  f.y = max.y
  win:setFrame(f)
end

-- top half
hs.hotkey.bind(mash.split, "up", function() adjust(0, 0, 1, 0.5) end)

-- right half
hs.hotkey.bind(mash.split, "right", function() adjust(0.5, 0, 0.5, 1) end)

-- bottom half
hs.hotkey.bind(mash.split, "down", function() adjust(0, 0.5, 1, 0.5) end)

-- left half
hs.hotkey.bind(mash.split, "left", function() adjust(0, 0, 0.5, 1) end)

-- top left
hs.hotkey.bind(mash.corner, "up", function() adjust(0, 0, 0.5, 0.5) end)

-- top right
hs.hotkey.bind(mash.corner, "right", function() adjust(0.5, 0, 0.5, 0.5) end)

-- bottom right
hs.hotkey.bind(mash.corner, "down", function() adjust(0.5, 0.5, 0.5, 0.5) end)

-- bottom left
hs.hotkey.bind(mash.corner, "left", function() adjust(0, 0.5, 0.5, 0.5) end)

-- fullscreen
hs.hotkey.bind(mash.split, ",", function() adjustCenterTop(1, 1) end)

-- top center small
hs.hotkey.bind(mash.split, ".", function()
  local win = hs.window.focusedWindow()
  if not win then return end

  local size = win:screen():frame().w >= 2560 and "large" or "small"
  adjustCenterTop(centeredWindowRatios[size].w, centeredWindowRatios[size].h)
end)


-- Spaces
local spacesCount = spaces.count()
local spacesModifiers = {"fn", spacesModifier}

-- infinitely cycle through spaces using ctrl+left/right to trigger cmd+[1..n]
hs.eventtap.new({hs.eventtap.event.types.keyDown}, function(o)
  local keyCode = o:getKeyCode()
  local modifiers = o:getFlags()

  -- check if correct key code
  if keyCode ~= 123 and keyCode ~= 124 then return end
  if not modifiers[spacesModifier] then return end

  -- check if no other modifiers where pressed
  local passed = hs.fnutils.every(modifiers, function(_, modifier)
    return hs.fnutils.contains(spacesModifiers, modifier)
  end)

  if not passed then return end

  -- switch spaces
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


-- Caffeinate
-- Icon shamelessly copied from https://github.com/BrianGilbert/.hammerspoon
local caffeine = hs.menubar.new(false)
caffeine:setIcon("caffeine-on.pdf")

local function setCaffeineMenuItem(state)
  if state then
    caffeine:returnToMenuBar()
  else
    caffeine:removeFromMenuBar()
  end
end

function toggleCaffeine()
  setCaffeineMenuItem(hs.caffeinate.toggle("systemIdle"))
end

if caffeine then
  caffeine:setClickCallback(toggleCaffeine)
  setCaffeineMenuItem(hs.caffeinate.get("systemIdle"))
end

hs.hotkey.bind(mash.utils, "c", toggleCaffeine)

hs.alert.show("Hammerspoon!")