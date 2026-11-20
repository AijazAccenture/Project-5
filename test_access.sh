#!/usr/bin/env bash
# =====================================================================
# Project 5: Secure Linux Server Permissions
# test_access.sh - Automatically tests ALLOWED and DENIED access.
# Usage: sudo bash test_access.sh
# =====================================================================

if [ "$EUID" -ne 0 ]; then
  echo "Please run with sudo: sudo bash test_access.sh"
  exit 1
fi

BASE=/srv/project5
PASS=0
FAIL=0

# Run a command as a user and EXPECT it to succeed
expect_allow() {
  local desc="$1" user="$2"; shift 2
  if sudo -u "$user" "$@" >/dev/null 2>&1; then
    echo "  PASS  [ALLOWED as expected] $desc"; PASS=$((PASS+1))
  else
    echo "  FAIL  [should be ALLOWED]   $desc"; FAIL=$((FAIL+1))
  fi
}

# Run a command as a user and EXPECT it to be blocked
expect_deny() {
  local desc="$1" user="$2"; shift 2
  if sudo -u "$user" "$@" >/dev/null 2>&1; then
    echo "  FAIL  [should be DENIED]    $desc"; FAIL=$((FAIL+1))
  else
    echo "  PASS  [DENIED as expected]  $desc"; PASS=$((PASS+1))
  fi
}

echo "=============================================="
echo " Project 5 - Access Control Test Report"
echo " Host: $(hostname)   Date: $(date)"
echo "=============================================="

echo
echo "--- ALLOWED access tests ---"
expect_allow "alice (devteam) can list dev"             alice   ls "$BASE/dev"
expect_allow "alice (devteam) can create a file in dev" alice   touch "$BASE/dev/test_alice.tmp"
expect_allow "bob (devteam) can read alice's file"      bob     cat "$BASE/dev/test_alice.tmp"
expect_allow "charlie (opsteam) can create file in ops" charlie touch "$BASE/ops/test_charlie.tmp"
expect_allow "charlie (opsteam) can write to shared"    charlie touch "$BASE/shared/test_shared.tmp"
expect_allow "alice can list shared (read-only)"        alice   ls "$BASE/shared"
expect_allow "bob can read a file in shared"            bob     cat "$BASE/shared/test_shared.tmp"

echo
echo "--- DENIED access tests ---"
expect_deny  "alice (devteam) cannot list ops"           alice   ls "$BASE/ops"
expect_deny  "alice (devteam) cannot create file in ops" alice   touch "$BASE/ops/hack.tmp"
expect_deny  "charlie (opsteam) cannot list dev"         charlie ls "$BASE/dev"
expect_deny  "charlie (opsteam) cannot read dev files"   charlie cat "$BASE/dev/test_alice.tmp"
expect_deny  "alice cannot create a file in shared"      alice   touch "$BASE/shared/hack.tmp"
expect_deny  "alice cannot modify a file in shared"      alice   sh -c "echo hack >> $BASE/shared/test_shared.tmp"
expect_deny  "bob cannot delete a file in shared"        bob     rm -f "$BASE/shared/test_shared.tmp"
expect_deny  "nobody (outsider) cannot list dev"         nobody  ls "$BASE/dev"
expect_deny  "nobody (outsider) cannot list ops"         nobody  ls "$BASE/ops"

# Clean up temporary test files
rm -f "$BASE/dev/test_alice.tmp" "$BASE/ops/test_charlie.tmp" "$BASE/shared/test_shared.tmp"

echo
echo "=============================================="
echo " RESULT: $PASS passed, $FAIL failed (total $((PASS+FAIL)))"
echo "=============================================="

[ "$FAIL" -eq 0 ]
