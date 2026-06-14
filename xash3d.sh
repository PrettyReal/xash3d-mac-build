#!/bin/bash
APPDIR="$(cd "$(dirname "$0")/.." && pwd)"
FRAMEWORKS="$APPDIR/Frameworks"

export DYLD_LIBRARY_PATH="$FRAMEWORKS"

XASHDIR="$HOME/Library/Application Support/Xash3D FWGS"
mkdir -p "$XASHDIR"

STEAM_HL="$HOME/Library/Application Support/Steam/steamapps/common/Half-Life/Half-Life.app/Contents/Resources"

for mod in valve gearbox bshift; do
    if [ -d "$STEAM_HL/$mod" ] && [ ! -L "$XASHDIR/$mod" ] && [ ! -d "$XASHDIR/$mod" ]; then
        ln -s "$STEAM_HL/$mod" "$XASHDIR/$mod"
    fi
done

cd "$XASHDIR"
exec "$FRAMEWORKS/xash3d.bin" "$@"
