# Half-Life (Xash3D FWGS) — macOS

Запуск Half-Life на macOS через движок [Xash3D FWGS](https://github.com/FWGS/xash3d-fwgs).

## Требования

- macOS 10.13+
- Xcode 15.2+ (нужен полный Xcode, не Command Line Tools)
- Python 3
- Homebrew

## Быстрая сборка

```bash
git clone --recursive https://github.com/USER/xash3d-mac-build.git
cd xash3d-mac-build
chmod +x build.sh
./build.sh
```

## Ручная установка ресурсов

После сборки нужно скопировать папку `valve` из купленной Half-Life (Steam) в:

```
/Applications/Half-Life.app/Contents/Resources/valve
```

Путь к Steam Half-Life:
```
~/Library/Application Support/Steam/steamapps/common/Half-Life/valve/
```

## Запуск

```bash
open /Applications/Half-Life.app
```

## Структура приложения

```
Half-Life.app/
├── Contents/
│   ├── Info.plist
│   ├── MacOS/xash3d              ← лаунчер
│   ├── Frameworks/
│   │   ├── xash3d.bin            ← движок
│   │   ├── libxash.dylib
│   │   ├── libref_gl.dylib       ← OpenGL
│   │   ├── libref_soft.dylib     ← софт рендерер
│   │   ├── libmenu.dylib
│   │   ├── filesystem_stdio.dylib
│   │   └── SDL2.framework
│   └── Resources/
│       └── valve/                ← ресурсы игры
```

## Лицензия

Xash3D FWGS — GNU GPL v2. Half-Life ресурсы принадлежат Valve.
