-- Caffeinate
-- Icon shamelessly copied from https://github.com/BrianGilbert/.hammerspoon
local caffeine

function toggleCaffeine()
  setCaffeineMenuItem(hs.caffeinate.toggle("systemIdle"))
end

function setCaffeineMenuItem(isIdle)
  if isIdle then
    caffeine = hs.menubar.new()
    caffeine:setIcon(hs.image.imageFromPath(os.getenv("HOME") .. "/.hammerspoon/caffeine-on.pdf"))
    caffeine:setClickCallback(toggleCaffeine)

    hs.alert.show("Caffeinated!")
  else
    caffeine:delete()

    hs.alert.show("Decaf")
  end
end

hs.hotkey.bind(mash.utils, "c", toggleCaffeine)
