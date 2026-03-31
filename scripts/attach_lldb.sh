#!/usr/bin/env bash
set -euo pipefail

SIM_NAME="iPhone 17 Pro"
DEST="platform=iOS Simulator,name=${SIM_NAME}"
ONLY_TEST="-only-testing:CycleOneTests/NotificationServiceTests/testCancelAll_callsRemoveAll"
XCODEBUILD_LOG="xcodebuild_test.log"

# Ensure simulators are reset
xcrun simctl shutdown all || true

# Remove previous result bundle
rm -rf TestResults.xcresult

# Start xcodebuild test in background and log output
echo "Starting xcodebuild test (only: ${ONLY_TEST})..."
xcodebuild test -project CycleOne.xcodeproj -scheme CycleOne -destination "${DEST}" -parallel-testing-enabled NO -derivedDataPath build/deriveddata -resultBundlePath TestResults.xcresult "${ONLY_TEST}" > "${XCODEBUILD_LOG}" 2>&1 &
XCODEBUILD_PID=$!
echo "xcodebuild pid ${XCODEBUILD_PID}"

# Wait up to ~60s for the app process to appear
APP_PID=""
for i in $(seq 1 120); do
  APP_PID=$(pgrep -x CycleOne || true)
  if [[ -n "${APP_PID}" ]]; then
    echo "Found CycleOne pid: ${APP_PID}"
    break
  fi
  sleep 0.5
done

if [[ -z "${APP_PID}" ]]; then
  echo "App pid not found; printing xcodebuild log for debugging:"
  tail -n +1 "${XCODEBUILD_LOG}"
  wait "${XCODEBUILD_PID}"
  exit 1
fi

# Attach lldb, set breakpoint on malloc_error_break, continue, print backtrace when hit
echo "Attaching lldb to pid ${APP_PID} and setting breakpoint on malloc_error_break"

lldb -p "${APP_PID}" -o "break set -n malloc_error_break" -o "process continue" -o "bt" -o "quit"

# Wait for xcodebuild to finish
wait "${XCODEBUILD_PID}"

echo "xcodebuild finished; check TestResults.xcresult and ${XCODEBUILD_LOG}"
