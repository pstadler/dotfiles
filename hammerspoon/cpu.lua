local updateFrequency = 3
local imageHeight = 17
local barWidth = 3
local gridSpacing = 2
local frameAlpha = 1
local barAlpha = 0

local maxBarHeight = (imageHeight - (gridSpacing * 3)) / 2

local menubar = hs.menubar.new():autosaveName("cpu")
local canvas
local timer

local canvasFrameItems = 0

function update(data)
  local usages
  local numberOfCores = data.n
  local barsPerRow = numberOfCores / 2
  local imageWidth = barsPerRow * (barWidth + gridSpacing) + gridSpacing

  -- init canvas only once
  if canvas == nil then
    canvas = hs.canvas.new {
      x = 0,
      y = 0,
      w = imageWidth,
      h = imageHeight
    }

    canvas[1] = {
      action = "fill",
      type = "rectangle",
      fillColor = {alpha = frameAlpha},
      frame = {x = 0, y = 0, w = imageWidth, h = imageHeight},
      roundedRectRadii = {xRadius = 1, yRadius = 1},
      clipToPath = true
    }

    -- local barBackgroundAlpha = .1
    -- for i = 1, numberOfCores do
    --   local y = imageHeight - gridSpacing
    --   local x = i - 1
    --   if i <= numberOfCores / 2 then
    --     y = y / 2
    --   elseif i > numberOfCores / 2 then
    --     x = x - (numberOfCores / 2)
    --   end

    --   canvas[i + 1] = {
    --     action = "fill",
    --     type = "rectangle",
    --     compositeRule = "sourceOut",
    --     fillColor = {alpha = barBackgroundAlpha},
    --     frame = {
    --       x = x * (barWidth + gridSpacing) + gridSpacing,
    --       y = y - maxBarHeight,
    --       w = barWidth,
    --       h = maxBarHeight
    --     }
    --   }
    -- end

    canvasFrameItems = #canvas
  end

  for i = 1, numberOfCores do
    local barHeight = math.max((maxBarHeight * (data[i].active / 100)), 1)
    --local barHeight = math.max((maxBarHeight * (100 / 100)), 1)

    local y = imageHeight - gridSpacing
    local x = i - 1
    if i <= numberOfCores / 2 then
      y = y / 2
    elseif i > numberOfCores / 2 then
      x = x - (numberOfCores / 2)
    end

    canvas[i + canvasFrameItems] = {
      action = "fill",
      type = "rectangle",
      compositeRule = barAlpha < frameAlpha and (data[i].active == 0.0 and "destinationOut" or "sourceOut") or "sourceOver",
      fillColor = {alpha = data[i].active == 0.0 and .5 or barAlpha},
      frame = {
        x = x * (barWidth + gridSpacing) + gridSpacing,
        y = y - barHeight,
        w = barWidth,
        h = barHeight
      }
    }
  end

  menubar:setIcon(canvas:imageFromCanvas())
end

function query()
  hs.host.cpuUsage(1, update)
end

function changeUpdateFrequency(freq)
  updateFrequency = freq
  timer:stop()
  timer = hs.timer.doEvery(updateFrequency, query)
end

menubar:setMenu(
  function()
    return {
      {
        title = "Update Frequency",
        menu = {
          {
            title = "Very often (1s)",
            checked = updateFrequency == 1,
            fn = function()
              changeUpdateFrequency(1)
            end
          },
          {
            title = "Often (3s)",
            checked = updateFrequency == 3,
            fn = function()
              changeUpdateFrequency(3)
            end
          },
          {
            title = "Normally (5s)",
            checked = updateFrequency == 5,
            fn = function()
              changeUpdateFrequency(5)
            end
          }
        }
      },
      {
        title = "Open Activity Monitor",
        fn = function()
          hs.application.launchOrFocus("Activity Monitor")
        end
      }
    }
  end
)

query()
timer = hs.timer.doEvery(updateFrequency, query)
