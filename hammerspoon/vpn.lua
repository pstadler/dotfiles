-- avoid garbage collection of timers
timers = {}

local function menuItemForRunningProcess(processName, menuItemLabel, checkIntervalSeconds, clickCallback)
  local menubar

  local function checkProcess()
    local output = hs.execute("pgrep -x " .. processName)
    if output == "" then
      if menubar and menubar:isInMenuBar() then
        menubar:delete()
      end
    elseif not (menubar and menubar:isInMenuBar()) then
      menubar = hs.menubar.new():setTitle(menuItemLabel)
      menubar:setClickCallback(function()
        if clickCallback then
          clickCallback()
        end
        checkProcess()
      end)
    end
  end

  table.insert(timers, hs.timer.new(checkIntervalSeconds, checkProcess, true):start())

  checkProcess()
end

menuItemForRunningProcess("openconnect", "VPN", 5, function()
  hs.execute([[osascript -e 'do shell script "sudo pkill openconnect" with administrator privileges']])
end)