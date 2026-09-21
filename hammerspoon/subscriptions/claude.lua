-- Read Claude subscription usage using Claude Code's existing login.
-- The OAuth usage endpoint is internal and may change without notice.
local autoRefreshSeconds = 300
local common = require("subscriptions.common")
local M = {}
local menubar = hs.menubar.new():autosaveName("claude")
local task, timeout
local refreshing = false
local userAgent
local retryAt = 0
local rows = {}
local planName = "Claude"
local status = "Loading Claude usage…"
local displayedPercent, displayedReset
local refresh

-- Claude mark from Simple Icons; preserve Retina resolution.
local icon = hs.image.imageFromPath(hs.configdir .. "/subscriptions/claude.png")
if icon then menubar:setIcon(icon:setSize({w = 18, h = 18}), true) end
menubar:setTitle(" —"):setTooltip("Claude usage")

local function unavailable(message)
  displayedPercent, displayedReset = nil, nil
  rows = {}
  status = message
  menubar:setTitle(" —"):setTooltip("Claude: " .. message)
end

local function resetTimestamp(value)
  if type(value) ~= "string" then return nil end
  local year, month, day, hour, minute, second = value:match("^(%d%d%d%d)%-(%d%d)%-(%d%d)T(%d%d):(%d%d):(%d%d)")
  if not year then return nil end
  local localTime = os.time({year = tonumber(year), month = tonumber(month), day = tonumber(day),
    hour = tonumber(hour), min = tonumber(minute), sec = tonumber(second), isdst = false})
  local utc = os.date("!*t", localTime)
  utc.isdst = false
  local timestamp = localTime + os.difftime(localTime, os.time(utc))
  local sign, zoneHour, zoneMinute = value:match("([+-])(%d%d):(%d%d)$")
  if sign then
    local offset = tonumber(zoneHour) * 3600 + tonumber(zoneMinute) * 60
    timestamp = timestamp - (sign == "+" and offset or -offset)
  end
  return timestamp
end

local function display(result)
  rows = {}
  displayedPercent, displayedReset = nil, nil
  for _, entry in ipairs({{"five_hour", "5-hour"}, {"seven_day", "Weekly"},
    {"seven_day_sonnet", "Sonnet weekly"}, {"seven_day_opus", "Opus weekly"}}) do
    local window = result[entry[1]]
    if type(window) == "table" and type(window.utilization) == "number" then
      local remaining = math.max(0, math.min(100, 100 - window.utilization))
      local resetsAt = resetTimestamp(window.resets_at)
      if not displayedPercent or remaining < displayedPercent then
        displayedPercent, displayedReset = remaining, resetsAt
      end
      table.insert(rows, {title = string.format("%s: %.0f%% left", entry[2], remaining),
        image = common.usageBar(remaining, "#D97757"), resetsAt = resetsAt, disabled = true})
    end
  end
  local extra = result.extra_usage
  local spend = type(result.spend) == "table" and result.spend or {}
  local used, limit = spend.used, spend.limit
  if type(used) ~= "table" and type(extra) == "table" then
    used = {amount_minor = extra.used_credits, currency = extra.currency or "USD", exponent = extra.decimal_places or 2}
  end
  if type(limit) ~= "table" and type(extra) == "table" and type(extra.monthly_limit) == "number" then
    limit = {amount_minor = extra.monthly_limit, currency = extra.currency or "USD", exponent = extra.decimal_places or 2}
  end
  local spendText
  if type(used) == "table" and type(used.amount_minor) == "number"
    and type(used.exponent) == "number" and used.exponent >= 0 and used.exponent <= 6
    and used.exponent % 1 == 0 and type(used.currency) == "string" then
    local currency = used.currency:upper()
    local function formatMoney(minor)
      local amount = string.format("%." .. used.exponent .. "f", minor / 10 ^ used.exponent)
      return currency == "USD" and ("$" .. amount) or (currency .. " " .. amount)
    end
    spendText = formatMoney(used.amount_minor)
    if type(limit) == "table" and type(limit.amount_minor) == "number" and limit.amount_minor >= 0
      and limit.exponent == used.exponent and type(limit.currency) == "string" and limit.currency:upper() == currency then
      local remaining = limit.amount_minor > 0 and math.max(0, math.min(100, 100 * (1 - used.amount_minor / limit.amount_minor))) or 0
      -- Claude Code's monthly usage-credit reset is the first day of the next local month.
      local now = os.date("*t")
      local resetsAt = os.time({year = now.year, month = now.month + 1, day = 1, hour = 0, min = 0, sec = 0})
      table.insert(rows, {title = string.format("%.0f%% left", remaining),
        image = common.usageBar(remaining, "#D97757"), disabled = true})
      table.insert(rows, {title = spendText .. " / " .. formatMoney(limit.amount_minor) .. " spent",
        resetsAt = resetsAt, disabled = true})
      if not displayedPercent then displayedPercent, displayedReset = remaining, resetsAt end
    else
      table.insert(rows, {title = "Spend: " .. spendText, disabled = true})
      table.insert(rows, {title = "No spending limit reported", disabled = true})
    end
  end
  if not displayedPercent and not spendText then unavailable("Claude allowance unavailable"); return end
  if type(extra) == "table" and type(extra.is_enabled) == "boolean" then
    table.insert(rows, {title = extra.is_enabled and "Extra usage enabled" or "Extra usage disabled", disabled = true})
  end
  status = "Updated " .. os.date("%H:%M")
  if displayedPercent then
    menubar:setTooltip("Claude usage")
    common.updateTitle(menubar, displayedPercent, displayedReset)
  else
    menubar:setTitle(spendText):setTooltip("Claude spend: " .. spendText)
  end
