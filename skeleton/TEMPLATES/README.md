# Pak Templates

This directory contains the canonical templates for generating platform-specific `.pak` directories.

## Structure

- `platforms.json` - Platform metadata (nice prefix, default settings)
- `cores.json` - Core definitions (emu_exe, bundled status)
- `paks/launch.sh.template` - Launch script template
- `paks/configs/` - Config templates for each core

## Usage

Paks are automatically generated during `make setup`, but you can also generate manually:

```bash
# Generate all paks for all platforms
./scripts/generate-paks.sh all

# Generate for specific platform
./scripts/generate-paks.sh miyoomini

# Generate specific cores for platform
./scripts/generate-paks.sh miyoomini GB GBA VB
```

## Adding a New Core

1. Add entry to `cores.json` (under `stock_cores` or `extra_cores`)
2. Create config template in `paks/configs/<CORE>.cfg`
3. Run `./scripts/generate-paks.sh all`

See `docs/PAK-TEMPLATES.md` for comprehensive documentation.

## Adding a New Platform

1. Add entry to `platforms.json`
2. Run `./scripts/generate-paks.sh all`

All existing cores will be generated for the new platform.

## Template Placeholders

### launch.sh.template
- `{{EMU_EXE}}` - Core library name
- `{{NICE_PREFIX}}` - CPU priority prefix (`nice -20 ` or empty)
- `{{CORES_PATH_OVERRIDE}}` - Sets CORES_PATH for bundled cores

### configs/*.cfg
- `{{PLATFORM_MINARCH_SETTING}}` - Platform-specific first-line setting

## Files

- **Generated** (during build): `build/SYSTEM/*/paks/`, `build/EXTRAS/Emus/*/`
- **Source of Truth**: This directory
- **Legacy** (for validation): `skeleton/SYSTEM/*/paks/`, `skeleton/EXTRAS/Emus/*/`
