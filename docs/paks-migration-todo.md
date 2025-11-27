# Paks Migration TODO

This document tracks the migration of existing paks to the new unified architecture (`workspace/all/paks/`).

## Completed ✅

- [x] **Clock** - Migrated to `workspace/all/paks/Clock/`
  - Single source of truth for launch.sh (was duplicated 11 times)
  - Native C code in `src/`
  - Builds and deploys successfully

- [x] **Utils Integration** - Added Jose's utilities to `workspace/all/utils/`
  - minui-keyboard (text input widget)
  - minui-list (settings/menu widget) - upgraded to DP system
  - minui-presenter (message display widget) - upgraded to DP system
  - All deployed to `build/SYSTEM/<platform>/bin/` (available to all paks)

- [x] **Input** - Migrated to `workspace/all/paks/Input/`
  - Native C code in `src/`
  - Single launch.sh (was duplicated 11 times)
  - Successfully validates the cross-platform paks pattern
  - Builds and deploys successfully

## Pending Migrations

### High Priority - Native Code Paks

None remaining!

### Medium Priority - Shell Script Paks

- [ ] **Bootlogo** - `skeleton/EXTRAS/Tools/*/Bootlogo.pak/`
  - Shell script only (no native code)
  - Currently duplicated across ~8 platforms
  - Tests non-native pak pattern

- [ ] **Files** - `skeleton/EXTRAS/Tools/*/Files.pak/`
  - Platform-specific binaries (DinguxCommander, 351Files, system fileM)
  - Launch.sh has platform branching
  - Tests `bin/<platform>/` pattern

### Low Priority - Platform-Specific Paks

- [ ] **WiFi** - `skeleton/EXTRAS/Tools/rgb30/Wi-Fi.pak/`
  - Currently rgb30-only
  - Expand to support multiple platforms
  - Use minui-list/minui-presenter for UI
  - Tests bin/, lib/, res/ with platform-specific assets

- [ ] **ADBD** - `skeleton/EXTRAS/Tools/miyoomini/ADBD.pak/`
  - miyoomini-specific (WiFi/USB debug)

- [ ] **Enable SSH** - `skeleton/EXTRAS/Tools/rg35xxplus/Enable SSH.pak/`
  - rg35xxplus-specific

- [ ] **Splore** - `skeleton/EXTRAS/Tools/rgb30/Splore.pak/`
  - rgb30-specific (PICO-8 launcher)

- [ ] **Other platform-specific paks** - Various Remove Loading, IP, etc.

## Future Enhancements

- [ ] **Emulator paks** - Consider migrating from `skeleton/TEMPLATES/minarch-paks/` to `workspace/all/paks/`
  - Lower priority - current template system works well
  - Would unify all paks in one location
  - Evaluate after tool paks are complete

- [ ] **Third-party pak support** - Make it easy to integrate external paks
  - Document pak.json schema
  - Provide template/example paks
  - Consider making `workspace/all/common/` available to external paks

- [ ] **Dependency management** - Add support for downloading external binaries
  - Implement `dependencies` section in pak.json
  - Auto-fetch jq, syncthing, sftpgo, etc.
  - Reference: Jose's sftpgo pak Makefile

## Next Recommended Action

**Migrate Bootlogo.pak** - Next straightforward step:
1. Shell script only (no native code) - tests non-native pak pattern
2. Currently duplicated across ~8 platforms
3. Simple pak structure validates template for script-only paks

**Or consider Files.pak:**
1. Tests platform-specific binaries pattern (`bin/<platform>/`)
2. Tests platform branching in launch.sh
3. More complex but demonstrates advanced pak capabilities
