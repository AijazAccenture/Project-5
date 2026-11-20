#!/usr/bin/env bash
# =====================================================================
# Project 5: Secure Linux Server Permissions
# setup.sh - Creates users, groups and team folders with permissions.
# Safe to run more than once (skips anything that already exists).
# Usage: sudo bash setup.sh
# =====================================================================
set -e

if [ "$EUID" -ne 0 ]; then
  echo "Please run with sudo: sudo bash setup.sh"
  exit 1
fi

BASE=/srv/project5

echo "== 1. Creating groups =="
for g in devteam opsteam; do
  if getent group "$g" >/dev/null; then
    echo "   group $g already exists - skipping"
  else
    groupadd "$g" && echo "   created group $g"
  fi
done

echo "== 2. Creating users =="
create_user() {
  local user="$1" group="$2"
  if id "$user" >/dev/null 2>&1; then
    echo "   user $user already exists - skipping"
  else
    useradd -m -s /bin/bash -G "$group" "$user" && echo "   created user $user in $group"
  fi
}
create_user alice   devteam
create_user bob     devteam
create_user charlie opsteam

echo "== 3. Creating folders =="
mkdir -p "$BASE/dev" "$BASE/ops" "$BASE/shared"

echo "== 4. Setting ownership =="
chown root:devteam "$BASE/dev"
chown root:opsteam "$BASE/ops"
chown root:opsteam "$BASE/shared"

echo "== 5. Setting permissions =="
chmod 2770 "$BASE/dev"     # devteam only, others locked out
chmod 2770 "$BASE/ops"     # opsteam only, others locked out
chmod 2775 "$BASE/shared"  # opsteam writes, everyone else read-only

echo "== 6. Result =="
id alice; id bob; id charlie
ls -ld "$BASE" "$BASE/dev" "$BASE/ops" "$BASE/shared"
echo "== Setup complete =="
