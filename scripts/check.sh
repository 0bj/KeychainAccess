#!/bin/zsh
# Builds the library for every platform, the tests and the Example app with warnings
# treated as errors, then runs the test suite on an iOS simulator.
#
# Usage: scripts/check.sh [simulator name]   (default: "iPhone 17 Pro")

set -euo pipefail

cd "${0:A:h}/.."

SIMULATOR="${1:-iPhone 17 Pro}"
DERIVED_DATA="$(mktemp -d)"
LOG="$DERIVED_DATA/xcodebuild.log"
STRICT=(SWIFT_TREAT_WARNINGS_AS_ERRORS=YES GCC_TREAT_WARNINGS_AS_ERRORS=YES)
trap 'rm -rf "$DERIVED_DATA"' EXIT

xcb() {
    local title="$1"; shift
    printf '%-24s' "$title"
    if xcodebuild -workspace KeychainAccess.xcworkspace -derivedDataPath "$DERIVED_DATA" "$@" "${STRICT[@]}" > "$LOG" 2>&1; then
        echo "ok"
    else
        echo "FAILED"
        grep -E "(error|warning):|' failed \(" "$LOG" | sort -u | head -20
        exit 1
    fi
}

printf '%-24s' "Build SwiftPM"
if swift build --scratch-path "$DERIVED_DATA/spm" -Xswiftc -warnings-as-errors > "$LOG" 2>&1; then
    echo "ok"
else
    echo "FAILED"
    grep -E "^/.*(error|warning):" "$LOG" | sort -u | head -20
    exit 1
fi

typeset -A platforms=(
    iOS          "generic/platform=iOS Simulator"
    tvOS         "generic/platform=tvOS Simulator"
    watchOS      "generic/platform=watchOS Simulator"
    macOS        "platform=macOS"
    "Mac Catalyst" "platform=macOS,variant=Mac Catalyst"
)
for name in iOS tvOS watchOS macOS "Mac Catalyst"; do
    xcb "Build $name" build -scheme KeychainAccess -destination "${platforms[$name]}" CODE_SIGNING_ALLOWED=NO
done

xcb "Build tests (tvOS)" build-for-testing -scheme KeychainAccessTests -destination "generic/platform=tvOS Simulator"
xcb "Build Example" build -scheme Example-iOS -destination "generic/platform=iOS Simulator" CODE_SIGNING_ALLOWED=NO

# The simulator grants the test host's keychain entitlements without a development team.
xcb "Test ($SIMULATOR)" test -scheme KeychainAccessTests \
    -destination "platform=iOS Simulator,name=$SIMULATOR" \
    -test-timeouts-enabled YES -default-test-execution-time-allowance 60 \
    CODE_SIGN_IDENTITY=- CODE_SIGN_STYLE=Manual
grep -E "Executed [0-9]+ tests" "$LOG" | tail -1
