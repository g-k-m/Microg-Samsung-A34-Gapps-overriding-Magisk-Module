#!/system/bin/sh
MODDIR=${0%/*}

PKG="com.google.android.gms"
DE_DIR="/data/user_de/0/$PKG"
LIB_DIR="$DE_DIR/app_extracted_libs"

# Destroy the directory if it exists and is owned by root (UID 0)
if [ -d "$LIB_DIR" ]; then
    DIR_UID=$(stat -c '%u' "$LIB_DIR")
    if [ "$DIR_UID" = "0" ]; then
        rm -rf "$LIB_DIR"
    fi
fi