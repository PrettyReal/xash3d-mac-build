#!/bin/bash
set -e

echo "=== Xash3D FWGS — macOS Build ==="

BUILD_DIR="/tmp/xash3d-mac-build"
APP_NAME="Half-Life"
INSTALL_DIR="$HOME/$APP_NAME.app"
STEAM_HL="$HOME/Library/Application Support/Steam/steamapps/common/Half-Life/Half-Life.app/Contents/Resources"

# 1. Клонирование репозиториев
echo "[1/8] Клонирование репозиториев..."
cd "$BUILD_DIR"
rm -rf SDL xash3d-fwgs hlsdk-portable 2>/dev/null

git clone --recursive --depth 1 https://github.com/libsdl-org/SDL.git -b SDL2 SDL
git clone --recursive --depth 1 https://github.com/FWGS/xash3d-fwgs
git clone --recursive --depth 1 https://github.com/FWGS/hlsdk-portable

# 2. Сборка SDL2.framework
echo "[2/8] Сборка SDL2.framework..."
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
xcodebuild -project "$BUILD_DIR/SDL/Xcode/SDL/SDL.xcodeproj" \
    -scheme "Framework" -configuration Release \
    -derivedDataPath "$BUILD_DIR/SDL-build" build

# 3. Сборка движка Xash3D
echo "[3/8] Сборка Xash3D FWGS..."
cd "$BUILD_DIR/xash3d-fwgs"
./waf configure --sdl2="$BUILD_DIR/SDL-build/Build/Products/Release/SDL2.framework" --enable-bundled-deps
./waf build

# 4. Сборка Half-Life (valve)
echo "[4/8] Сборка Half-Life (valve)..."
cd "$BUILD_DIR/hlsdk-portable"
./waf distclean 2>/dev/null || true
cat > mod_options.txt << 'MODOPT'
BARNACLE_FIX_VISIBILITY=OFF # Barnacle tongue length fix
CLIENT_WEAPONS=ON # Client local weapons prediction
CROWBAR_IDLE_ANIM=OFF # Crowbar idle animation
CROWBAR_DELAY_FIX=OFF # Crowbar attack delay fix
CROWBAR_FIX_RAPID_CROWBAR=ON # Rapid crowbar fix
GAUSS_OVERCHARGE_FIX=OFF # Gauss overcharge fix
TRIPMINE_BEAM_DUPLICATION_FIX=OFF # Fix of tripmine beam duplication on level transition
HANDGRENADE_DEPLOY_FIX=OFF # Handgrenade deploy animation fix after finishing a throw
WEAPONS_ANIMATION_TIMES_FIX=OFF # Animation times fix for some weapons
SATCHEL_OLD_BEHAVIOUR=OFF # Old pre-HL 25th satchel's behaviour
SPEAKABLE_TARGETS=ON # Speakable cycler and func_button (breaks AMXModX offsets)
OEM_BUILD=OFF # OEM Build
HLDEMOD_BUILD=OFF # Demo Build

GAMEDIR=valve # Gamedir path

SERVER_INSTALL_DIR=dlls # Where to put server dll
CLIENT_INSTALL_DIR=cl_dlls # Where to put client or menu dll
SERVER_LIBRARY_NAME=hl # Default server dll name
MODOPT
./waf configure && ./waf build
VALVE_CLIENT="$BUILD_DIR/hlsdk-portable/build/cl_dll/client_amd64.dylib"
VALVE_SERVER="$BUILD_DIR/hlsdk-portable/build/dlls/hl_amd64.dylib"

# 5. Сборка Opposing Force (gearbox)
echo "[5/8] Сборка Opposing Force (gearbox)..."
cd "$BUILD_DIR/hlsdk-portable"
./waf distclean
cat > mod_options.txt << 'MODOPT'
BARNACLE_FIX_VISIBILITY=OFF # Barnacle tongue length fix
CLIENT_WEAPONS=ON # Client local weapons prediction
CROWBAR_IDLE_ANIM=OFF # Crowbar idle animation
CROWBAR_DELAY_FIX=OFF # Crowbar attack delay fix
CROWBAR_FIX_RAPID_CROWBAR=ON # Rapid crowbar fix
GAUSS_OVERCHARGE_FIX=OFF # Gauss overcharge fix
TRIPMINE_BEAM_DUPLICATION_FIX=OFF # Fix of tripmine beam duplication on level transition
HANDGRENADE_DEPLOY_FIX=OFF # Handgrenade deploy animation fix after finishing a throw
WEAPONS_ANIMATION_TIMES_FIX=OFF # Animation times fix for some weapons
SATCHEL_OLD_BEHAVIOUR=OFF # Old pre-HL 25th satchel's behaviour
SPEAKABLE_TARGETS=ON # Speakable cycler and func_button (breaks AMXModX offsets)
OEM_BUILD=OFF # OEM Build
HLDEMOD_BUILD=OFF # Demo Build

GAMEDIR=gearbox # Gamedir path

