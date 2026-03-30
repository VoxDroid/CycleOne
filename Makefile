# Makefile

.PHONY: lint format test clean build

lint:
	swiftlint lint --config .swiftlint.yml

lint-fix:
	swiftlint --fix --config .swiftlint.yml

format:
	swiftformat . --config .swiftformat

check: lint format test test-ui

test:
	rm -rf TestResults.xcresult
	# Ensure simulator and DerivedData are in a clean state to avoid preflight failures
	xcrun simctl shutdown all || true
	killall -9 com.apple.CoreSimulator.CoreSimulatorService 2>/dev/null || true
	rm -rf ~/Library/Developer/Xcode/DerivedData/CycleOne-* || true
	# Build/run tests using a local derived data folder to avoid networked/remote path issues
	xcodebuild test \
		-project CycleOne.xcodeproj \
		-scheme CycleOne \
		-destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
		-parallel-testing-enabled NO \
		-derivedDataPath build/deriveddata \
		-resultBundlePath TestResults.xcresult

test-ui:
	# Run UI tests with a clean simulator state and local derived data
	xcrun simctl shutdown all || true
	killall -9 com.apple.CoreSimulator.CoreSimulatorService 2>/dev/null || true
	rm -rf ~/Library/Developer/Xcode/DerivedData/CycleOne-* || true
	xcodebuild test \
		-project CycleOne.xcodeproj \
		-scheme CycleOneUITests \
		-destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
		-parallel-testing-enabled NO \
		-derivedDataPath build/deriveddata

clean:
	rm -rf build/
	rm -rf TestResults.xcresult
	rm -rf DerivedData/
