-- Reconnect to current Wifi
function ssidChangedCallback()
    local ssid = hs.wifi.currentNetwork()
    if ssid then
      hs.alert.show("Network connected: " .. ssid)
    end
end

hs.wifi.watcher.new(ssidChangedCallback):start()

hs.hotkey.bind(mash.utils, "r", function()
  local ssid = hs.wifi.currentNetwork()
  if not ssid then return end

  hs.alert.show("Reconnecting to: " .. ssid)
  hs.execute("networksetup -setairportpower en0 off")
  hs.execute("networksetup -setairportpower en0 on")
end)