end

local function decodeCredentials(raw)
  local ok, result = pcall(hs.json.decode, raw)
  local oauth = ok and type(result) == "table" and result.claudeAiOauth
  if type(oauth) == "table" and type(oauth.accessToken) == "string" and oauth.accessToken ~= "" then
    return oauth
  end
end

local function fileCredentials()
  local directory = os.getenv("CLAUDE_CONFIG_DIR") or (os.getenv("HOME") .. "/.claude")
  local file = io.open(directory .. "/.credentials.json", "r")
  if not file then return nil end
  local raw = file:read("*a")
  file:close()
  return decodeCredentials(raw)
end

refresh = function()
  if refreshing or os.time() < retryAt then return end
  refreshing = true
  local finished = false
  local function finish(result, message)
    if finished then return end
    finished, refreshing = true, false
    if timeout then timeout:stop(); timeout = nil end
    if task then task:terminate(); task = nil end
    if result then
      display(result)
    elseif #rows > 0 then
      status = message .. " (showing last reading)"
      menubar:setTooltip("Claude: " .. status)
    else
      unavailable(message)
    end
  end

  local function requestUsage(credentials)
    if finished then return end
    if not credentials then finish(nil, "Claude Code credentials unavailable; sign in with claude"); return end
    -- Claude Code owns token refresh; never overwrite its credentials here.
    if type(credentials.expiresAt) == "number" and credentials.expiresAt <= os.time() * 1000 then
      finish(nil, "Claude login expired; open Claude Code to refresh it")
      return
    end
    local plans = {pro = "Pro", max = "Max", team = "Team", enterprise = "Enterprise"}
    local plan = plans[credentials.subscriptionType]
    planName = plan and ("Claude " .. plan) or "Claude"
    hs.http.asyncGet("https://api.anthropic.com/api/oauth/usage", {
      ["Authorization"] = "Bearer " .. credentials.accessToken,
      ["anthropic-beta"] = "oauth-2025-04-20",
      ["User-Agent"] = userAgent,
      ["Cache-Control"] = "no-cache",
      ["Content-Type"] = "application/json",
      ["Accept"] = "application/json"
    }, function(code, body, headers)
      if finished then return end
      if code == 401 or code == 403 then
        finish(nil, "Could not read Claude usage; check Claude Code login")
      elseif code == 429 then
        local delay = autoRefreshSeconds
        for name, value in pairs(headers or {}) do
          if name:lower() == "retry-after" then delay = math.max(delay, tonumber(value) or 0) end
        end
        retryAt = os.time() + delay
        finish(nil, "Usage request throttled; retry after " .. os.date("%H:%M", retryAt))
      elseif code ~= 200 then
        finish(nil, "Could not read Claude usage; check connection")
      else
        local ok, result = pcall(hs.json.decode, body)
        if ok and type(result) == "table" then finish(result)
        else finish(nil, "Invalid Claude usage response") end
      end
    end)
  end

  timeout = hs.timer.doAfter(30, function() finish(nil, "Claude usage request timed out") end)
  local function readCredentials()
    task = hs.task.new("/usr/bin/security", function(code, stdout)
      if finished then return end
      task = nil
      requestUsage((code == 0 and decodeCredentials(stdout)) or fileCredentials())
    end, {"find-generic-password", "-s", "Claude Code-credentials", "-w"})
    if not task or not task:start() then
      task = nil
      requestUsage(fileCredentials())
    end
  end
  if userAgent then readCredentials(); return end
  local path = common.findExecutable("claudePath", {"/opt/homebrew/bin/claude", "/usr/local/bin/claude",
    os.getenv("HOME") .. "/.local/bin/claude"})
  if not path then finish(nil, "Claude Code CLI not found; set hs.settings claudePath"); return end
  task = hs.task.new(path, function(code, stdout)
    if finished then return end
    task = nil
    local version = code == 0 and stdout:match("^(%d+%.%d+%.%d+)")
    if not version then finish(nil, "Could not read Claude Code version"); return end
    userAgent = "claude-code/" .. version
    readCredentials()
  end, {"--version"})
  if not task or not task:start() then
    finish(nil, "Could not start Claude Code version reader")
  end
end

menubar:setMenu(function()
  local menu = {{title = planName, disabled = true}}
  for _, row in ipairs(rows) do
    table.insert(menu, {title = row.title, image = row.image, disabled = true})
    if row.resetsAt then
      local date = os.date("%a %b %d, %H:%M", row.resetsAt):gsub(" 0", " ")
      local countdown = common.resetText(row.resetsAt):gsub("^resets in ", "in ")
      table.insert(menu, {title = "Resets " .. countdown .. " (" .. date .. ")", disabled = true})
    end
  end
  table.insert(menu, {title = "-"})
  table.insert(menu, {title = status, disabled = refreshing or os.time() < retryAt, fn = refresh})
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
