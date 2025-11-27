#!/bin/sh

# Cross-platform loading screen removal tool
# Patches device firmware to disable boot loading screens

DIR="$(dirname "$0")"
cd "$DIR"

# Platform-specific implementations
case "$PLATFORM" in
	miyoomini)
		overclock.elf $CPU_SPEED_GAME # slow down, my282 didn't like overclock during this operation

		{
			# squashfs tools and liblzma.so sourced from toolchain buildroot
			cp -r miyoomini/bin /tmp
			cp -r miyoomini/lib /tmp

			export PATH=/tmp/bin:$PATH
			export LD_LIBRARY_PATH=/tmp/lib:$LD_LIBRARY_PATH

			show.elf "$DIR/miyoomini/patch.png" 600 &

			cd /tmp

			rm -rf customer squashfs-root customer.modified

			cp /dev/mtd6 customer

			unsquashfs customer
			if [ $? -ne 0 ]; then
				killall -9 show.elf
				show.elf "$DIR/miyoomini/abort.png" 2
				sync
				exit 1
			fi

			sed -i '/^\/customer\/app\/sdldisplay/d' squashfs-root/main
			echo "patched main"

			mksquashfs squashfs-root customer.mod -comp xz -b 131072 -xattrs -all-root
			if [ $? -ne 0 ]; then
				killall -9 show.elf
				show.elf "$DIR/miyoomini/abort.png" 2
				sync
				exit 1
			fi

			dd if=customer.mod of=/dev/mtdblock6 bs=128K conv=fsync

			killall -9 show.elf

		} &> ./log.txt

		mv "$DIR" "$DIR.disabled"
		reboot
		;;

	my282)
		overclock.elf performance 2 1200 384 1080 0

		{
			# copy to tmp to get around spaces in lib path
			# these are sourced from the my282 toolchain buildroot
			cp -r my282/bin /tmp
			cp -r my282/lib /tmp

			export PATH=/tmp/bin:$PATH
			export LD_LIBRARY_PATH=/tmp/lib:$LD_LIBRARY_PATH

			show.elf "$DIR/my282/patch.png" 600 &

			cd /tmp

			rm -rf rootfs squashfs-root rootfs.modified

			cp /dev/mtdblock3 rootfs

			unsquashfs rootfs
			if [ $? -ne 0 ]; then
				killall -9 show.elf
				show.elf "$DIR/my282/abort.png" 2
				sync
				exit 1
			fi

			BOOT_PATH=/tmp/squashfs-root/etc/init.d/boot

			sed -i '/^#added by cb.*/,/^echo "show loading txt" >> \/tmp\/.show_loading_txt.log/d' $BOOT_PATH
			echo "patched $BOOT_PATH"

			mksquashfs squashfs-root rootfs.modified -comp xz -b 256k
			if [ $? -ne 0 ]; then
				killall -9 show.elf
				show.elf "$DIR/my282/abort.png" 2
				sync
				exit 1
			fi

			mtd write /tmp/rootfs.modified rootfs
			killall -9 show.elf

		} &> ./log.txt

		mv "$DIR" "$DIR.disabled"
		;;

	tg5040)
		sed -i '/^\/usr\/sbin\/pic2fb \/etc\/splash.png/d' /etc/init.d/runtrimui
		show.elf "$DIR/$DEVICE/done.png" 2

		mv "$DIR" "$DIR.disabled"
		sync
		;;

	*)
		echo "Remove Loading not supported on $PLATFORM"
		exit 1
		;;
esac
