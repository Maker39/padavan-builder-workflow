#!/bin/bash

# Название конфигурационного файла вашей платы в репозитории
BOARD_NAME="WT3020H16M"
BOARD_DIR="padavan-ng/trunk/configs/boards/NEXX/${BOARD_NAME}"

echo "=== Скрипт pre_build.sh: Настройка WT3020H16M под Flash 32MB ==="

# 1. Проверяем путь к конфигурации платы
if [ ! -d "$BOARD_DIR" ]; then
    # Резервный путь, если в форке изменена структура каталогов
    BOARD_DIR="padavan-ng/trunk/configs/boards/${BOARD_NAME}"
fi

if [ -d "$BOARD_DIR" ]; then
    echo "Каталог платы найден: $BOARD_DIR"
    
    # 2. Увеличиваем лимит размера прошивки для GitHub Actions, чтобы сборщик не выдавал ошибку размера.
    # Задаем максимальный размер ~31 МБ (32505856 байт), оставляя место под Breed и Factory в конце.
    if [ -f "$BOARD_DIR/board.config" ]; then
        echo "Корректируем board.config..."
        sed -i 's/CONFIG_FIRMWARE_MAX_SIZE=.*/CONFIG_FIRMWARE_MAX_SIZE=32505856/g' "$BOARD_DIR/board.config"
    fi

    # 3. Переразмечаем MTD-разделы под чип 32МБ (256 Мбит) в partitions.config.
    # В Breed разметка Factory находится в самом конце памяти, поэтому смещаем адреса разделов firmware и storage.
    # Подменяем старые шестнадцатеричные лимиты 16МБ флэша (0xF70000 / 0xFC0000) на новые для 32МБ (0x1F70000 / 0x1FC0000).
    if [ -f "$BOARD_DIR/partitions.config" ]; then
        echo "Модифицируем карту разделов partitions.config..."
        sed -i 's/0x770000/0x1F70000/g' "$BOARD_DIR/partitions.config"
        sed -i 's/0x7C0000/0x1FC0000/g' "$BOARD_DIR/partitions.config"
        sed -i 's/0xF70000/0x1F70000/g' "$BOARD_DIR/partitions.config"
        sed -i 's/0xFC0000/0x1FC0000/g' "$BOARD_DIR/partitions.config"
    fi
    
    echo "Конфигурационные файлы успешно изменены."
else
    echo "Ошибка: Не удалось найти директорию конфигурации платы WT3020H16M!"
    exit 1
fi

echo "=== pre_build.sh успешно выполнен ==="
