#!/bin/bash

echo "=== ФИНАЛЬНАЯ НАСТРОЙКА ИНДИКАЦИИ KIMAX ==="

BOARD_H=$(find . -name "board.h" | grep -i "WT3020" | grep -v "uboot" | head -n 1)
KERNEL_CONFIG=$(find . -name "kernel-3.4.x.config" | grep -i "WT3020" | head -n 1)

if [ -n "$BOARD_H" ] && [ -f "$BOARD_H" ]; then
    echo "ПАТЧ: Найдена конфигурация платы: $BOARD_H"
    
    sed -i 's/#define BOARD_NUM_ETH_EPHY.*/#define BOARD_NUM_ETH_EPHY     1/g' "$BOARD_H"
    sed -i 's/#define BOARD_HAS_5P.*/\/\/#define BOARD_HAS_5P/g' "$BOARD_H"
    
    # 1. Возвращаем программные LED в отключенное состояние -1
    # Это заставит ядро Padavan полностью отпустить пины и не зажигать их в конце загрузки
    sed -i 's/#define BOARD_GPIO_LED_LAN.*/#define BOARD_GPIO_LED_LAN    -1/g' "$BOARD_H"
    sed -i 's/#define BOARD_GPIO_LED_WAN.*/#define BOARD_GPIO_LED_WAN    -1/g' "$BOARD_H"
    
    # 2. Переводим диод в режим аппаратного линка свитча (BOARD_HAS_EPHY_LNK)
    # В Padavan значение "1" заставляет свитч автоматически привязать индикацию к активному физическому порту
    sed -i 's/#define BOARD_HAS_EPHY_LNK.*/#define BOARD_HAS_EPHY_LNK     1/g' "$BOARD_H"
    sed -i 's/#define BOARD_HAS_EPHY_WLM.*/#define BOARD_HAS_EPHY_WLM     1/g' "$BOARD_H"
    
    # Возвращаем инверсию в 1, так как при ней он хотя бы мигал при старте
    sed -i 's/#define BOARD_GPIO_LED_INVERT.*/#define BOARD_GPIO_LED_INVERT  1/g' "$BOARD_H"
fi

if [ -n "$KERNEL_CONFIG" ] && [ -f "$KERNEL_CONFIG" ]; then
    # Наш маппинг порта, который уже оживил LAN-интерфейс
    sed -i 's/CONFIG_RAETH_ESW_PORT_WAN.*/CONFIG_RAETH_ESW_PORT_WAN=4/g' "$KERNEL_CONFIG"
    sed -i 's/CONFIG_RAETH_ESW_PORT_LAN1.*/CONFIG_RAETH_ESW_PORT_LAN1=4/g' "$KERNEL_CONFIG"
fi

echo "=== ЗАВЕРШЕНИЕ СБОРКИ ==="
