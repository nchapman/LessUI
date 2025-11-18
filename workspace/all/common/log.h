/**
 * log.h - LessUI Logging System
 *
 * A lightweight, elegant logging library for embedded systems.
 * Provides consistent logging across all LessUI components with automatic
 * timestamps, errno translation, log rotation, and thread safety.
 *
 * Features:
 * - Four log levels: ERROR, WARN, INFO, DEBUG
 * - Automatic timestamps (HH:MM:SS format)
 * - Automatic errno translation with LOG_errno()
 * - Optional file:line context for errors
 * - Thread-safe file logging with rotation
 * - Compile-time level control for zero overhead
 * - Size-based log rotation (configurable)
 *
 * Usage:
 *   LOG_error("Failed to open file: %s", path);
 *   LOG_errno("fopen() failed for %s", path);  // Adds errno automatically
 *   LOG_warn("Battery low: %d%%", level);
 *   LOG_info("Loading ROM: %s", rom_path);
 *   LOG_debug("Pixel %d,%d = %06x", x, y, color);
 *
 * Note: Newlines are added automatically - do not include \n in messages
 *
 * Compile-time control:
 *   -DENABLE_INFO_LOGS    Enable INFO level (recommended for main apps)
 *   -DENABLE_DEBUG_LOGS   Enable DEBUG level (development/testing only)
 *   Without flags: Only ERROR and WARN compiled in
 *
 * Log output:
 *   By default, logs go to stdout/stderr. Shell scripts redirect to files.
 *   For daemons or apps needing rotation, use log_file_open() API.
 */

#ifndef __LOG_H__
#define __LOG_H__

#include <errno.h>
#include <stdarg.h>
#include <stddef.h>
#include <string.h>

///////////////////////////////
// Log Levels
///////////////////////////////

typedef enum {
	LOG_LEVEL_ERROR = 0, // Critical errors, always compiled
	LOG_LEVEL_WARN = 1, // Warnings, always compiled
	LOG_LEVEL_INFO = 2, // Informational, controlled by ENABLE_INFO_LOGS
	LOG_LEVEL_DEBUG = 3, // Debug, controlled by ENABLE_DEBUG_LOGS
} LogLevel;

///////////////////////////////
// Core Logging Functions
///////////////////////////////

/**
 * Write a log message at the specified level.
 *
 * Formats and writes a timestamped log message. For ERROR level, includes
 * file:line context. Output goes to stderr for ERROR/WARN, stdout for INFO/DEBUG.
 *
 * @param level Log severity level
 * @param file Source file name (use __FILE__)
 * @param line Source line number (use __LINE__)
 * @param fmt Printf-style format string
 * @param ... Format arguments
 */
void log_write(LogLevel level, const char* file, int line, const char* fmt, ...);

/**
 * Write a simple log message without file:line context.
 *
 * Same as log_write() but omits source location. Use for cleaner output
 * when context isn't needed.
 *
 * @param level Log severity level
 * @param fmt Printf-style format string
 * @param ... Format arguments
 */
void log_write_simple(LogLevel level, const char* fmt, ...);

///////////////////////////////
// Primary Logging Macros
///////////////////////////////

/**
 * Log an error message with file:line context.
 *
 * Always compiled. Use for critical failures that prevent normal operation.
 * Examples: file open failures, malloc failures, invalid state
 */
#define LOG_error(fmt, ...) log_write(LOG_LEVEL_ERROR, __FILE__, __LINE__, fmt, ##__VA_ARGS__)

/**
 * Log a warning message with file:line context.
 *
 * Always compiled. Use for non-critical issues that don't prevent operation.
 * Examples: missing optional files, deprecated features, recoverable errors
 */
#define LOG_warn(fmt, ...) log_write(LOG_LEVEL_WARN, __FILE__, __LINE__, fmt, ##__VA_ARGS__)

/**
 * Log an informational message.
 *
 * Compiled only if ENABLE_INFO_LOGS defined. Use for key events and milestones.
 * Examples: app startup, ROM loading, save state operations
 */
#ifdef ENABLE_INFO_LOGS
#define LOG_info(fmt, ...) log_write_simple(LOG_LEVEL_INFO, fmt, ##__VA_ARGS__)
#else
#define LOG_info(fmt, ...) ((void)0)
#endif

/**
 * Log a debug message.
 *
 * Compiled only if ENABLE_DEBUG_LOGS defined. Use for detailed tracing.
 * Examples: loop iterations, variable values, call traces
 */
#ifdef ENABLE_DEBUG_LOGS
#define LOG_debug(fmt, ...) log_write_simple(LOG_LEVEL_DEBUG, fmt, ##__VA_ARGS__)
#else
#define LOG_debug(fmt, ...) ((void)0)
#endif

///////////////////////////////
// Errno Helper Macros
///////////////////////////////

/**
 * Log an error with automatic errno translation.
 *
 * Automatically appends strerror(errno) to the message. Use immediately
 * after system calls that set errno.
 *
 * Example:
 *   FILE* fp = fopen(path, "r");
 *   if (!fp) {
 *       LOG_errno("Failed to open %s", path);
 *       return -1;
 *   }
 *
 * Output:
 *   [ERROR] file.c:123 Failed to open /path/to/file: No such file or directory
 */
#define LOG_errno(fmt, ...)                                                                        \
	log_write(LOG_LEVEL_ERROR, __FILE__, __LINE__, fmt ": %s", ##__VA_ARGS__, strerror(errno))

/**
 * Log a warning with automatic errno translation.
 *
 * Same as LOG_errno() but at WARN level.
 */
#define LOG_errno_warn(fmt, ...)                                                                   \
	log_write(LOG_LEVEL_WARN, __FILE__, __LINE__, fmt ": %s", ##__VA_ARGS__, strerror(errno))

///////////////////////////////
// File Logging API (Optional)
///////////////////////////////

/**
 * Opaque handle for direct file logging with rotation.
 *
 * Use log_file_open() to create, log_file_write() to write,
 * log_file_close() to cleanup. Thread-safe.
 */
typedef struct LogFile LogFile;

/**
 * Open a log file with automatic rotation support.
 *
 * Creates a log file that automatically rotates when it exceeds max_size.
 * Rotated files are named: file.log.1, file.log.2, etc.
 *
 * Thread-safe: Multiple threads can write to the same LogFile.
 *
 * @param path Path to log file (e.g., "/tmp/keymon.log")
 * @param max_size Maximum size in bytes before rotation (0 = no rotation)
 * @param max_backups Number of rotated backups to keep
 * @return LogFile handle, or NULL on failure
 *
 * Example:
 *   LogFile* log = log_file_open("/tmp/daemon.log", 1024*1024, 3);
 *   if (log) {
 *       log_file_write(log, LOG_LEVEL_INFO, "Daemon started");
 *       log_file_close(log);
 *   }
 */
LogFile* log_file_open(const char* path, size_t max_size, int max_backups);

/**
 * Write a message to a LogFile.
 *
 * Thread-safe. Automatically rotates if file exceeds max_size.
 *
 * @param lf LogFile handle from log_file_open()
 * @param level Log severity level
 * @param fmt Printf-style format string
 * @param ... Format arguments
 */
void log_file_write(LogFile* lf, LogLevel level, const char* fmt, ...);

/**
 * Close and free a LogFile.
 *
 * Flushes buffers and releases resources. Handle becomes invalid.
 *
 * @param lf LogFile handle from log_file_open()
 */
void log_file_close(LogFile* lf);

#endif // __LOG_H__
