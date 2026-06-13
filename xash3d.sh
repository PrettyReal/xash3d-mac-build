#!/bin/bash
APPDIR="$(cd "$(dirname "$0")/.." && pwd)"
FRAMEWORKS="$APPDIR/Frameworks"
RESOURCES="$APPDIR/Resources"

export DYLD_LIBRARY_PATH="$FRAMEWORKS"

XASHDIR="$HOME/Library/Application Support/Xash3D FWGS"
mkdir -p "$XASHDIR"

if [ ! -L "$XASHDIR/valve" ]; then
    ln -s "$RESOURCES/valve" "$XASHDIR/valve"
fi

cd "$XASHDIR"
exec "$FRAMEWORKS/xash3d.bin" "$@"
