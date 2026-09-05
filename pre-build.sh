#!/bin/bash

echo "=== ФИНАЛЬНЫЙ АППАРАТНЫЙ ПАТЧ PINMUX KIMAX ==="

# 1. Корректируем базовые файлы портов (чтобы LAN работал)
BOARD_H=$(find . -name "board.h" | grep -i "WT3020" | grep -v "uboot" | head -n 1)
KERNEL_CONFIG=$(find . -name "kernel-3.4.x.config" | grep -i "WT3020" | head -n 1)

if [ -n "$BOARD_H" ] && [ -f "$BOARD_H" ]; then
    sed -i 's/#define BOARD_NUM_ETH_EPHY.*/#define BOARD_NUM_ETH_EPHY     1/g' "$BOARD_H"
    sed -i 's/#define BOARD_HAS_5P.*/\/\/#define BOARD_HAS_5P/g' "$BOARD_H"
    sed -i 's/#define BOARD_GPIO_LED_LAN.*/#define BOARD_GPIO_LED_LAN     43/g' "$BOARD_H"
    sed -i 's/#define BOARD_GPIO_LED_WAN.*/#define BOARD_GPIO_LED_WAN     -1/g' "$BOARD_H"
    sed -i 's/#define BOARD_GPIO_LED_INVERT.*/#define BOARD_GPIO_LED_INVERT  1/g' "$BOARD_H"
    sed -i 's/#define BOARD_HAS_EPHY_LNK.*/#define BOARD_HAS_EPHY_LNK     0/g' "$BOARD_H"
    sed -i 's/#define BOARD_HAS_EPHY_WLM.*/#define BOARD_HAS_EPHY_WLM     0/g' "$BOARD_H"
fi

if [ -n "$KERNEL_CONFIG" ] && [ -f "$KERNEL_CONFIG" ]; then
    sed -i 's/CONFIG_RAETH_ESW_PORT_WAN.*/CONFIG_RAETH_ESW_PORT_WAN=4/g' "$KERNEL_CONFIG"
    sed -i 's/CONFIG_RAETH_ESW_PORT_LAN1.*/CONFIG_RAETH_ESW_PORT_LAN1=4/g' "$KERNEL_CONFIG"
fi

# 2. ГЛУБОКИЙ ПАТЧ ЯДРА: Ищем файлы управления pinctrl/pinmux для чипа MT7620
# Мы заменяем функцию включения EPHY_LED на режим GPIO, чтобы процессор отпустил эту группу ног
CHIP_MT7620=$(find . -name "chip-mt7620.c" -o -name "mt7620.c" | head -n 1)

if [ -n "$CHIP_MT7620" ] && [ -f "$CHIP_MT7620" ]; then
    echo "ПАТЧ: Найдена инициализация чипа: $CHIP_MT7620. Отключаем аппаратную маску EPHY_LED..."
    # Заменяем принудительную инициализацию ephy led функций на gpio режим
    sed -i 's/rt_sysc_w32(mar, MT7620_SYSC_REG_GPIO_MODE);/\/\/ Отключено для Kimax/g' "$CHIP_MT7620" 2>/dev/null
    sed -i 's/pinctrl_init_ephy_led/pinctrl_init_gpio/g' "$CHIP_MT7620" 2>/dev/null
fi

echo "=== ЗАВЕРШЕНИЕ СБОРКИ ==="
