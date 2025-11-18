#!/bin/sh

# SYSTEM/usr/bin/autostart.sh

SDCARD_PATH=/storage/TF2
SYSTEM_FRAG=/.system/magicmini
UPDATE_FRAG=/LessUI.zip
SYSTEM_PATH=${SDCARD_PATH}${SYSTEM_FRAG}
UPDATE_PATH=${SDCARD_PATH}${UPDATE_FRAG}
LOG_FILE="$SDCARD_PATH/lessui-install.log"

# Embedded logging (same format as log.sh)
log_write() {
	echo "[$1] $2" >> "$LOG_FILE"
}
log_info() { log_write "INFO" "$*"; }
log_error() { log_write "ERROR" "$*"; }

# is there an update available?
if [ -f $UPDATE_PATH ]; then
	if [ ! -d $SYSTEM_PATH ]; then
		ACTION=installing
		ACTION_NOUN="installation"
	else
		ACTION=updating
		ACTION_NOUN="update"
	fi

	# show action
	dd if=/usr/config/minui/$ACTION.bmp of=/dev/fb0 bs=1 skip=54
	echo 0,0 > /sys/class/graphics/fb0/pan

	log_info "Starting LessUI $ACTION_NOUN..."
	if unzip -o $UPDATE_PATH -d $SDCARD_PATH >> "$LOG_FILE" 2>&1; then
		log_info "Unzip complete"
	else
		EXIT_CODE=$?
		log_error "Unzip failed with exit code $EXIT_CODE"
	fi
	rm -f $UPDATE_PATH

	# the updated system finishes the install/update
	if [ -f $SYSTEM_PATH/bin/install.sh ]; then
		log_info "Running install.sh..."
		if $SYSTEM_PATH/bin/install.sh >> "$LOG_FILE" 2>&1; then
			log_info "Installation complete"
		else
			EXIT_CODE=$?
			log_error "install.sh failed with exit code $EXIT_CODE"
		fi
	fi
fi

LAUNCH_PATH=$SYSTEM_PATH/paks/MinUI.pak/launch.sh
if [ -f $LAUNCH_PATH ]; then
	$LAUNCH_PATH
fi

sync && shutdown now
