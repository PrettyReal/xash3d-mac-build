#!/bin/bash
set -e

echo "=== Xash3D FWGS — macOS Build ==="

BUILD_DIR="/tmp/xash3d-mac-build"
APP_NAME="Half-Life"
INSTALL_DIR="$HOME/$APP_NAME.app"

# 1. Клонирование репозиториев
echo "[1/6] Клонирование репозиториев..."
cd "$BUILD_DIR"
rm -rf SDL xash3d-fwgs hlsdk-portable 2>/dev/null

git clone --recursive --depth 1 https://github.com/libsdl-org/SDL.git -b SDL2 SDL
git clone --recursive --depth 1 https://github.com/FWGS/xash3d-fwgs
git clone --recursive --depth 1 https://github.com/FWGS/hlsdk-portable

# 2. Сборка SDL2.framework
echo "[2/6] Сборка SDL2.framework..."
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
xcodebuild -project "$BUILD_DIR/SDL/Xcode/SDL/SDL.xcodeproj" \
    -scheme "Framework" -configuration Release \
    -derivedDataPath "$BUILD_DIR/SDL-build" build

# 3. Сборка движка Xash3D
echo "[3/6] Сборка Xash3D FWGS..."
cd "$BUILD_DIR/xash3d-fwgs"
./waf configure --sdl2="$BUILD_DIR/SDL-build/Build/Products/Release/SDL2.framework" --enable-bundled-deps
./waf build

# 4. Сборка HLSDK (клиент + сервер)
echo "[4/6] Сборка Half-Life SDK..."
cd "$BUILD_DIR/hlsdk-portable"
./waf configure
./waf build

# 5. Сборка приложения
echo "[5/6] Сборка .app бандла..."
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

# HLSDK
cp "$BUILD_DIR/hlsdk-portable/build/cl_dll/client_amd64.dylib" "$INSTALL_DIR/Contents/Resources/valve/cl_dlls/"
cp "$BUILD_DIR/hlsdk-portable/build/dlls/hl_amd64.dylib" "$INSTALL_DIR/Contents/Resources/valve/dlls/"

# 6. Готово
echo "[6/6] Готово!"
echo ""
echo "Приложение: $INSTALL_DIR"
echo "Запуск: open $INSTALL_DIR"
