#!/system/bin/sh
MODDIR=${0%/*}

PKG="com.google.android.gms"
VD_PKG="com.android.vending"
DE_DIR="/data/user_de/0/$PKG"
LIB_DIR="$DE_DIR/app_extracted_libs"

# 1. Wait for installd to initialize the parent directory
while [ ! -d "$DE_DIR" ]; do
    sleep 1
done

# 2. Extract dynamic DAC attributes
DIR_UID=$(stat -c '%u' "$DE_DIR")
DIR_GID=$(stat -c '%g' "$DE_DIR")

# 3. Extract exact MAC attributes (SELinux Context + MCS)
DIR_CONTEXT=$(ls -dZ "$DE_DIR" | awk '{print $1}')

# 4. Safely create the extraction directory
if [ ! -d "$LIB_DIR" ]; then
    mkdir -p "$LIB_DIR"
fi

# 5. Enforce DAC Permissions
chown -R $DIR_UID:$DIR_GID "$LIB_DIR"
chmod 0771 "$LIB_DIR"

# 6. Enforce MAC Contexts
chcon -R "$DIR_CONTEXT" "$LIB_DIR"

# 7. Secure the parent directory
chmod 0755 "$DE_DIR"

# 8. Wait for boot completion to safely grant dynamic permissions
while [ "$(getprop sys.boot_completed)" != "1" ]; do
    sleep 2
done

# 9. Force grant Fake Package Signature (Adopted from 1.0.0-0)
pm grant $VD_PKG android.permission.FAKE_PACKAGE_SIGNATURE 2>/dev/null
pm grant $PKG android.permission.FAKE_PACKAGE_SIGNATURE 2>/dev/null