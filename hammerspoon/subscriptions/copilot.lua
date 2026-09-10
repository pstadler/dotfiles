-- Read Copilot quotas using gh's existing login. The internal GitHub endpoint
-- is also used by Copilot clients, but is not a stable public API.
local autoRefreshSeconds = 300
local common = require("subscriptions.common")
local M = {}
local menubar = hs.menubar.new():autosaveName("copilot")
local task, timeout
local rows = {}
local planName = "Copilot"
local status = "Loading Copilot usage…"
local refresh
local displayedPercent, displayedReset

-- GitHub Primer Octicons Copilot mark; preserve Retina resolution.
local icon = hs.image.imageFromPath(hs.configdir .. "/subscriptions/copilot.png")
if icon then menubar:setIcon(icon:setSize({w = 18, h = 18}), true) end
menubar:setTitle(" —")

local function unavailable(message)
  displayedPercent, displayedReset = nil, nil
  rows = {}
  planName = "Copilot (plan unavailable)"
  status = message
  menubar:setTitle(" —"):setTooltip("Copilot: " .. message)
end

-- Convert an API UTC date without interpreting midnight as local time.
local function resetTimestamp(value)
  if type(value) ~= "string" then return nil end
  local year, month, day = value:match("^(%d%d%d%d)%-(%d%d)%-(%d%d)")
  if not year then return nil end
  local hour, minute, second = value:match("T(%d%d):(%d%d):(%d%d)")
  local localTime = os.time({year = tonumber(year), month = tonumber(month), day = tonumber(day),
    hour = tonumber(hour) or 0, min = tonumber(minute) or 0, sec = tonumber(second) or 0, isdst = false})
  local utc = os.date("!*t", localTime)
  utc.isdst = false
  return localTime + os.difftime(localTime, os.time(utc))
end

local function display(result)
  local quotas = result.quota_snapshots
  local premium = type(quotas) == "table" and quotas.premium_interactions
  if type(premium) ~= "table" or (premium.unlimited ~= true and type(premium.percent_remaining) ~= "number") then
    unavailable("Copilot allowance unavailable")
    return
  end
  local plans = {free = "Free", individual = "Pro", individual_pro = "Pro+",
    business = "Business", enterprise = "Enterprise"}
  planName = "Copilot " .. (plans[result.copilot_plan] or result.copilot_plan or "(plan unavailable)")
  displayedPercent = premium.unlimited and math.huge or math.max(0, math.min(100, premium.percent_remaining))
  displayedReset = type(premium.quota_reset_at) == "number" and premium.quota_reset_at > 0 and premium.quota_reset_at
    or resetTimestamp(result.quota_reset_date_utc or result.quota_reset_date)
  local barRemaining = displayedPercent == math.huge and 100 or displayedPercent
  rows = {{title = displayedPercent == math.huge and "Unlimited" or string.format("%.0f%% left", displayedPercent),
    image = common.usageBar(barRemaining, "#000000"), disabled = true}}

  local entitlement = premium.entitlement
  if premium.token_based_billing and type(premium.credits_used) == "number" and type(entitlement) == "number" then
    table.insert(rows, {title = string.format("%s / %s AI credits used", common.formatCount(premium.credits_used), common.formatCount(entitlement)), disabled = true})
  elseif not premium.unlimited and type(premium.remaining) == "number" and type(entitlement) == "number" then
    table.insert(rows, {title = string.format("%s / %s premium requests left", common.formatCount(math.max(0, premium.remaining)), common.formatCount(entitlement)), disabled = true})
  end
  if premium.overage_permitted ~= nil then
    table.insert(rows, {title = premium.overage_permitted and "Additional usage enabled" or "Additional usage disabled", disabled = true})
  end
  for _, entry in ipairs({{"chat", "Chat"}, {"completions", "Completions"}}) do
    local quota = quotas[entry[1]]
    if type(quota) == "table" and quota.unlimited then
      table.insert(rows, {title = entry[2] .. ": unlimited", disabled = true})
    end
  end
  status = "Updated " .. os.date("%H:%M")
  common.updateTitle(menubar, displayedPercent, displayedReset)
end

local function ghPath()
  return common.findExecutable("ghPath", {"/opt/homebrew/bin/gh", "/usr/local/bin/gh", os.getenv("HOME") .. "/.local/bin/gh"})
end

refresh = function()
  if task then return end
  local path = ghPath()
  if not path then unavailable("GitHub CLI not found; set hs.settings ghPath"); return end
  local timedOut = false
  task = hs.task.new(path, function(code, stdout)
    if timeout then timeout:stop(); timeout = nil end
    task = nil
    if timedOut then return end
    if code ~= 0 then unavailable("Could not read Copilot usage; check gh login or connection"); return end
    local ok, result = pcall(hs.json.decode, stdout)
    if ok and type(result) == "table" then display(result) else unavailable("Invalid Copilot usage response") end
  end, {"api", "--hostname", "github.com", "/copilot_internal/user", "--jq",
    "{copilot_plan, quota_reset_date, quota_reset_date_utc, quota_snapshots}"})
  if not task then unavailable("Could not create Copilot usage reader"); return end
  if not task:start() then task = nil; unavailable("Could not start GitHub CLI"); return end
  timeout = hs.timer.doAfter(30, function()
    timedOut = true
    unavailable("Copilot usage request timed out")
    if task then task:terminate() end
  end)
end

menubar:setMenu(function()
  local menu = {{title = planName, disabled = true}}
  for _, row in ipairs(rows) do table.insert(menu, row) end
  if displayedReset then
    local date = os.date("%a %b %d", displayedReset):gsub(" 0", " ")
    local countdown = common.resetText(displayedReset):gsub("^resets in ", "in ")
    table.insert(menu, {title = "Resets " .. countdown .. " (" .. date .. ")", disabled = true})
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
