#!/bin/sh
#
# log.sh - LessUI Shell Script Logging Library
#
# SOURCE LOCATION: skeleton/SYSTEM/common/log.sh
# BUILD DESTINATIONS (copied during make):
#   1. .system/common/log.sh (runtime - sourced by launch.sh)
#   2. .tmp_update/install/log.sh (update time - sourced by boot.sh)
#
# Provides consistent, timestamped logging for boot scripts, install scripts,
# and launch scripts across all platforms.
#
# Features:
# - Automatic timestamps (HH:MM:SS)
# - Log levels: INFO, WARN, ERROR
# - Automatic log file rotation (1MB limit)
# - Thread-safe append mode
# - Console + file output (tee)
#
# Usage:
#   source $SYSTEM_PATH/common/log.sh
#   log_init "$SDCARD_PATH/boot.log"
#   log_info "System starting..."
#   log_warn "Battery low"
#   log_error "Failed to mount SD card"
#
# Environment variables:
#   LOG_FILE - Current log file path
#   LOG_ENABLED - 1 to enable logging, 0 to disable
#

###############################################################################
# Configuration
###############################################################################

LOG_FILE=""
LOG_ENABLED=1
LOG_MAX_SIZE=1048576  # 1MB in bytes
LOG_MAX_BACKUPS=3

###############################################################################
# Internal Functions
###############################################################################

# Get current timestamp in HH:MM:SS format
log_timestamp() {
	date '+%H:%M:%S'
}

# Get file size in bytes (portable across busybox and GNU coreutils)
log_get_size() {
	local file="$1"
	if [ ! -f "$file" ]; then
		echo 0
		return
	fi

	# Try stat (GNU coreutils)
	if command -v stat >/dev/null 2>&1; then
		# Linux (busybox or GNU)
		stat -c%s "$file" 2>/dev/null && return
		# macOS/BSD
		stat -f%z "$file" 2>/dev/null && return
	fi

	# Fallback: use wc (slower but universal)
	wc -c < "$file" 2>/dev/null || echo 0
}

# Rotate log file if it exceeds maximum size
log_rotate() {
	local file="$1"

	if [ ! -f "$file" ]; then
		return
	fi

	local size=$(log_get_size "$file")

	if [ "$size" -lt "$LOG_MAX_SIZE" ]; then
		return
	fi

	# Delete oldest backup
	rm -f "${file}.${LOG_MAX_BACKUPS}" 2>/dev/null

	# Rotate backups (N-1 -> N, N-2 -> N-1, ...)
	local i=$((LOG_MAX_BACKUPS - 1))
	while [ $i -ge 1 ]; do
		if [ -f "${file}.${i}" ]; then
			mv "${file}.${i}" "${file}.$((i + 1))" 2>/dev/null
		fi
		i=$((i - 1))
	done

	# Move current log to .1
	mv "$file" "${file}.1" 2>/dev/null
}

###############################################################################
# Public API
###############################################################################

# Initialize logging to a file
#
# Usage: log_init "/path/to/file.log"
#
# Creates log file directory if needed, rotates if file is too large,
# and writes a session header.
log_init() {
	LOG_FILE="$1"

	if [ -z "$LOG_FILE" ]; then
		LOG_ENABLED=0
		return
	fi

	# Create directory if needed
	mkdir -p "$(dirname "$LOG_FILE")" 2>/dev/null

	# Rotate if file exists and is too large
	log_rotate "$LOG_FILE"

	# Write session header
	echo "========================================" >> "$LOG_FILE"
	echo "Log started: $(date '+%Y-%m-%d %H:%M:%S')" >> "$LOG_FILE"
	echo "========================================" >> "$LOG_FILE"
}

# Log an informational message
#
# Usage: log_info "message"
#
# Writes to both console (stdout) and log file with [INFO] prefix.
log_info() {
	[ "$LOG_ENABLED" -eq 0 ] && return
	local msg="[$(log_timestamp)] [INFO] $*"

	if [ -n "$LOG_FILE" ]; then
		echo "$msg" | tee -a "$LOG_FILE"
	else
		echo "$msg"
	fi
}

# Log a warning message
#
# Usage: log_warn "message"
#
# Writes to both console (stdout) and log file with [WARN] prefix.
log_warn() {
	[ "$LOG_ENABLED" -eq 0 ] && return
	local msg="[$(log_timestamp)] [WARN] $*"

	if [ -n "$LOG_FILE" ]; then
		echo "$msg" | tee -a "$LOG_FILE"
	else
		echo "$msg"
	fi
}

# Log an error message
#
# Usage: log_error "message"
#
# Writes to both console (stderr) and log file with [ERROR] prefix.
log_error() {
	[ "$LOG_ENABLED" -eq 0 ] && return
	local msg="[$(log_timestamp)] [ERROR] $*"

	if [ -n "$LOG_FILE" ]; then
		echo "$msg" | tee -a "$LOG_FILE" >&2
	else
		echo "$msg" >&2
	fi
}

# Disable logging
#
# Usage: log_disable
#
# Stops writing to log file. Console output continues.
log_disable() {
	LOG_ENABLED=0
}

# Enable logging
#
# Usage: log_enable
#
# Resumes writing to log file.
log_enable() {
	LOG_ENABLED=1
}

# Write session footer and close log
#
# Usage: log_close
#
# Optional cleanup function. Writes a footer to the log file.
log_close() {
	[ "$LOG_ENABLED" -eq 0 ] && return
	[ -z "$LOG_FILE" ] && return

	echo "========================================" >> "$LOG_FILE"
	echo "Log ended: $(date '+%Y-%m-%d %H:%M:%S')" >> "$LOG_FILE"
	echo "========================================" >> "$LOG_FILE"
}
