-- Shared presentation and utility helpers for subscription indicators.
local M = {}

function M.resetText(resetsAt)
  if type(resetsAt) ~= "number" then return "reset unavailable" end
  local seconds = math.max(0, resetsAt - os.time())
  local days = math.floor(seconds / 86400)
  local hours = math.floor(seconds / 3600) % 24
  local minutes = math.floor(seconds / 60) % 60
  if days > 0 then return string.format("resets in %dd %dh", days, hours) end
  if hours > 0 then return string.format("resets in %dh %dm", hours, minutes) end
  if seconds >= 60 then return string.format("resets in %dm", minutes) end
  if seconds > 0 then return "resets in <1m" end
  return "reset due"
end

function M.formatCount(value)
  local digits = string.format("%.0f", math.abs(value))
  local grouped = ""
  while #digits > 3 do
    grouped = "," .. digits:sub(-3) .. grouped
    digits = digits:sub(1, -4)
  end
  return (value < 0 and "-" or "") .. digits .. grouped
end

function M.usageBar(remaining, fillHex)
  local width, height = 140, 6
  local canvas = hs.canvas.new({x = 0, y = 0, w = width, h = 16})
  canvas[1] = {
    type = "rectangle", action = "fill",
    frame = {x = 0, y = 6, w = width, h = height},
    roundedRectRadii = {xRadius = 4, yRadius = 4},
    fillColor = {white = 0.5, alpha = 0.5}
  }
  if remaining > 0 then
    local filledWidth = math.max(1, width * math.min(100, remaining) / 100)
    canvas[2] = {
      type = "rectangle", action = "fill",
      frame = {x = 0, y = 6, w = filledWidth, h = height},
      roundedRectRadii = {xRadius = math.min(4, filledWidth / 2), yRadius = math.min(4, filledWidth / 2)},
      fillColor = {hex = fillHex, alpha = 1}
    }
  end
  local image = canvas:imageFromCanvas()
  canvas:delete()
  return image
end

function M.updateTitle(menubar, remaining, resetsAt)
  if not remaining then return end
  local percentage = remaining == math.huge and "∞" or string.format("%.0f%%", remaining)
  local countdown = M.resetText(resetsAt):gsub("^resets in ", "")
  local title = hs.styledtext.new(percentage .. "\n" .. countdown, {
    font = {name = ".AppleSystemUIFont", size = 8},
    baselineOffset = -5,
    paragraphStyle = {alignment = "left", minimumLineHeight = 8, maximumLineHeight = 8}
  })
  title = title:setStyle({font = {name = ".AppleSystemUIFont", size = 12}}, 1, #percentage)
  menubar:setTitle(title)
end

function M.findExecutable(setting, candidates)
  local configured = hs.settings.get(setting)
  if configured and hs.fs.attributes(configured, "mode") == "file" then return configured end
  for _, path in ipairs(candidates) do
    if hs.fs.attributes(path, "mode") == "file" then return path end
  end
end

return M
