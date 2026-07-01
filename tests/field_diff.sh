#!/usr/bin/env bash
set -euo pipefail
# shellcheck source=helpers.sh
source "$(dirname "$0")/_helpers.sh"

out=$("$BINARY" testdata/changes.json)

assert_contains     "preamble title"           "Terraform will perform the following actions:"       "$out"
assert_contains     "diff fence"               '```diff'                                             "$out"
assert_contains     "create header"            "# aws_instance.web will be created"                  "$out"
assert_contains     "create resource block"    'resource "aws_instance" "web" {'                     "$out"
assert_contains     "known after apply"        "= (known after apply)"                               "$out"
assert_contains     "update header"            "# aws_s3_bucket.assets will be updated in-place"     "$out"
assert_contains     "update uses bang marker"  '!   resource "aws_s3_bucket" "assets" {'             "$out"
assert_contains     "nested block"             "versioning {"                                        "$out"
assert_contains     "field transition"         "enabled = false -> true"                             "$out"
assert_contains     "unchanged hidden"         "unchanged attribute hidden)"                         "$out"
assert_contains     "destroy header"           "# aws_instance.legacy will be destroyed"             "$out"
assert_contains     "removed field"            'ami           = "ami-old" -> null'                   "$out"

out=$("$BINARY" testdata/noop.json)

assert_not_contains "no diff on noop"          '```diff'                                             "$out"

summarise
