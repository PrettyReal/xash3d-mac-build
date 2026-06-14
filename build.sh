#!/bin/bash
set -e

echo "=== Xash3D FWGS — macOS Build ==="

BUILD_DIR="/tmp/xash3d-build"
APP_NAME="Half-Life"
INSTALL_DIR="$HOME/$APP_NAME.app"
STEAM_HL="$HOME/Library/Application Support/Steam/steamapps/common/Half-Life/Half-Life.app/Contents/Resources"
XASHDIR="$HOME/Library/Application Support/Xash3D FWGS"

# 1. Клонирование репозиториев
echo "[1/9] Клонирование репозиториев..."
cd "$BUILD_DIR"
rm -rf SDL-macos xash3d-fwgs hlsdk-portable cs16-client 2>/dev/null

git clone --recursive --depth 1 https://github.com/nicknumber9/SDL-macos
git clone --recursive --depth 1 https://github.com/FWGS/xash3d-fwgs
git clone --recursive --depth 1 https://github.com/FWGS/hlsdk-portable
git clone --recursive --depth 1 https://github.com/Velaron/cs16-client

# 2. Сборка SDL2.framework
echo "[2/9] Сборка SDL2.framework..."
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
xcodebuild -project "$BUILD_DIR/SDL-macos/Xcode/SDL/SDL.xcodeproj" \
    -scheme "Framework" -configuration Release \
    -derivedDataPath "$BUILD_DIR/SDL-build" build

# 3. Сборка движка Xash3D
echo "[3/9] Сборка Xash3D FWGS..."
cd "$BUILD_DIR/xash3d-fwgs"
./waf configure --sdl2="$BUILD_DIR/SDL-build/Build/Products/Release/SDL2.framework" --enable-bundled-deps
./waf build

# 4. Сборка Half-Life (valve)
echo "[4/9] Сборка Half-Life (valve)..."
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
echo "[5/9] Сборка Opposing Force (gearbox)..."
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
echo "[6/9] Сборка Blue Shift (bshift)..."
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

# 7. Сборка CS 1.6 клиента
echo "[7/9] Сборка CS 1.6 (cs16-client)..."
cd "$BUILD_DIR/cs16-client"
mkdir -p build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_OSX_DEPLOYMENT_TARGET=10.15
cmake --build . --target client --config Release -j$(sysctl -n hw.ncpu)
CS16_CLIENT="$BUILD_DIR/cs16-client/build/cl_dll/client_amd64.dylib"
CS16_MENU="$BUILD_DIR/cs16-client/build/3rdparty/mainui_cpp/menu_amd64.dylib"
CS16_SERVER="$BUILD_DIR/cs16-client/build/3rdparty/ReGameDLL_CS/regamedll/cs_amd64.dylib"

# 8. Сборка приложения
echo "[8/9] Сборка .app бандлов..."
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

# CS 1.6 — копирование библиотек
CSTRIKE_DIR="$HOME/Library/Application Support/Steam/steamapps/common/Half-Life/cstrike"
if [ ! -d "$CSTRIKE_DIR" ]; then
    mkdir -p "$CSTRIKE_DIR"
fi
mkdir -p "$CSTRIKE_DIR/dlls" "$CSTRIKE_DIR/cl_dlls"
cp "$CS16_CLIENT" "$CSTRIKE_DIR/cl_dlls/"
cp "$CS16_SERVER" "$CSTRIKE_DIR/dlls/"
cp "$CS16_MENU" "$CSTRIKE_DIR/"

# CS 1.6 .app bundle
CS16_APP="$HOME/Desktop/CS 1.6.app"
mkdir -p "$CS16_APP/Contents/"{MacOS,Resources,Frameworks}

# Info.plist для CS 1.6
cat > "$CS16_APP/Contents/Info.plist" << 'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleDisplayName</key>
    <string>Counter-Strike 1.6</string>
    <key>CFBundleExecutable</key>
    <string>cs16</string>
    <key>CFBundleIdentifier</key>
    <string>com.valve.cs16</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>Counter-Strike 1.6</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.6</string>
    <key>CFBundleVersion</key>
    <string>1.6</string>
    <key>LSMinimumSystemVersion</key>
    <string>10.13</string>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
PLIST

# Лаунчер CS 1.6
cat > "$CS16_APP/Contents/MacOS/cs16" << 'LAUNCHER'
#!/bin/bash
APPDIR="$(cd "$(dirname "$0")/.." && pwd)"
FRAMEWORKS="$APPDIR/Frameworks"
export DYLD_LIBRARY_PATH="$FRAMEWORKS"
XASHDIR="$HOME/Library/Application Support/Xash3D FWGS"
mkdir -p "$XASHDIR"
STEAM_HL="$HOME/Library/Application Support/Steam/steamapps/common/Half-Life"
if [ -d "$STEAM_HL/cstrike" ] && [ ! -L "$XASHDIR/cstrike" ] && [ ! -d "$XASHDIR/cstrike" ]; then
    ln -s "$STEAM_HL/cstrike" "$XASHDIR/cstrike"
fi
cd "$XASHDIR"
exec "$FRAMEWORKS/xash3d.bin" -game cstrike "$@"
LAUNCHER
chmod +x "$CS16_APP/Contents/MacOS/cs16"

# Копирование движка в CS 1.6.app
cp "$BUILD_DIR/xash3d-fwgs/build/game_launch/xash3d" "$CS16_APP/Contents/Frameworks/xash3d.bin"
cp "$BUILD_DIR/xash3d-fwgs/build/engine/libxash.dylib" "$CS16_APP/Contents/Frameworks/"
cp "$BUILD_DIR/xash3d-fwgs/build/ref/gl/libref_gl.dylib" "$CS16_APP/Contents/Frameworks/"
cp "$BUILD_DIR/xash3d-fwgs/build/ref/soft/libref_soft.dylib" "$CS16_APP/Contents/Frameworks/"
cp "$BUILD_DIR/xash3d-fwgs/build/3rdparty/mainui/libmenu.dylib" "$CS16_APP/Contents/Frameworks/"
cp "$BUILD_DIR/xash3d-fwgs/build/filesystem/filesystem_stdio.dylib" "$CS16_APP/Contents/Frameworks/"
cp -R "$BUILD_DIR/SDL-build/Build/Products/Release/SDL2.framework" "$CS16_APP/Contents/Frameworks/"

# 9. Готово
echo "[9/9] Готово!"
echo ""
echo "Приложение Half-Life: $INSTALL_DIR"
echo "Приложение CS 1.6: $CS16_APP"
echo "Запуск HL: open $INSTALL_DIR"
echo "Запуск CS: open $CS16_APP"
