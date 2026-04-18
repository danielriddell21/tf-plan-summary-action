#!/usr/bin/env bash
set -euo pipefail
# shellcheck source=helpers.sh
source "$(dirname "$0")/_helpers.sh"

if ! command -v unum &>/dev/null; then
    echo "  skip: unum not in PATH"
    exit 0
fi

out=$("$BINARY" testdata/changes.json)

assert_contains     "details block present"    "<details><summary>Field-level diff</summary>" "$out"
assert_contains     "create instance in diff"  "+ .aws_instance.web"                          "$out"
assert_contains     "create sg in diff"        "+ .aws_security_group.web"                    "$out"
assert_contains     "deleted resource"          "- .aws_instance.legacy"                       "$out"
assert_contains     "modified field"            "! .aws_s3_bucket.assets.versioning.enabled"   "$out"
assert_contains     "old to new value"         "false → true"                                  "$out"

out=$("$BINARY" testdata/noop.json)

assert_not_contains "no details on noop"       "<details>"                                    "$out"

summarise
