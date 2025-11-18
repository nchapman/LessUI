#!/bin/sh
# NOTE: becomes .tmp_update/tg5040.sh

PLATFORM="tg5040"
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

# for Brick
mount -o remount,rw,async "$SDCARD_PATH"
mount -o remount,rw,async "/mnt/UDISK"

echo userspace > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
CPU_PATH=/sys/devices/system/cpu/cpu0/cpufreq/scaling_setspeed
CPU_SPEED_PERF=2000000
echo $CPU_SPEED_PERF > $CPU_PATH

# install/update
if [ -f "$UPDATE_PATH" ]; then
	export LD_LIBRARY_PATH=/usr/trimui/lib:$LD_LIBRARY_PATH
	export PATH=/usr/trimui/bin:$PATH

	TRIMUI_MODEL=`strings /usr/trimui/bin/MainUI | grep ^Trimui`
	if [ "$TRIMUI_MODEL" = "Trimui Brick" ]; then
		DEVICE="brick"
	fi

	# leds_off
	echo 0 > /sys/class/led_anim/max_scale
	if [ "$DEVICE" = "brick" ]; then
		echo 0 > /sys/class/led_anim/max_scale_lr
		echo 0 > /sys/class/led_anim/max_scale_f1f2
	fi

	cd $(dirname "$0")/$PLATFORM
	if [ -d "$SYSTEM_PATH" ]; then
		ACTION=updating
		ACTION_NOUN="update"
	else
		ACTION=installing
		ACTION_NOUN="installation"
	fi
	./show.elf ./$DEVICE/$ACTION.png

	log_info "Starting LessUI $ACTION_NOUN..."
	if ./unzip -o "$UPDATE_PATH" -d "$SDCARD_PATH" >> "$LOG_FILE" 2>&1; then
		log_info "Unzip complete"
	else
		EXIT_CODE=$?
		log_error "Unzip failed with exit code $EXIT_CODE"
	fi
	rm -f "$UPDATE_PATH"
	sync

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

	if [ "$ACTION" = "installing" ]; then
		log_info "Rebooting..."
		reboot
	fi
fi

LAUNCH_PATH="$SYSTEM_PATH/$PLATFORM/paks/MinUI.pak/launch.sh"
if [ -f "$LAUNCH_PATH" ] ; then
	exec "$LAUNCH_PATH"
fi
