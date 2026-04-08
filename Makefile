# Makefile

.PHONY: lint lint-fix format check test test-ui test-reset clean build

SIM_DEST ?= platform=iOS Simulator,name=iPhone 17 Pro
DERIVED_DATA_PATH ?= build/deriveddata

lint:
	swiftlint lint --config .swiftlint.yml

lint-fix:
	swiftlint --fix --config .swiftlint.yml

format:
	swiftformat . --config .swiftformat

check: lint format test test-ui

test:
	rm -rf TestResults.xcresult
	# Keep simulator and derived data warm for faster incremental runs.
	xcodebuild test \
		-project CycleOne.xcodeproj \
		-scheme CycleOne-Unit \
		-destination '$(SIM_DEST)' \
		-parallel-testing-enabled YES \
		-derivedDataPath $(DERIVED_DATA_PATH) \
		-resultBundlePath TestResults.xcresult

test-ui:
	# Reuse build artifacts to avoid rebuilding the app from scratch.
	xcodebuild test \
		-project CycleOne.xcodeproj \
		-scheme CycleOne-UI \
		-destination '$(SIM_DEST)' \
		-parallel-testing-enabled YES \
		-derivedDataPath $(DERIVED_DATA_PATH)

test-reset:
	# Use only when simulator state is corrupted; this is intentionally expensive.
	xcrun simctl shutdown all || true
	killall -9 com.apple.CoreSimulator.CoreSimulatorService 2>/dev/null || true
	rm -rf ~/Library/Developer/Xcode/DerivedData/CycleOne-* || true
	rm -rf $(DERIVED_DATA_PATH) || true

clean:
	rm -rf build/
	rm -rf TestResults.xcresult
	rm -rf DerivedData/
