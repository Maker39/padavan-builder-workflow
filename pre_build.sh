#!/bin/bash

BOARD_NAME="WT3020H16M"
BOARD_DIR="padavan-ng/trunk/configs/boards/NEXX/${BOARD_NAME}"

echo "=== 1. Перезапись board.h ==="
cat << 'EOF' > ${BOARD_DIR}/board.h
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

echo "=== 2. Принудительный хак инициализации GPIO в ядре Padavan ==="
# Папка с исходниками ядра ралинк (путь может отличаться в зависимости от версии ядра 3.4/4.4, ищем в trunk/linux)
KERNEL_BOARD_C=$(find padavan-ng/trunk/linux -name "board.c" | grep "ralink" | head -n 1)

if [ -f "$KERNEL_BOARD_C" ]; then
    echo "Найден файл инициализации ядра: $KERNEL_BOARD_C"
    
    # Жестко подменяем вызовы инициализации GPIO перед сборкой ядра модуля
    # Очищаем старые привязки WT3020 (обычно там GPIO 1 и GPIO 13/14 в других режимах)
    sed -i 's/BOARD_GPIO_BTN_RESET/13/g' "$KERNEL_BOARD_C"
    sed -i 's/BOARD_GPIO_LED_WIFI/7/g' "$KERNEL_BOARD_C"
    sed -i 's/BOARD_GPIO_LED_POWER/14/g' "$KERNEL_BOARD_C"
    sed -i 's/BOARD_GPIO_LED_SATA/15/g' "$KERNEL_BOARD_C"
else
    echo "Предупреждение: Файл board.c в ядре не найден. Пробуем переписать дефайны в общих заголовках..."
fi

# 3. На всякий случай фиксим общий файл с дефайнами плат, если он используется
BOARDS_H="padavan-ng/trunk/user/shared/boards.h"
if [ -f "$BOARDS_H" ]; then
    echo "Корректируем глобальный boards.h"
    sed -i 's/define BOARD_GPIO_BTN_RESET.*/define BOARD_GPIO_BTN_RESET 13/g' "$BOARDS_H"
fi

echo "=== Изменения GPIO применены! ==="
