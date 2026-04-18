#!/usr/bin/env bash
set -euo pipefail
# shellcheck source=helpers.sh
source "$(dirname "$0")/_helpers.sh"

out=$("$BINARY" testdata/noop.json)

assert_contains     "heading"            "## Terraform Plan"                            "$out"
assert_contains     "no changes message" "✅ No changes — infrastructure is up to date." "$out"
assert_not_contains "no table header"    "| Action |"                                   "$out"
assert_not_contains "no resource row"    "aws_instance.web"                             "$out"

summarise
