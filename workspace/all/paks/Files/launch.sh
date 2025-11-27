#!/bin/sh

cd "$(dirname "$0")"

# Set HOME to SD card path for all file managers
HOME="$SDCARD_PATH"

case "$PLATFORM" in
	rg35xxplus)
		# Use system file manager on rg35xxplus
		DIR="/mnt/vendor/bin/fileM"
		if [ ! -d "$DIR" ]; then
			show.elf "$(dirname "$0")/res/$PLATFORM/missing.png" 4
		else
			cd "$DIR"
			syncsettings.elf &
			./dinguxCommand_en.dge
		fi
		;;
	magicmini)
		# Use 351Files on magicmini
		./bin/$PLATFORM/351Files
		;;
	*)
		# Use DinguxCommander on all other platforms
		./bin/$PLATFORM/DinguxCommander
		;;
esac
