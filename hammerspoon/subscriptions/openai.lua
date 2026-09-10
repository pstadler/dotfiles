-- Read subscription limits through the Codex CLI's authenticated app server.
--
local autoRefreshSeconds = 300
local common = require("subscriptions.common")
local M = {}
local menubar = hs.menubar.new():autosaveName("codex")
local task, timeout
local rows = {}
local planName = "Codex"
local status = "Loading Codex usage…"
local refresh
local displayedPercent, displayedReset

-- OpenAI template icon from the ChatGPT macOS app; retain its Retina resolution.
local icon = hs.image.imageFromPath(hs.configdir .. "/subscriptions/openai.png")
if icon then menubar:setIcon(icon:setSize({w = 18, h = 18}), true) end
menubar:setTitle(" —")

local function unavailable(message)
  displayedPercent, displayedReset = nil, nil
  rows = {}
  planName = "Codex (plan unavailable)"
  status = message
  menubar:setTitle(" —"):setTooltip("Codex: " .. message)
end

local function display(result)
  local buckets = result.rateLimitsByLimitId
  local limits = type(buckets) == "table" and buckets.codex or result.rateLimits
  if type(limits) ~= "table" then
    unavailable("Subscription usage unavailable")
    return
  end

  local plans = {
    free = "Free", go = "Go", plus = "Plus", pro = "Pro", prolite = "Pro Lite",
    team = "Team", business = "Business", enterprise = "Enterprise", edu = "Edu",
    edu_plus = "Edu Plus", edu_pro = "Edu Pro",
    self_serve_business_prolite = "Business Pro Lite",
    self_serve_business_usage_based = "Business Usage Based"
  }
  local plan = plans[limits.planType]
  planName = plan and ("Codex " .. plan) or "Codex (plan unavailable)"

  rows = {}
  local remaining, remainingReset
  for _, key in ipairs({"primary", "secondary"}) do
    local window = limits[key]
    if type(window) == "table" and type(window.usedPercent) == "number" then
      local percent = math.max(0, math.min(100, 100 - window.usedPercent))
      if not remaining or percent < remaining then
        remaining, remainingReset = percent, window.resetsAt
      end
      local minutes = window.windowDurationMins
      local label = key == "primary" and "Primary window" or "Secondary window"
      if type(minutes) == "number" then
        if minutes == 10080 then
          label = "Weekly"
        elseif minutes % 60 == 0 then
          label = string.format("%d-hour", minutes / 60)
        else
          label = string.format("%d-minute", minutes)
        end
      end
      table.insert(rows, {
        title = minutes ~= 10080 and string.format("%s: %.0f%% left", label, percent) or nil,
        resetsAt = type(window.resetsAt) == "number" and window.resetsAt or nil,
        disabled = true
      })
      if minutes == 10080 then
        table.insert(rows, 1, {title = string.format("%.0f%% left", percent), image = common.usageBar(percent, "#10A37F"), disabled = true})
      end
    end
  end

  if not remaining then
    unavailable("No subscription usage windows returned")
    return
  end
  local resets = result.rateLimitResetCredits
  local count = type(resets) == "table" and resets.availableCount
  local resetTextValue = "N/A"
  if type(count) == "number" then
    resetTextValue = string.format("%d", count)
  end
  table.insert(rows, {title = "Usage limit resets: " .. resetTextValue, disabled = true})

  status = "Updated " .. os.date("%H:%M")
  displayedPercent, displayedReset = remaining, remainingReset
  common.updateTitle(menubar, displayedPercent, displayedReset)
end

local function codexPath()
  return common.findExecutable("codexPath", {"/opt/homebrew/bin/codex", "/usr/local/bin/codex", os.getenv("HOME") .. "/.local/bin/codex"})
end

refresh = function()
  if task then return end
  local path = codexPath()
  if not path then
    unavailable("Codex CLI not found; set hs.settings codexPath")
    return
  end

  local buffer, finished = "", false
  local function finish(result, message)
    if finished then return end
    finished = true
    if timeout then timeout:stop(); timeout = nil end
    if result then display(result) else unavailable(message) end
    if task then task:terminate() end
  end

  task = hs.task.new(path, function()
    if not finished then finish(nil, "Could not read usage; check Codex login") end
    task = nil
  end, function(_, stdout)
    buffer = buffer .. (stdout or "")
    while true do
      local newline = buffer:find("\n", 1, true)
      if not newline then break end
      local line = buffer:sub(1, newline - 1)
      buffer = buffer:sub(newline + 1)
      local ok, message = pcall(hs.json.decode, line)
      if ok and type(message) == "table" and not finished then
        if message.id == 1 then
          if message.error then
            finish(nil, "Could not initialize Codex usage reader")
          else
            task:setInput(hs.json.encode({method = "initialized"}) .. "\n" ..
              hs.json.encode({id = 2, method = "account/rateLimits/read"}) .. "\n")
          end
        elseif message.id == 2 then
          if type(message.result) == "table" then
            finish(message.result)
          else
            finish(nil, "Usage unavailable; check Codex login or connection")
          end
        end
      end
    end
    return true
  end, {"app-server", "--stdio"})

  if not task then
    unavailable("Could not create Codex usage reader")
    return
  end
  task:setWorkingDirectory(os.getenv("HOME"))
  task:setInput(hs.json.encode({
    id = 1, method = "initialize",
    params = {clientInfo = {name = "hammerspoon_usage", version = "1.0"}}
  }) .. "\n")
  if not task:start() then
    task = nil
    unavailable("Could not start Codex CLI")
    return
  end
  timeout = hs.timer.doAfter(30, function() finish(nil, "Usage request timed out") end)
end

menubar:setMenu(function()
  local menu = {{title = planName, disabled = true}}
  for _, row in ipairs(rows) do
    if row.resetsAt then
      if row.title then table.insert(menu, {title = row.title, disabled = true}) end
      local date = os.date("%a %b %d", row.resetsAt):gsub(" 0", " ")
      local countdown = common.resetText(row.resetsAt):gsub("^resets in ", "in ")
      table.insert(menu, {title = "Resets " .. countdown .. " (" .. date .. ")", disabled = true})
    elseif row.title then
      table.insert(menu, row)
    end
  end
  table.insert(menu, {title = "-"})
  table.insert(menu, {title = status, disabled = task ~= nil, fn = refresh})
  return menu
end)

M.menubar = menubar
M.refresh = refresh
M.timer = hs.timer.doEvery(autoRefreshSeconds, refresh)
M.countdownTimer = hs.timer.doEvery(60, function()
  common.updateTitle(menubar, displayedPercent, displayedReset)
end)
refresh()
return M
