logger = hs.logger.new("config", "verbose")

hs.alert.defaultStyle.strokeColor = { white = 0, alpha = 0.75 }
hs.alert.defaultStyle.textSize = 25

-- Reload config
hs.hotkey.bind(mash.utils, "-", function()
  hs.reload()
end)
