#!/bin/bash

BOARD_H=$(find . -name "board.h" | grep -i "WT3020H16M" | grep -v "uboot" | head -n 1)

if [ -n "$BOARD_H" ] && [ -f "$BOARD_H" ]; then
    # 1. Возвращаем 1 рабочий порт в систему
    sed -i 's/#define BOARD_NUM_ETH_EPHY.*/#define BOARD_NUM_ETH_EPHY     1/g' "$BOARD_H"
    
    # 2. Переключаем конфигурацию встроенного коммутатора на схему с одним общим LAN портом (как у Kimax)
    # Вместо схемы WAN+LAN активируем режим, где единственный порт привязан к внутренней шине без разделения VLAN
    sed -i 's/#define BOARD_HAS_5P.*/\/\/#define BOARD_HAS_5P/g' "$BOARD_H"
    
    # 3. Восстанавливаем оригинальные светодиоды (убираем наши -1 из прошлых тестов, если они остались)
    sed -i 's/#define BOARD_GPIO_LED_LAN.*/#define BOARD_GPIO_LED_LAN    -1/g' "$BOARD_H" 
    # Часто LAN-диод на Kimax — это физический светодиод WAN-порта от WT3020. Попробуем переназначить его:
    sed -i 's/#define BOARD_GPIO_LED_WAN.*/#define BOARD_GPIO_LED_WAN     43/g' "$BOARD_H" # Тестовый пин оригинального WAN LED
fi
