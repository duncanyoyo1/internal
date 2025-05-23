#!/bin/sh
# HELP: Clear System Cache
# ICON: clear

. /opt/muos/script/var/func.sh

FRONTEND stop

MUOS_CACHE_DIR="$(GET_VAR "device" "storage/rom/mount")/MUOS/info/cache"

echo "Clearing all cache"
rm -rf "$MUOS_CACHE_DIR"/mmc/* "$MUOS_CACHE_DIR"/sdcard/* "$MUOS_CACHE_DIR"/usb/*

echo "Sync Filesystem"
sync

echo "All Done!"
/opt/muos/bin/toybox sleep 2

FRONTEND start task
exit 0
