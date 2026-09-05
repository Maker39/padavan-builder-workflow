#!/bin/bash

echo "=== ФИНАЛЬНАЯ КОРРЕКЦИЯ СВЕТОДИОДА KIMAX ==="

BOARD_H=$(find . -name "board.h" | grep -i "WT3020" | grep -v "uboot" | head -n 1)
KERNEL_CONFIG=$(find . -name "kernel-3.4.x.config" | grep -i "WT3020" | head -n 1)

if [ -n "$BOARD_H" ] && [ -f "$BOARD_H" ]; then
    echo "ПАТЧ: Найдена конфигурация платы: $BOARD_H"
    
    sed -i 's/#define BOARD_NUM_ETH_EPHY.*/#define BOARD_NUM_ETH_EPHY     1/g' "$BOARD_H"
    sed -i 's/#define BOARD_HAS_5P.*/\/\/#define BOARD_HAS_5P/g' "$BOARD_H"
    
    # 1. ОТКЛЮЧАЕМ аппаратный контроль линков свитча (он заставляет диод гореть)
    sed -i 's/#define BOARD_HAS_EPHY_LNK.*/\/\/#define BOARD_HAS_EPHY_LNK     0/g' "$BOARD_H"
    sed -i 's/#define BOARD_HAS_EPHY_WLM.*/\/\/#define BOARD_HAS_EPHY_WLM     0/g' "$BOARD_H"
    
    # 2. НАЗНАЧАЕМ LAN-диод на GPIO 43 (как в OpenWrt для Kimax)
    sed -i 's/#define BOARD_GPIO_LED_LAN.*/#define BOARD_GPIO_LED_LAN     43/g' "$BOARD_H"
    sed -i 's/#define BOARD_GPIO_LED_WAN.*/#define BOARD_GPIO_LED_WAN     -1/g' "$BOARD_H"
    
    # 3. Настройка инверсии: если диод будет гореть без кабеля и тухнуть с кабелем,
    # мы поменяем этот параметр. Пока ставим 1 (инвертировано, стандарт для MT7620)
    sed -i 's/#define BOARD_GPIO_LED_INVERT.*/#define BOARD_GPIO_LED_INVERT  1/g' "$BOARD_H"
fi

if [ -n "$KERNEL_CONFIG" ] && [ -f "$KERNEL_CONFIG" ]; then
    sed -i 's/CONFIG_RAETH_ESW_PORT_WAN.*/CONFIG_RAETH_ESW_PORT_WAN=4/g' "$KERNEL_CONFIG"
    sed -i 's/CONFIG_RAETH_ESW_PORT_LAN1.*/CONFIG_RAETH_ESW_PORT_LAN1=4/g' "$KERNEL_CONFIG"
fi

echo "=== ЗАВЕРШЕНИЕ СБОРКИ ==="
