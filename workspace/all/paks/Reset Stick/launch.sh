#!/bin/sh

PRESENTER="$SYSTEM_PATH/bin/minui-presenter"

if [ -z "$USERDATA_PATH" ]; then
	$PRESENTER "Error: USERDATA_PATH not set" 3
	exit 1
fi

if ! rm -f "$USERDATA_PATH/mstick.bin" 2>/dev/null; then
	$PRESENTER "Error: Failed to reset calibration" 3
	exit 1
fi

$PRESENTER "Stick calibration reset.\n\nMove stick to recalibrate." 3
