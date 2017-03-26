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
    message = "Charging:"

    if untilFull == -1 then
      message = string.format("%s %.0f%% (calculating...)", message, pct);
    else
      local watts = hs.battery.watts()
      message = string.format("%s %.0f%% (%s remaining @ %.1fW)", message, pct, minutesToHours(untilFull), watts)
    end
  elseif hs.battery.powerSource() == "Battery Power" then
    local pct = hs.battery.percentage()
    local untilEmpty = hs.battery.timeRemaining()
    message = "Battery:"

    if untilEmpty == -1 then
      message = string.format("%s %.0f%% (calculating...)", message, pct)
    else
      local watts = hs.battery.watts()
      message = string.format("%s %.0f%% (%s remaining @ %.1fW)", message, pct, minutesToHours(untilEmpty), watts)
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
