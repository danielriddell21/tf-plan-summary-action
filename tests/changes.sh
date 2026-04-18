#!/usr/bin/env bash
set -euo pipefail
# shellcheck source=helpers.sh
source "$(dirname "$0")/_helpers.sh"

out=$("$BINARY" testdata/changes.json)

assert_contains     "heading"            "## Terraform Plan"                        "$out"
assert_contains     "add count"          "2 to add"                                 "$out"
assert_contains     "change count"       "1 to change"                              "$out"
assert_contains     "destroy count"      "1 to destroy"                             "$out"
assert_contains     "replace count"      "0 to replace"                             "$out"
assert_contains     "create instance"    "➕ create | \`aws_instance.web\`"         "$out"
assert_contains     "create sg"          "➕ create | \`aws_security_group.web\`"   "$out"
assert_contains     "update s3"          "📝 update | \`aws_s3_bucket.assets\`"     "$out"
assert_contains     "delete legacy"      "🗑️ destroy | \`aws_instance.legacy\`"    "$out"
assert_not_contains "no-op excluded"     "aws_cloudwatch_log_group"                 "$out"

summarise
