#!/bin/sh

if pgrep -f "playbgm.sh" >/dev/null; then
    killall -q "playbgm.sh" "mp3play"
fi

if pgrep -f "muplay" >/dev/null; then
    killall -q "muplay"
    rm "$SND_PIPE"
fi
echo app >/tmp/act_go

. /opt/muos/script/var/func.sh

. /opt/muos/script/var/device/device.sh
. /opt/muos/script/var/device/sdl.sh
. /opt/muos/script/var/device/storage.sh

GPTOKEYB_BIN=gptokeyb2
GPTOKEYB_DIR="$DC_STO_ROM_MOUNT/MUOS/emulator/gptokeyb"

export LD_LIBRARY_PATH=/usr/lib32
export SDL_GAMECONTROLLERCONFIG=$(grep "Deeplay" "$SDL_GAMECONTROLLER")

export HOME=/root

LGPT_DIR="$DC_STO_ROM_MOUNT/MUOS/application/.lgpt"

cd "$LGPT_DIR" || exit

echo "lgpt" >/tmp/fg_proc

SDL_ASSERT=always_ignore $GPTOKEYB_DIR/$GPTOKEYB_BIN "./lgpt" -c "./lgpt.gptk.$ANALOGSTICKS" &
./lgpt
sync
kill -9 "$(pidof lgpt)"
kill -9 "$(pidof gptokeyb2)"
