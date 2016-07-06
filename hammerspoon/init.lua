spaces = require("hs._asm.undocumented.spaces")

-- Config
local mash = {
  split   = {"ctrl", "alt", "cmd"},
  corner  = {"ctrl", "alt", "shift"},
  focus   = {"ctrl", "alt"},
  utils   = {"ctrl", "alt", "cmd"}
}

local spacesModifier = "ctrl"

local animationDuration = 0

local centeredWindowRatios = {
  small = { w = 0.8, h = 0.8 }, -- screen width < 2560
  large = { w = 0.66, h = 0.66 } -- screen width >= 2560
}


-- Setup
hs.window.animationDuration = animationDuration
local logger = hs.logger.new("config", "verbose")


-- Reload config
hs.hotkey.bind(mash.utils, "-", function()
  hs.reload()
end)


-- Resize windows
local function adjust(x, y, w, h)
  return function()
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
end

local function adjustCenter(w, h)
  return function()
    local win = hs.window.focusedWindow()
    if not win then return end

    local f = win:frame()
    local max = win:screen():frame()

    f.w = math.floor(max.w * w)
    f.h = math.floor(max.h * h)
    f.x = math.floor((max.w / 2) - (f.w / 2))
    f.y = math.floor((max.h / 2) - (f.h / 2))
    win:setFrame(f)
  end
end

-- top half
hs.hotkey.bind(mash.split, "up", adjust(0, 0, 1, 0.5))

-- right half
hs.hotkey.bind(mash.split, "right", adjust(0.5, 0, 0.5, 1))

-- bottom half
hs.hotkey.bind(mash.split, "down", adjust(0, 0.5, 1, 0.5))

-- left half
hs.hotkey.bind(mash.split, "left", adjust(0, 0, 0.5, 1))

-- top left
hs.hotkey.bind(mash.corner, "up", adjust(0, 0, 0.5, 0.5))

-- top right
hs.hotkey.bind(mash.corner, "right", adjust(0.5, 0, 0.5, 0.5))

-- bottom right
hs.hotkey.bind(mash.corner, "down", adjust(0.5, 0.5, 0.5, 0.5))

-- bottom left
hs.hotkey.bind(mash.corner, "left", adjust(0, 0.5, 0.5, 0.5))

-- fullscreen
hs.hotkey.bind(mash.split, ",", adjustCenter(1, 1))

-- top center small
hs.hotkey.bind(mash.split, ".", function()
  local win = hs.window.focusedWindow()
  if not win then return end

  local size = win:screen():frame().w >= 2560 and "large" or "small"
  adjustCenter(centeredWindowRatios[size].w, centeredWindowRatios[size].h)()
end)

-- Focus windows
local function focus(direction)
  local fn = "focusWindow" .. (direction:gsub("^%l", string.upper))

  return function()
    local win = hs.window:focusedWindow()
    if not win then return end

    win[fn]()
  end
end

hs.hotkey.bind(mash.focus, "up", focus("north"))
hs.hotkey.bind(mash.focus, "right", focus("east"))
hs.hotkey.bind(mash.focus, "down", focus("south"))
hs.hotkey.bind(mash.focus, "left", focus("west"))


-- Spaces
local spacesCount = spaces.count()
local spacesModifiers = {"fn", spacesModifier}

-- infinitely cycle through spaces using ctrl+left/right to trigger ctrl+[1..n]
local spacesEventtap = hs.eventtap.new({hs.eventtap.event.types.keyDown}, function(o)
  local keyCode = o:getKeyCode()
  local modifiers = o:getFlags()

  --logger.i(keyCode, hs.inspect(modifiers))

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

hs.hotkey.bind(mash.utils, "e", function()
  -- this is to bind the spacesEventtap variable to a long-lived function in
  -- order to prevent GC from doing their evil business
  hs.alert.show("Fast space switching enabled: " .. tostring(spacesEventtap:isEnabled()))
end)

-- Wifi
function ssidChangedCallback()
    local ssid = hs.wifi.currentNetwork()
    if ssid then
      hs.alert.show("Network connected: " .. ssid)
    end
end

hs.wifi.watcher.new(ssidChangedCallback):start()

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
caffeine:setIcon(os.getenv("HOME") .. "/.hammerspoon/caffeine-on.pdf")

local function setCaffeineMenuItem(state)
  if state then
    caffeine:returnToMenuBar()
    hs.alert.show("Caffeinated!")
  else
    caffeine:removeFromMenuBar()
    hs.alert.show("Decaf")
  end
end

function toggleCaffeine()
  setCaffeineMenuItem(hs.caffeinate.toggle("systemIdle"))
end

if caffeine then
  caffeine:setClickCallback(toggleCaffeine)
end

hs.hotkey.bind(mash.utils, "c", toggleCaffeine)


-- Battery
local previousPowerSource = hs.battery.powerSource()

function minutesToHours(minutes)
  if minutes <= 0 then
    return "0:00";
  else
    hours = string.format("%d", math.floor(minutes / 60))
    mins = string.format("%02.f", math.floor(minutes - (hours * 60)))
    return string.format("%s:%s", hours, mins)
  end
end

function showBatteryStatus()
  local message

  if hs.battery.isCharging() then
    local pct = hs.battery.percentage()
    local untilFull = hs.battery.timeToFullCharge()
    message = "Charging"

    if untilFull == -1 then
      message = string.format("%s %.0f%% (calculating...)", message, pct);
    else
      message = string.format("%s %.0f%% (%s remaining)", message, pct, minutesToHours(untilFull))
    end
  elseif hs.battery.powerSource() == "Battery Power" then
    local pct = hs.battery.percentage()
    local untilEmpty = hs.battery.timeRemaining()
    message = "Battery"

    if untilEmpty == -1 then
      message = string.format("%s %.0f%% (calculating...)", message, pct)
    else
      message = string.format("%s %.0f%% (%s remaining)", message, pct, minutesToHours(untilEmpty))
    end
  else
    message = "Fully charged"
  end

  hs.alert.show(message)
end

function batteryChangedCallback()
  local powerSource = hs.battery.powerSource()

  if powerSource ~= previousPowerSource then
    showBatteryStatus()
    previousPowerSource = powerSource;
  end
end

hs.battery.watcher.new(batteryChangedCallback):start()

hs.hotkey.bind(mash.utils, "b", showBatteryStatus)


-- All set
hs.alert.show("Hammerspoon!")
