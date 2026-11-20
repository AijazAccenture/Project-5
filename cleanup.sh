#!/usr/bin/env bash
# =====================================================================
# Project 5: Secure Linux Server Permissions
# cleanup.sh - Removes users, groups and folders created by setup.sh
# Usage: sudo bash cleanup.sh
# =====================================================================

if [ "$EUID" -ne 0 ]; then
  echo "Please run with sudo: sudo bash cleanup.sh"
  exit 1
fi

echo "WARNING: This will DELETE users alice, bob, charlie (and their home folders),"
echo "         groups devteam, opsteam, and the folder /srv/project5."
read -r -p "Type YES to continue: " answer
if [ "$answer" != "YES" ]; then
  echo "Cancelled. Nothing was deleted."
  exit 0
fi

for u in alice bob charlie; do
  if id "$u" >/dev/null 2>&1; then
    userdel -r "$u" 2>/dev/null || userdel "$u"
    echo "Removed user $u"
  fi
done

for g in devteam opsteam; do
  if getent group "$g" >/dev/null; then
    groupdel "$g"
    echo "Removed group $g"
  fi
done

rm -rf /srv/project5
echo "Removed /srv/project5"
echo "Cleanup complete."
