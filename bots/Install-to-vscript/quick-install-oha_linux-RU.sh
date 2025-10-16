#!/bin/bash

set -euo pipefail

function error_exit {
    echo "============"
    echo "$1"
    echo "Общие рекомендации по устранению неисправностей:"
    echo "1. Убедитесь, что вы запускаете этот скрипт в папке: 'SteamLibrary/steamapps/workshop/content/570/3246316298/Install-to-vscript' (или эквивалентном пути в вашей библиотеке Steam)."
    echo "2. Если вы не знаете, где находится папка библиотеки Steam, щелкните правой кнопкой мыши на Dota 2 в библиотеке Steam, выберите Свойства > Установленные файлы > Просмотреть. Откроется папка: 'steamapps/common/dota 2 beta'. Оттуда вернитесь в 'steamapps', а затем перейдите в 'workshop/content/570/3246316298/Install-to-vscript'."
    echo "3. Если возникнут проблемы с разрешениями, убедитесь, что папки библиотеки Steam принадлежат вашему пользователю (например, выполните 'chown -R $USER:$USER /path/to/SteamLibrary', если нужно, заменив /path/to/SteamLibrary на ваш фактический путь). Команда chown рекурсивно изменяет владельца файлов и каталогов на указанного пользователя и группу (здесь — ваш текущий пользователь и группа)."
    echo "============"
    echo "Установка не удалась!!!"
    echo "============"
    exit 1
}

# Получить текущую временную метку (формат: YYYYMMDD_HHMMSS)
TIMESTAMP=$(date +%Y%m%d_%H%M%S) || error_exit "Не удалось сгенерировать временную метку."

# Получить директорию скрипта
SCRIPT_DIR=$(pwd) || error_exit "Не удалось определить текущую директорию."

# Директория элемента мастерской (родительская директория этого скрипта)
WORKSHOP_ITEM_DIR="$SCRIPT_DIR/.."
if [ ! -d "$WORKSHOP_ITEM_DIR" ]; then
    error_exit "Директория элемента мастерской не найдена: $WORKSHOP_ITEM_DIR. Убедитесь, что скрипт запущен из правильного места."
fi

# Проверить исходную папку Customize
if [ ! -d "$WORKSHOP_ITEM_DIR/Customize" ]; then
    error_exit "Исходная папка Customize не найдена в $WORKSHOP_ITEM_DIR."
fi

# Директория Dota 2 (предполагая стандартную структуру библиотеки Steam)
DOTA_DIR="$SCRIPT_DIR/../../../../../common/dota 2 beta"
if [ ! -d "$DOTA_DIR" ]; then
    error_exit "Директория установки Dota 2 не найдена: $DOTA_DIR. Проверьте путь к вашей библиотеке Steam и位置 скрипта."
fi

# Директория vscripts
VSCRIPTS_DIR="$DOTA_DIR/game/dota/scripts/vscripts"
if [ ! -d "$VSCRIPTS_DIR" ]; then
    error_exit "Директория vscripts Dota 2 не найдена: $VSCRIPTS_DIR. Убедитесь, что Dota 2 установлена правильно."
fi

# Целевые директории
BOTS_DIR="$VSCRIPTS_DIR/bots"
CUSTOMIZE_TARGET="$VSCRIPTS_DIR/game/Customize"
CUSTOMIZE_PARENT="$VSCRIPTS_DIR/game"
if [ ! -d "$CUSTOMIZE_PARENT" ]; then
    mkdir -p "$CUSTOMIZE_PARENT" || error_exit "Не удалось создать родительскую директорию для Customize: $CUSTOMIZE_PARENT."
fi

# Проверить, существует ли папка bots
if [ -d "$BOTS_DIR" ] || [ -L "$BOTS_DIR" ]; then
    echo "Папка bots или символьная ссылка уже существует, переименовывается в bots_old_$TIMESTAMP..."
    mv "$BOTS_DIR" "$VSCRIPTS_DIR/bots_old_$TIMESTAMP" || error_exit "Не удалось переименовать существующую директорию bots."
fi

echo "Создание символьной ссылки..."
ln -s "$WORKSHOP_ITEM_DIR" "$BOTS_DIR" || error_exit "Не удалось создать символьную ссылку для bots."

# Проверить, существует ли папка Customize
if [ -d "$CUSTOMIZE_TARGET" ] || [ -L "$CUSTOMIZE_TARGET" ]; then
    echo "Папка Customize уже существует, переименовывается в Customize_old_$TIMESTAMP..."
    mv "$CUSTOMIZE_TARGET" "$VSCRIPTS_DIR/game/Customize_old_$TIMESTAMP" || error_exit "Не удалось переименовать существующую директорию Customize."
fi

echo "Копирование папки Customize..."
cp -r "$WORKSHOP_ITEM_DIR/Customize/" "$CUSTOMIZE_TARGET" || error_exit "Не удалось скопировать папку Customize."

echo "============"
echo "Установка удалась!!!"
echo "============"
