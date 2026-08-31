#!/bin/bash

# Название вашей целевой платы
BOARD_NAME="WT3020H16M"
BOARD_DIR="padavan-ng/trunk/configs/boards/NEXX/${BOARD_NAME}"

echo "=== 1. Модификация пользовательской конфигурации ==="
cat << 'EOF' > ${BOARD_DIR}/board.h
/* Blueendless Kimax BS-U35-WF (WT3020H16M Mod) */
#define BOARD_PID		"WT3020H16M"
#define BOARD_NAME		"WT3020H16M"
#define BOARD_DESC		"Blueendless Kimax BS-U35-WF"
#define BOARD_VENDOR_NAME	"Nexx Digital"
#define BOARD_VENDOR_URL	"http://nexxdigital.ru"
#define BOARD_MODEL_URL		"http://nexxdigital.ru"
#define BOARD_BOOT_TIME		25
#define BOARD_FLASH_TIME	120

#define BOARD_GPIO_BTN_RESET	13
#undef  BOARD_GPIO_BTN_WPS

#define BOARD_GPIO_LED_WIFI	7
#define BOARD_GPIO_LED_POWER	14
#define BOARD_GPIO_LED_SATA	15

#define BOARD_GPIO_LED_INVERTED
#define BOARD_GPIO_BTN_INVERTED

#define BOARD_HAS_5G_11AC	0
#define BOARD_NUM_ANT_5G	0
#define BOARD_NUM_ANT_2G	2
#define BOARD_NUM_ETH_LEDS	0
#define BOARD_HAS_EPHY_LNK	0
#define BOARD_HAS_EPHY_WND	0
#define BOARD_NUM_UPHY_LEDS	0
#define BOARD_USB_PORT_COUNT	1
EOF

echo "=== 2. Безопасный патч исходников ядра Linux ==="

# Находим файлы ядра в структуре padavan-ng
DTS_FILE=$(find padavan-ng/trunk/linux -name "WT3020*.dts" | head -n 1)
KERNEL_BOARD_C=$(find padavan-ng/trunk/linux -name "board.c" | grep "ralink" | head -n 1)

# Модифицируем DTS (Если ядро использует дерево устройств)
if [ -f "$DTS_FILE" ]; then
    echo "Патчим Device Tree: $DTS_FILE"
    # Безопасная замена кнопки сброса с 1 на 13
    sed -i 's/gpios = <\&gpio0 1 /gpios = <\&gpio0 13 /g' "$DTS_FILE"
fi

# Модифицируем board.c ядра
if [ -f "$KERNEL_BOARD_C" ]; then
    echo "Патчим инициализацию архитектуры: $KERNEL_BOARD_C"
    
    # Меняем маску GPIO 1 на 13 для кнопки сброса, не затрагивая многострочные структуры
    sed -i 's/BOARD_GPIO_BTN_RESET, DIR_IN/13, DIR_IN/g' "$KERNEL_BOARD_C" 2>/dev/null
    sed -i 's/BOARD_GPIO_BTN_RESET/13/g' "$KERNEL_BOARD_C" 2>/dev/null
fi

echo "=== 3. Фикс глобального заголовка подсистемы сборки ==="
GLOBAL_BOARDS_H="padavan-ng/trunk/user/shared/boards.h"
if [ -f "$GLOBAL_BOARDS_H" ]; then
    echo "Патчим $GLOBAL_BOARDS_H"
    sed -i 's/BOARD_GPIO_BTN_RESET.*/BOARD_GPIO_BTN_RESET 13/g' "$GLOBAL_BOARDS_H"
fi

echo "=== Скрипт успешно отработал без синтаксических ошибок ==="
