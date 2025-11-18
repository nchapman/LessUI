#!/bin/sh
# NOTE: becomes .tmp_update/my282.sh

PLATFORM="my282"
SDCARD_PATH="/mnt/SDCARD"
UPDATE_PATH="$SDCARD_PATH/LessUI.zip"
SYSTEM_PATH="$SDCARD_PATH/.system"
LOG_FILE="$SDCARD_PATH/lessui-install.log"

# Embedded logging (same format as log.sh)
log_write() {
	echo "[$1] $2" >> "$LOG_FILE"
}
log_info() { log_write "INFO" "$*"; }
log_error() { log_write "ERROR" "$*"; }

CPU_PATH=/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo performance > "$CPU_PATH"

# install/update
if [ -f "$UPDATE_PATH" ]; then
	cd $(dirname "$0")/$PLATFORM

	if [ -d "$SYSTEM_PATH" ]; then
		ACTION="update"
		./show.elf ./updating.png
	else
		ACTION="installation"
		./show.elf ./installing.png
	fi

	log_info "Starting LessUI $ACTION..."
	mv $SDCARD_PATH/.tmp_update $SDCARD_PATH/.tmp_update-old
	if ./unzip -o "$UPDATE_PATH" -d "$SDCARD_PATH" >> "$LOG_FILE" 2>&1; then
		log_info "Unzip complete"
	else
		EXIT_CODE=$?
		log_error "Unzip failed with exit code $EXIT_CODE"
	fi
	rm -f "$UPDATE_PATH"
	rm -rf $SDCARD_PATH/.tmp_update-old

	# the updated system finishes the install/update
	if [ -f $SYSTEM_PATH/$PLATFORM/bin/install.sh ]; then
		log_info "Running install.sh..."
		if $SYSTEM_PATH/$PLATFORM/bin/install.sh >> "$LOG_FILE" 2>&1; then
			log_info "Installation complete"
		else
			EXIT_CODE=$?
			log_error "install.sh failed with exit code $EXIT_CODE"
		fi
	fi
fi

# or launch (and keep launched)
LAUNCH_PATH="$SYSTEM_PATH/$PLATFORM/paks/MinUI.pak/launch.sh"
while [ -f "$LAUNCH_PATH" ] ; do
	"$LAUNCH_PATH"
done

poweroff # under no circumstances should stock be allowed to touch this card
