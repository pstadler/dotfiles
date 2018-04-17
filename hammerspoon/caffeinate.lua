-- Caffeinate
-- Icon shamelessly copied from https://github.com/BrianGilbert/.hammerspoon
local caffeine

function toggleCaffeine()
  setCaffeineMenuItem(hs.caffeinate.toggle("systemIdle"))
end

function setCaffeineMenuItem(isIdle)
  if isIdle then
    if not caffeine then
      caffeine = hs.menubar.new()
      caffeine:setIcon(os.getenv("HOME") .. "/.hammerspoon/caffeine-on.pdf")
      caffeine:setClickCallback(toggleCaffeine)
    else
      caffeine:returnToMenuBar()
    end

    hs.alert.show("Caffeinated!")
  else
    caffeine:removeFromMenuBar()
    hs.alert.show("Decaf")
  end
end

hs.hotkey.bind(mash.utils, "c", toggleCaffeine)
