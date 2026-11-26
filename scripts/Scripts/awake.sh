#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Keep Mac Awake
# @raycast.mode silent

# Optional parameters:
# @raycast.icon ☕
# @raycast.packageName Mac Utilities

osascript <<'APPLESCRIPT'
tell application "iTerm"
    activate
    create window with default profile
    tell current session of current window
        write text "caffeinate -disu"
    end tell
end tell
APPLESCRIPT
