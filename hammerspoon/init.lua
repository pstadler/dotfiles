mash = {
  position = {"ctrl", "alt", "cmd"},
  focus    = {"ctrl", "alt"},
  utils    = {"ctrl", "alt", "cmd"}
}

require('setup')

require('position')
require('focus')
require('spaces')
require('caffeinate.caffeinate')
require('wifi')
require('cpu')
require('subscriptions.openai')
require('subscriptions.copilot')

--hs.alert.show("Hammerspoon!")
