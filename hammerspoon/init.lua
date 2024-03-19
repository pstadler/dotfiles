mash = {
  position = {"ctrl", "alt", "cmd"},
  focus    = {"ctrl", "alt"},
  utils    = {"ctrl", "alt", "cmd"}
}

require('setup')

require('position')
require('focus')
require('spaces')
require('caffeinate')
require('wifi')
require('battery')
require('cpu')

hs.alert.show("Hammerspoon!")