SERVER_INSTALL_DIR=dlls # Where to put server dll
CLIENT_INSTALL_DIR=cl_dlls # Where to put client or menu dll
SERVER_LIBRARY_NAME=opfor # Default server dll name
MODOPT
./waf configure && ./waf build
GEARBOX_CLIENT="$BUILD_DIR/hlsdk-portable/build/cl_dll/client_amd64.dylib"
GEARBOX_SERVER="$BUILD_DIR/hlsdk-portable/build/dlls/opfor_amd64.dylib"

# 6. Сборка Blue Shift (bshift)
echo "[6/8] Сборка Blue Shift (bshift)..."
cd "$BUILD_DIR/hlsdk-portable"
./waf distclean
cat > mod_options.txt << 'MODOPT'
BARNACLE_FIX_VISIBILITY=OFF # Barnacle tongue length fix
CLIENT_WEAPONS=ON # Client local weapons prediction
CROWBAR_IDLE_ANIM=OFF # Crowbar idle animation
CROWBAR_DELAY_FIX=OFF # Crowbar attack delay fix
CROWBAR_FIX_RAPID_CROWBAR=ON # Rapid crowbar fix
GAUSS_OVERCHARGE_FIX=OFF # Gauss overcharge fix
TRIPMINE_BEAM_DUPLICATION_FIX=OFF # Fix of tripmine beam duplication on level transition
HANDGRENADE_DEPLOY_FIX=OFF # Handgrenade deploy animation fix after finishing a throw
WEAPONS_ANIMATION_TIMES_FIX=OFF # Animation times fix for some weapons
SATCHEL_OLD_BEHAVIOUR=OFF # Old pre-HL 25th satchel's behaviour
SPEAKABLE_TARGETS=ON # Speakable cycler and func_button (breaks AMXModX offsets)
OEM_BUILD=OFF # OEM Build
HLDEMOD_BUILD=OFF # Demo Build

GAMEDIR=bshift # Gamedir path

SERVER_INSTALL_DIR=dlls # Where to put server dll
CLIENT_INSTALL_DIR=cl_dlls # Where to put client or menu dll
SERVER_LIBRARY_NAME=bshift # Default server dll name
MODOPT
./waf configure && ./waf build
BSHIFT_CLIENT="$BUILD_DIR/hlsdk-portable/build/cl_dll/client_amd64.dylib"
BSHIFT_SERVER="$BUILD_DIR/hlsdk-portable/build/dlls/bshift_amd64.dylib"

# 7. Сборка приложения
echo "[7/8] Сборка .app бандла..."
mkdir -p "$INSTALL_DIR/Contents/"{MacOS,Resources,Frameworks}

# Info.plist
cp "$BUILD_DIR/xash3d-mac-build/Info.plist" "$INSTALL_DIR/Contents/"

# Лаунчер
cp "$BUILD_DIR/xash3d-mac-build/xash3d.sh" "$INSTALL_DIR/Contents/MacOS/xash3d"
chmod +x "$INSTALL_DIR/Contents/MacOS/xash3d"

# Движок
cp "$BUILD_DIR/xash3d-fwgs/build/game_launch/xash3d" "$INSTALL_DIR/Contents/Frameworks/xash3d.bin"
cp "$BUILD_DIR/xash3d-fwgs/build/engine/libxash.dylib" "$INSTALL_DIR/Contents/Frameworks/"
cp "$BUILD_DIR/xash3d-fwgs/build/ref/gl/libref_gl.dylib" "$INSTALL_DIR/Contents/Frameworks/"
cp "$BUILD_DIR/xash3d-fwgs/build/ref/soft/libref_soft.dylib" "$INSTALL_DIR/Contents/Frameworks/"
cp "$BUILD_DIR/xash3d-fwgs/build/3rdparty/mainui/libmenu.dylib" "$INSTALL_DIR/Contents/Frameworks/"
cp "$BUILD_DIR/xash3d-fwgs/build/filesystem/filesystem_stdio.dylib" "$INSTALL_DIR/Contents/Frameworks/"
cp -R "$BUILD_DIR/SDL-build/Build/Products/Release/SDL2.framework" "$INSTALL_DIR/Contents/Frameworks/"

# HLSDK — valve
if [ -d "$STEAM_HL/valve" ]; then
    cp "$VALVE_CLIENT" "$STEAM_HL/valve/cl_dlls/"
    cp "$VALVE_SERVER" "$STEAM_HL/valve/dlls/"
fi

# HLSDK — gearbox
if [ -d "$STEAM_HL/gearbox" ]; then
    cp "$GEARBOX_CLIENT" "$STEAM_HL/gearbox/cl_dlls/"
    cp "$GEARBOX_SERVER" "$STEAM_HL/gearbox/dlls/"
fi

# HLSDK — bshift
if [ -d "$STEAM_HL/bshift" ]; then
    cp "$BSHIFT_CLIENT" "$STEAM_HL/bshift/cl_dlls/"
    cp "$BSHIFT_SERVER" "$STEAM_HL/bshift/dlls/"
fi

# 8. Готово
echo "[8/8] Готово!"
echo ""
echo "Приложение: $INSTALL_DIR"
echo "Запуск: open $INSTALL_DIR"
