PASS=0
FAIL=0

assert_contains() {
    local desc="$1" expected="$2" actual="$3"
    if printf '%s' "$actual" | grep -qF -- "$expected"; then
        printf '  pass: %s\n' "$desc"
        ((PASS++)) || true
    else
        printf '  FAIL: %s\n' "$desc"
        printf '    expected to find: %s\n' "$expected"
        printf '    in output:\n%s\n' "$actual"
        ((FAIL++)) || true
    fi
}

assert_not_contains() {
    local desc="$1" unexpected="$2" actual="$3"
    if ! printf '%s' "$actual" | grep -qF "$unexpected"; then
        printf '  pass: %s\n' "$desc"
        ((PASS++)) || true
    else
        printf '  FAIL: %s\n' "$desc"
        printf '    did not expect to find: %s\n' "$unexpected"
        printf '    in output:\n%s\n' "$actual"
        ((FAIL++)) || true
    fi
}

summarise() {
    printf '%d passed, %d failed\n' "$PASS" "$FAIL"
    [ "$FAIL" -eq 0 ]
}
