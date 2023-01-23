-- Fast space switching using https://github.com/asmagill/hs._asm.spaces
local spaces = require("hs.spaces")

local spacesModifier = "ctrl"

local spacesTable = spaces.spacesForScreen()
local spacesCount = #spacesTable
local spacesModifiers = {"fn", spacesModifier}

function getFocusedSpaceIndex()
  local focusedSpace = spaces.focusedSpace()
  for k, v in ipairs(spacesTable) do
    if v == focusedSpace then return k end
  end
end

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
  local currentSpace = getFocusedSpaceIndex()
  local nextSpace

  -- left arrow
  if keyCode == 123 then
    nextSpace = currentSpace ~= 1 and currentSpace - 1 or spacesCount
   -- right arrow
  elseif keyCode == 124 then
    nextSpace = currentSpace ~= spacesCount and currentSpace + 1 or 1
  end

  local event = require("hs.eventtap").event
  hs.eventtap.keyStroke({spacesModifier}, string.format("%d", nextSpace), 0)

  -- stop propagation
  return true
end):start()

hs.hotkey.bind(mash.utils, "e", function()
  -- this is to bind the spacesEventtap variable to a long-lived function in
  -- order to prevent GC from doing their evil business
  hs.alert.show("Fast space switching enabled: " .. tostring(spacesEventtap:isEnabled()))
end)
