#!/bin/bash

echo "=== ЗАПУСК ПАТЧА КОНФИГУРАЦИИ BOARD.H ==="

# Находим точный конфигурационный файл для собираемого профиля WT3020
BOARD_H=$(find . -name "board.h" | grep -i "WT3020H16M" | grep -v "uboot" | head -n 1)

if [ -n "$BOARD_H" ] && [ -f "$BOARD_H" ]; then
    echo "FIRMWARE PATCH: Нашли файл конфигурации: $BOARD_H"
    
    # 1. Отключаем аппаратную логику светодиодов свитча
    sed -i 's/#define BOARD_NUM_ETH_EPHY.*/#define BOARD_NUM_ETH_EPHY     0/g' "$BOARD_H"
    sed -i 's/#define BOARD_HAS_EPHY_LNK.*/\/\/#define BOARD_HAS_EPHY_LNK/g' "$BOARD_H"
    sed -i 's/#define BOARD_HAS_EPHY_WLM.*/\/\/#define BOARD_HAS_EPHY_WLM/g' "$BOARD_H"
    
    # 2. Выставляем всем программным светодиодам значение -1 (Отключено)
    # Это отключит WAN_LED, LAN_LED, USB_LED и все остальные, прописанные в профиле
    sed -i 's/#define BOARD_GPIO_LED_WAN.*/#define BOARD_GPIO_LED_WAN    -1/g' "$BOARD_H"
    sed -i 's/#define BOARD_GPIO_LED_LAN.*/#define BOARD_GPIO_LED_LAN    -1/g' "$BOARD_H"
    sed -i 's/#define BOARD_GPIO_LED_WLAN.*/#define BOARD_GPIO_LED_WLAN   -1/g' "$BOARD_H"
    sed -i 's/#define BOARD_GPIO_LED_USB.*/#define BOARD_GPIO_LED_USB    -1/g' "$BOARD_H"
    sed -i 's/#define BOARD_GPIO_LED_ROUTER.*/#define BOARD_GPIO_LED_ROUTER -1/g' "$BOARD_H"
    
    # 3. Отключаем инверсию (на случай, если она заставляла пин гореть постоянно)
    sed -i 's/#define BOARD_GPIO_LED_INVERT.*/#define BOARD_GPIO_LED_INVERT  0/g' "$BOARD_H"

    echo "=== Проверка внесенных изменений в board.h ==="
    grep "BOARD_GPIO_LED_" "$BOARD_H"
    grep "BOARD_NUM_ETH_EPHY" "$BOARD_H"
else
    echo "FIRMWARE PATCH ERROR: Не удалось найти board.h для профиля WT3020!"
fi

echo "=== ЗАВЕРШЕНИЕ ПАТЧА КОНФИГУРАЦИИ BOARD.H ==="
