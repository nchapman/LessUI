# workspace/all/utils/makefile
# Orchestrates all utility builds using a standard hook interface
#
# Each util can implement these hooks (all optional):
#   setup   - Runs once before platform builds (download shared binaries)
#   build   - Runs per-platform in Docker (compile platform-specific code)
#   install - Runs per-platform outside Docker (copy to build directory)
#   clean   - Clean build artifacts
#
# Utils that don't implement a hook are skipped automatically.

###########################################################

ifeq (,$(PLATFORM))
PLATFORM=$(UNION_PLATFORM)
endif

# Discover all utils with makefiles (exclude third-party libraries)
UTIL_DIRS := $(dir $(wildcard */makefile))
UTIL_NAMES := $(filter-out parson,$(patsubst %/,%,$(UTIL_DIRS)))

.PHONY: setup build install clean all

# Default target when called from workspace/makefile (per-platform build)
all: build

# Setup hook - runs once before any platform builds
setup:
	@echo "utils/makefile: UTIL_NAMES=$(UTIL_NAMES)"
	@echo "utils/makefile: DESTDIR=$(DESTDIR)"
	@for util in $(UTIL_NAMES); do \
		echo "  Calling setup for $$util"; \
		$(MAKE) -C "$$util" setup DESTDIR=$(DESTDIR); \
	done

# Build hook - runs per-platform in Docker
build:
	@for util in $(UTIL_NAMES); do \
		$(MAKE) -C "$$util" build PLATFORM=$(PLATFORM); \
	done

# Install hook - runs per-platform outside Docker
install:
	@for util in $(UTIL_NAMES); do \
		$(MAKE) -C "$$util" install PLATFORM=$(PLATFORM) DESTDIR=$(DESTDIR); \
	done

# Clean hook
clean:
	@for util in $(UTIL_NAMES); do \
		$(MAKE) -C "$$util" clean; \
	done
