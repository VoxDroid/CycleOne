# Coverage percentage commands (target-level)

# 1) Generate a fresh coverage bundle
make test

# 2) Show coverage % for every target in TestResults.xcresult
xcrun xccov view --report --json TestResults.xcresult \
  | jq -r '.targets[] | "\(.name): \((.lineCoverage * 100) | tostring)% (\(.coveredLines)/\(.executableLines))"'

# 3) Show only the main project targets
xcrun xccov view --report --json TestResults.xcresult \
  | jq -r '.targets[]
    | select(.name == "CycleOne.app" or .name == "CycleOneTests.xctest" or .name == "CycleOneUITests.xctest")
    | "\(.name): \((.lineCoverage * 100) | tostring)% (\(.coveredLines)/\(.executableLines))"'

# 4) Enforce minimum target percentage (example: 100)
MIN_PERCENT=100
xcrun xccov view --report --json TestResults.xcresult \
  | jq -e --argjson min "$MIN_PERCENT" '
    .targets
    | map(select(.name == "CycleOne.app" or .name == "CycleOneTests.xctest" or .name == "CycleOneUITests.xctest"))
    | all((.lineCoverage * 100) >= $min)
  '

# jq exits 0 when all targets meet the threshold, non-zero otherwise.
