#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

export BINARY=/tmp/tf-plan-summary-test
go build -o "$BINARY" .

FAILED=0
for t in tests/[!_]*.sh; do
    echo "=== $t ==="
    bash "$t" || FAILED=1
    echo ""
done

rm -f "$BINARY"
[ "$FAILED" -eq 0 ]
