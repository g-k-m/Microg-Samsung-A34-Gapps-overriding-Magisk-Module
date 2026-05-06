#!/system/bin/sh

# SKIPUNZIP=0 ensures Magisk extracts your 'system' folder automatically
SKIPUNZIP=0

if [ -n "$MMM_EXT_SUPPORT" ]; then
  ui_print "#!useExt"
  mmm_exec() {
    ui_print "$(echo "#!$@")"
  }
else
  mmm_exec() { true; }
fi

if ! $BOOTMODE; then
   abort "- ERROR: Installation via recovery is NOT supported."
fi

mmm_exec showLoading
ui_print " "
ui_print "==================================="
ui_print "  microG Installer Revived (Fixed)"
ui_print "  Samsung One UI Overlay Mode"
ui_print "  with Native Lib Pre-packing"
ui_print "==================================="
ui_print " "

ui_print "- Force Installing microG..."

# 1. Set standard permissions for the base directory structure
set_perm_recursive "$MODPATH" 0 0 0755 0644 u:object_r:system_lib_file:s0

# 2. Phase 1 Execution: Native Library Permission Hardening
ui_print "- Configuring native system library permissions..."

# Dynamically search for the pre-packed library directories within the module
LIB_DIRS=$(find "$MODPATH" -type d \( -name "arm64" -o -name "arm64-v8a" \))

if [ -n "$LIB_DIRS" ]; then
    for DIR in $LIB_DIRS; do
        # Extract relative path for cleaner UI output
        REL_DIR=${DIR#$MODPATH/}
        ui_print "  Securing linker paths for: $REL_DIR"
        
        # Enforce exact permissions: Root owner, Dir 0755, Files 0644
        set_perm_recursive "$DIR" 0 0 0755 0644
    done
    ui_print "  [SUCCESS] Native libraries pre-packed for system linker."
else
    ui_print "  [WARNING] Native lib directory not found in module structure."
fi

ui_print " "
ui_print "==================================="
ui_print "  Installation Complete!"
ui_print "==================================="
ui_print " "
ui_print "Reboot to apply changes."
ui_print " "

mmm_exec hideLoading