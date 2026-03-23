# Makefile

.PHONY: lint format test clean build

lint:
	swiftlint lint --config .swiftlint.yml

lint-fix:
	swiftlint --fix --config .swiftlint.yml

format:
	swiftformat . --config .swiftformat

check: format lint

test:
	rm -rf TestResults.xcresult
	xcodebuild test \
		-project CycleOne.xcodeproj \
		-scheme CycleOne \
		-destination 'platform=iOS Simulator,name=iPhone 16e,OS=latest' \
		-resultBundlePath TestResults.xcresult

clean:
	rm -rf build/
	rm -rf TestResults.xcresult
	rm -rf DerivedData/
