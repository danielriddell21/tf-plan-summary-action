#!/usr/bin/env bash
set -euo pipefail
# shellcheck source=helpers.sh
source "$(dirname "$0")/_helpers.sh"

out=$("$BINARY" testdata/changes.json)

assert_contains     "heading"            "## Terraform Plan"                        "$out"
assert_contains     "plan line"          "Plan: 2 to add, 1 to change, 1 to destroy, 0 to replace." "$out"
assert_contains     "create instance"    "# aws_instance.web will be created"       "$out"
assert_contains     "create sg"          "# aws_security_group.web will be created" "$out"
assert_contains     "update s3"          "# aws_s3_bucket.assets will be updated in-place" "$out"
assert_contains     "delete legacy"      "# aws_instance.legacy will be destroyed"  "$out"
assert_not_contains "no-op excluded"     "aws_cloudwatch_log_group"                 "$out"

# The title and the plan line sit outside the ```diff``` code block.
title_line=$(printf '%s\n' "$out" | grep -n '## Terraform Plan' | head -1 | cut -d: -f1)
fence_line=$(printf '%s\n' "$out" | grep -n '```diff' | head -1 | cut -d: -f1)
close_line=$(printf '%s\n' "$out" | grep -n '^```$' | head -1 | cut -d: -f1)
plan_line=$(printf '%s\n' "$out" | grep -n 'Plan: 2 to add' | head -1 | cut -d: -f1)

if [ "$title_line" -lt "$fence_line" ]; then
    printf '  pass: %s\n' "title above diff block"; ((PASS++)) || true
else
    printf '  FAIL: %s\n' "title above diff block"; ((FAIL++)) || true
fi
if [ "$plan_line" -gt "$close_line" ]; then
    printf '  pass: %s\n' "plan line below diff block"; ((PASS++)) || true
else
    printf '  FAIL: %s\n' "plan line below diff block"; ((FAIL++)) || true
fi

summarise
