# Half-Life for macOS

Запуск **Half-Life**, **Opposing Force** и **Blue Shift** на macOS как нативное приложение.

Использует открытый движок [Xash3D FWGS](https://github.com/FWGS/xash3d-fwgs) — кроссплатформенную реализацию GoldSrc引擎, совместимую с оригинальным движком Half-Life.

## Что это даёт

- Нативное `.app` приложение — двойной клик в Finder
- Поддержка трёх игр: Half-Life, Opposing Force, Blue Shift
- OpenGL рендерер (и софтверный как запасной)
- Полная совместимость с оригинальными модами и картами
- Работает на macOS 10.13 High Sierra и новее
- Сетевая игра, голосовой чат, мастер-серверы

## Требования

| Компонент | Версия |
|-----------|--------|
| macOS | 10.13+ (High Sierra и новее) |
| Xcode | 15.2+ (полная версия, не Command Line Tools) |
| Python | 3.x |
| Homebrew | последняя |
| Half-Life | купленная в Steam (нужны файлы игры) |

## Установка

### Автоматическая сборка (рекомендуется)

```bash
git clone --recursive https://github.com/PrettyReal/xash3d-mac-build.git
cd xash3d-mac-build
chmod +x build.sh
./build.sh
```

Скрипт автоматически:
1. Скачает SDL2, Xash3D FWGS и Half-Life SDK
2. Соберёт движок и все три игры (valve, gearbox, bshift) в 64-bit
3. Создаст приложение `~/Half-Life.app`
4. Подключит ресурсы из Steam

### Запуск

```bash
open ~/Half-Life.app
```

Или двойной клик в Finder / Launchpad.

## Поддерживаемые игры

| Игра | Папка | Описание |
|------|-------|----------|
| Half-Life | `valve` | Оригинальная кампания |
| Opposing Force | `gearbox` | Дополнение от Gearbox |
| Blue Shift | `bshift` | Дополнение от Gearbox |

Все три игры требуют легальную копию Half-Life из Steam.

## Структура приложения

```
Half-Life.app/
├── Contents/
│   ├── Info.plist
│   ├── MacOS/
│   │   └── xash3d              ← лаунчер
│   ├── Frameworks/
│   │   ├── xash3d.bin            ← движок
│   │   ├── libxash.dylib         ← ядро движка
│   │   ├── libref_gl.dylib       ← OpenGL рендерер
│   │   ├── libref_soft.dylib     ← софт рендерер
│   │   ├── libmenu.dylib         ← главное меню
│   │   ├── filesystem_stdio.dylib
│   │   └── SDL2.framework
│   └── Resources/
│       └── valve/                ← ресурсы игры (симлинк на Steam)
```

## Решение проблем

### "couldn't find game directory valve"

Убедитесь что Half-Life установлена в Steam и папка существует:
```bash
ls ~/Library/Application\ Support/Steam/steamapps/common/Half-Life/
```

### Движок не запускается

Проверьте что Xcode установлен как полная версия:
```bash
xcode-select -p
# Должно быть: /Applications/Xcode.app/Contents/Developer
```

Если нет:
```bash
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
```

### Низкий FPS

Попробуйте софт-рендерер:
```bash
DYLD_LIBRARY_PATH=~/Half-Life.app/Contents/Frameworks \
    ~/Half-Life.app/Contents/Frameworks/xash3d.bin -renderer software
```

## Что собирается

| Компонент | Источник |
|-----------|----------|
| Xash3D FWGS | [github.com/FWGS/xash3d-fwgs](https://github.com/FWGS/xash3d-fwgs) |
| SDL2 | [github.com/libsdl-org/SDL](https://github.com/libsdl-org/SDL) (ветка SDL2) |
| HLSDK | [github.com/FWGS/hlsdk-portable](https://github.com/FWGS/hlsdk-portable) |

## Лицензия

- Движок Xash3D FWGS — [GNU GPL v2](https://www.gnu.org/licenses/old-licenses/gpl-2.0.html)
- Half-Life ресурсы — © Valve Corporation. Требуется легальная копия игры.

## Авторы

- [FWGS](https://github.com/FWGS) — авторы Xash3D FWGS
- [a1batross](https://github.com/a1batross) — мейнтейнер
