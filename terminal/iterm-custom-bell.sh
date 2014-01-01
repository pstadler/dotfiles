#!/bin/bash

iterm_location=$(mdfind 'kMDItemContentType == "com.apple.application-bundle" && kMDItemFSName = "iTerm.app"')

if [ -z "$iterm_location" ]; then
	echo "iTerm.app not found."
	exit 1
fi

if [ -f "$iterm_location/Contents/Resources/bell.png-default" ]; then
	echo "Custom bell is already installed."
	exit 1
fi

mv "$iterm_location/Contents/Resources/bell.png" "$iterm_location/Contents/Resources/bell.png-default"
cp ./bell.png "$iterm_location/Contents/Resources/bell.png"

echo "Done. Restart iTerm to apply changes."
