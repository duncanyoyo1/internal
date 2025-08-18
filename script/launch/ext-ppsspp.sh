#!/bin/sh

. /opt/muos/script/var/func.sh

NAME=$1
CORE=$2
FILE=${3%/}

(
	LOG_INFO "$0" 0 "Content Launch" "DETAIL"
	LOG_INFO "$0" 0 "NAME" "$NAME"
	LOG_INFO "$0" 0 "CORE" "$CORE"
	LOG_INFO "$0" 0 "FILE" "$FILE"
) &

PPSSPP_DIR="$(GET_VAR "device" "storage/rom/mount")/MUOS/emulator/ppsspp"

HOME="$PPSSPP_DIR"
export HOME

XDG_CONFIG_HOME="$HOME/.config"
export XDG_CONFIG_HOME

SETUP_SDL_ENVIRONMENT modern

case "$(GET_VAR "device" "board/name")" in
	rg*)
		PPSSPP_DIR="${PPSSPP_DIR}/rg"

		sed -i '/^GraphicsBackend\|^FailedGraphicsBackends\|^DisabledGraphicsBackends/d' \
			"$PPSSPP_DIR/.config/ppsspp/PSP/SYSTEM/ppsspp.ini"

		rm -f "$PPSSPP_DIR/.config/ppsspp/PSP/SYSTEM/FailedGraphicsBackends.txt"
		;;
	tui*)
		PPSSPP_DIR="${PPSSPP_DIR}/tui"

		export LD_LIBRARY_PATH="$PPSSPP_DIR/lib:$LD_LIBRARY_PATH"
		echo 1000000 >"$(GET_VAR "device" "cpu/min_freq")"
		;;
esac

case "$FILE" in
	*.psp)
		# Mechanism to launch PSP folder-style games
		GAME=$(basename "$FILE" | sed -e 's/\.[^.]*$//')
		GAMEDIR=$(dirname "$FILE")
		if [ -e "$PPSSPP_DIR/.config/ppsspp/PSP/GAME/$GAME/EBOOT.PBP" ]; then
			FILE="$PPSSPP_DIR/.config/ppsspp/PSP/GAME/$GAME/EBOOT.PBP"
		else
			GAMESUBDIR=$(find "$GAMEDIR" -maxdepth 2 -type d \( -iname "$GAME" -o -iname ".$GAME" \))
			if [ -n "$GAMESUBDIR" ]; then
				if [ -e "$GAMESUBDIR/EBOOT.PBP" ]; then
					FILE="$GAMESUBDIR/EBOOT.PBP"
				fi
			fi
		fi
		;;
esac

rm -rf "$PPSSPP_DIR/.config/ppsspp/PSP/SYSTEM/CACHE/"*
cd "$PPSSPP_DIR" || exit

/opt/muos/script/mux/track.sh "$NAME" "$CORE" "$FILE" start

SET_VAR "system" "foreground_process" "PPSSPP"

./PPSSPP --pause-menu-exit "$FILE"

/opt/muos/script/mux/track.sh "$NAME" "$CORE" "$FILE" stop

unset SDL_ASSERT SDL_HQ_SCALER SDL_ROTATION SDL_BLITTER_DISABLED
