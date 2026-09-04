#!/bin/bash

echo "=== ЗАПУСК КАСТОМНОГО СКРИПТА МОДИФИКАЦИИ ==="

# 1. Корректно определяем путь к конфигурации платы WT3020H16M в padavan-ng
# find ищет файл board.h по всему дереву, независимо от того, в какой папке мы находимся
BOARD_H=$(find . -name "board.h" | grep "WT3020H16M" | head -n 1)

if [ -n "$BOARD_H" ] && [ -f "$BOARD_H" ]; then
    echo "FIRMWARE PATCH: Найдена конфигурация платы: $BOARD_H"
    
    # Полностью отключаем встроенную LED-логику коммутатора MediaTek для этой платы
    # Меняем BOARD_NUM_ETH_EPHY на 0
    sed -i 's/#define BOARD_NUM_ETH_EPHY.*/#define BOARD_NUM_ETH_EPHY     0/g' "$BOARD_H"
    
    # На всякий случай зачищаем остальные триггеры линков EPHY
    sed -i 's/#define BOARD_HAS_EPHY_LNK.*/\/\/#define BOARD_HAS_EPHY_LNK/g' "$BOARD_H"
    sed -i 's/#define BOARD_HAS_EPHY_WLM.*/\/\/#define BOARD_HAS_EPHY_WLM/g' "$BOARD_H"
    
    echo "=== Сводка изменений в board.h ==="
    grep "BOARD_NUM_ETH_EPHY" "$BOARD_H"
else
    echo "FIRMWARE PATCH ERROR: Не удалось найти файл board.h для профиля WT3020H16M!"
fi

echo "=== ЗАВЕРШЕНИЕ КАСТОМНОГО СКРИПТА МОДИФИКАЦИИ ==="
