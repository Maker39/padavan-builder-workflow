#!/bin/bash

echo "=== ФИНАЛЬНЫЙ СКРИПТ КОРРЕКЦИИ NVRAM ДЛЯ KIMAX ==="

BOARD_H=$(find . -name "board.h" | grep -i "WT3020" | grep -v "uboot" | head -n 1)
KERNEL_CONFIG=$(find . -name "kernel-3.4.x.config" | grep -i "WT3020" | head -n 1)
DEFAULTS_C=$(find . -name "defaults.c" | grep "user/shared" | head -n 1)

# 1. Корректируем базовые файлы (чтобы порт работал аппаратно)
if [ -n "$BOARD_H" ] && [ -f "$BOARD_H" ]; then
    sed -i 's/#define BOARD_NUM_ETH_EPHY.*/#define BOARD_NUM_ETH_EPHY     1/g' "$BOARD_H"
    sed -i 's/#define BOARD_HAS_5P.*/\/\/#define BOARD_HAS_5P/g' "$BOARD_H"
    sed -i 's/#define BOARD_GPIO_LED_LAN.*/#define BOARD_GPIO_LED_LAN     43/g' "$BOARD_H"
    sed -i 's/#define BOARD_GPIO_LED_WAN.*/#define BOARD_GPIO_LED_WAN     -1/g' "$BOARD_H"
    sed -i 's/#define BOARD_GPIO_LED_INVERT.*/#define BOARD_GPIO_LED_INVERT  1/g' "$BOARD_H"
fi

if [ -n "$KERNEL_CONFIG" ] && [ -f "$KERNEL_CONFIG" ]; then
    sed -i 's/CONFIG_RAETH_ESW_PORT_WAN.*/CONFIG_RAETH_ESW_PORT_WAN=4/g' "$KERNEL_CONFIG"
    sed -i 's/CONFIG_RAETH_ESW_PORT_LAN1.*/CONFIG_RAETH_ESW_PORT_LAN1=4/g' "$KERNEL_CONFIG"
fi

# 2. ИНЪЕКЦИЯ В NVRAM DEFAULTS: Перезаписываем генерацию заводских настроек
if [ -n "$DEFAULTS_C" ] && [ -f "$DEFAULTS_C" ]; then
    echo "ПАТЧ: Найдена генерация NVRAM: $DEFAULTS_C. Исправляем карту диодов..."
    
    # Меняем внутренние переменные Padavan, которые прописываются в веб-интерфейс при старте
    sed -i 's/{"lan_led",.*/{"lan_led", "43"},/g' "$DEFAULTS_C"
    sed -i 's/{"wan_led",.*/{"wan_led", "255"},/g' "$DEFAULTS_C" # 255 означает отключено в NVRAM
    sed -i 's/{"led_invert",.*/{"led_invert", "1"},/g' "$DEFAULTS_C"
fi

echo "=== ЗАВЕРШЕНИЕ СБОРКИ ==="
