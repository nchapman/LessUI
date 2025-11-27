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

- [x] **Files** - Migrated to `workspace/all/paks/Files/`
  - Platform-specific binaries (DinguxCommander, 351Files, system fileM)
  - Launch.sh has platform branching using case/esac
  - Successfully validates `bin/<platform>/` and `res/<platform>/` pattern
  - Removed old skeleton copies (10 platforms)
  - Removed platform-specific makefile.copy rules
  - Builds and deploys successfully

- [x] **Bootlogo** - Migrated to `workspace/all/paks/Bootlogo/`
  - Cross-platform launch.sh with platform branching (7 platforms)
  - Platform-specific resources in `<platform>/` directories
  - Hybrid pak: native code for miyoomini, shell-only for others
  - miyoomini: logoread.elf, logomake.elf, logowrite.elf (compiled)
  - my282: bootlogo.bmp + res/ with firmware offsets
  - my355: payload/bin/ with mkbootimg, unpackbootimg, rsce_tool
  - tg5040: brick/ and default bootlogo.bmp variants
  - zero28, m17, trimuismart: bootlogo.bmp files
  - Enhanced with minui-presenter for user feedback
  - Successfully validates hybrid pak pattern (native + shell)
  - Removed old skeleton copies (7 platforms)
  - Removed platform-specific makefile.copy rules

## Pending Migrations

### High Priority - Native Code Paks

None remaining!

### Medium Priority - Shell Script Paks

None remaining!

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

**All high and medium priority tool paks are now migrated!**

Remaining paks are platform-specific (WiFi, ADBD, SSH, Splore, etc.). These can be migrated as needed or left as platform-specific since they only apply to 1-2 platforms each.

Consider:
1. WiFi pak - Most complex remaining, would benefit from unified approach
2. Emulator paks - Evaluate if template system should migrate to unified paks
3. Third-party pak documentation - Make it easy for external developers to contribute paks
