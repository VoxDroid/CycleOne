# Coverage commands (split schemes + merged report)

# 1) Run unit tests with coverage output
xcodebuild test \
  -project CycleOne.xcodeproj \
  -scheme CycleOne-Unit \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -parallel-testing-enabled YES \
  -derivedDataPath build/deriveddata \
  -enableCodeCoverage YES \
  -resultBundlePath UnitCoverage.xcresult

# 2) Run UI tests with coverage output
xcodebuild test \
  -project CycleOne.xcodeproj \
  -scheme CycleOne-UI \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -parallel-testing-enabled YES \
  -derivedDataPath build/deriveddata \
  -enableCodeCoverage YES \
  -resultBundlePath UICoverage.xcresult

# 3) Export coverage payloads and merge unit + UI reports
rm -rf coverage_export
mkdir -p coverage_export/unit coverage_export/ui coverage_export/merged

xcrun xcresulttool export coverage --path UnitCoverage.xcresult --output-path coverage_export/unit
xcrun xcresulttool export coverage --path UICoverage.xcresult --output-path coverage_export/ui

xcrun xccov merge \
  --outReport coverage_export/merged/merged.xccovreport \
  --outArchive coverage_export/merged/merged.xccovarchive \
  'coverage_export/unit/0_Test_iPhone 17 Pro_CoverageReport' \
  'coverage_export/unit/0_Test_iPhone 17 Pro_CoverageArchive' \
  'coverage_export/ui/0_Test_iPhone 17 Pro_CoverageReport' \
  'coverage_export/ui/0_Test_iPhone 17 Pro_CoverageArchive'

# 4) Show merged target coverage percentages
xcrun xccov view --report --json coverage_export/merged/merged.xccovreport \
  | jq -r '.targets[] | "\(.name): \(((.lineCoverage * 100) | tostring))% (\(.coveredLines)/\(.executableLines))"'

# 5) Enforce 100% for app target
xcrun xccov view --report --json coverage_export/merged/merged.xccovreport \
  | jq -e '.targets[] | select(.name == "CycleOne.app") | (.coveredLines == .executableLines)'

# 6) Run localization integrity checks (unit scheme)
DEST_ID=$(xcrun simctl list devices available | awk -F '[()]' '/iPhone/ {print $2; exit}')
if [ -z "$DEST_ID" ]; then echo "No available iPhone simulator found."; exit 1; fi

xcodebuild test -project CycleOne.xcodeproj -scheme CycleOne-Unit -destination "id=${DEST_ID}" \
  -parallel-testing-enabled NO \
  -only-testing:CycleOneTests/LocalizationCoverageTests \
  -only-testing:CycleOneTests/AppLanguageTests
