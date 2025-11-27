#!/bin/sh
# ADBD.pak - Enable ADB over WiFi

PAK_DIR="$(dirname "$0")"
PAK_NAME="$(basename "$PAK_DIR" .pak)"
cd "$PAK_DIR" || exit 1

# Logging
rm -f "$LOGS_PATH/$PAK_NAME.txt"
exec >>"$LOGS_PATH/$PAK_NAME.txt" 2>&1
echo "$0" "$@"

# Bail if already running
if pidof adbd >/dev/null 2>&1; then
	echo "adbd already running"
	exit 0
fi

# Platform-specific implementation
case "$PLATFORM" in
	miyoomini)
		# Load the WiFi driver from the SD card
		if ! grep -q 8188fu /proc/modules 2>/dev/null; then
			insmod "$PAK_DIR/miyoomini/8188fu.ko"
		fi

		# Enable WiFi hardware
		/customer/app/axp_test wifion
		sleep 2

		# Bring up WiFi interface (configured in stock)
		ifconfig wlan0 up
		wpa_supplicant -B -D nl80211 -iwlan0 -c /appconfigs/wpa_supplicant.conf
		udhcpc -i wlan0 -s /etc/init.d/udhcpc.script &

		# Surgical strike to nop /etc/profile
		# because it brings up the entire system again
		mount -o bind "$PAK_DIR/miyoomini/profile" /etc/profile

		# Launch adbd
		export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$PAK_DIR/miyoomini"
		"$PAK_DIR/miyoomini/adbd" &
		;;
	*)
		echo "$PLATFORM is not a supported platform"
		exit 1
		;;
esac
