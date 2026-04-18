#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

export BINARY=/tmp/tf-plan-summary-test
go build -o "$BINARY" .

# Save and clear so test assertions capture stdout instead of the summary file
SUMMARY="${GITHUB_STEP_SUMMARY:-}"
unset GITHUB_STEP_SUMMARY

FAILED=0
for t in tests/[!_]*.sh; do
    echo "=== $t ==="
    bash "$t" || FAILED=1
    echo ""
done

# Write rendered examples to the job summary for visual inspection in CI
if [ -n "$SUMMARY" ]; then
    echo "## Example: changes plan" >> "$SUMMARY"
    echo "" >> "$SUMMARY"
    GITHUB_STEP_SUMMARY="$SUMMARY" "$BINARY" testdata/changes.json

    echo "" >> "$SUMMARY"
    echo "---" >> "$SUMMARY"
    echo "" >> "$SUMMARY"
    echo "## Example: noop plan" >> "$SUMMARY"
    echo "" >> "$SUMMARY"
    GITHUB_STEP_SUMMARY="$SUMMARY" "$BINARY" testdata/noop.json
fi

rm -f "$BINARY"
[ "$FAILED" -eq 0 ]
