#!/usr/bin/env bash
# Preview this site in the iOS Simulator.
#   ./ios-preview.sh                      # index-fancy.html on iPhone 17 Pro
#   ./ios-preview.sh index.html           # a different page
#   DEVICE="iPhone Air" ./ios-preview.sh  # a different device
set -euo pipefail

PAGE="${1:-index-fancy.html}"
DEVICE="${DEVICE:-iPhone 17 Pro}"
PORT="${PORT:-8090}"

# Xcode's simctl, in case xcode-select still points at CommandLineTools.
SIMCTL=/Applications/Xcode.app/Contents/Developer/usr/bin/simctl
SIMAPP=/Applications/Xcode.app/Contents/Developer/Applications/Simulator.app
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Serve the site unless something is already on $PORT.
if lsof -nP -iTCP:"$PORT" -sTCP:LISTEN >/dev/null 2>&1; then
  echo "Reusing server already on port $PORT"
else
  echo "Serving $ROOT on port $PORT"
  (cd "$ROOT" && nohup python3 -m http.server "$PORT" --bind 127.0.0.1 \
    > /tmp/ios-preview-server.log 2>&1 &)
  sleep 1
fi

"$SIMCTL" boot "$DEVICE" 2>/dev/null || true   # already-booted is fine
open -a "$SIMAPP"
"$SIMCTL" bootstatus "$DEVICE" -b >/dev/null 2>&1 || true

"$SIMCTL" openurl "$DEVICE" "http://127.0.0.1:$PORT/$PAGE"
echo "Opened http://127.0.0.1:$PORT/$PAGE on $DEVICE"
echo
echo "Screenshot:  $SIMCTL io '$DEVICE' screenshot shot.png"
echo "Stop server: kill \$(lsof -tiTCP:$PORT -sTCP:LISTEN)"
echo "Web Inspector: Safari on your Mac -> Develop -> Simulator -> the page"
