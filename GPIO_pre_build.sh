#!/bin/bash

# Точный путь к целевой плате в padavan-ng
BOARD_NAME="WT3020H16M"
BOARD_DIR="padavan-ng/trunk/configs/boards/NEXX/${BOARD_NAME}"

echo "=== Модификация WT3020H16M под Kimax BS-U35-WF ==="

# Полностью перезаписываем board.h для правильного назначения GPIO
cat << 'EOF' > ${BOARD_DIR}/board.h
/* Blueendless Kimax BS-U35-WF (Based on WT3020H16M Profile) */

#define BOARD_PID		"WT3020H16M"
#define BOARD_NAME		"WT3020H16M"
#define BOARD_DESC		"NEXX WT3020H (16MB Flash)"
#define BOARD_VENDOR_NAME	"Nexx Digital"
#define BOARD_VENDOR_URL	"http://nexxdigital.ru"
#define BOARD_MODEL_URL		"http://nexxdigital.ru"
#define BOARD_BOOT_TIME		25
#define BOARD_FLASH_TIME	120

/* Переназначение кнопок и диодов по схеме OpenWrt */
#define BOARD_GPIO_BTN_RESET	13  /* Сброс на GPIO 13 вместо GPIO 1 */
#undef  BOARD_GPIO_BTN_WPS

#define BOARD_GPIO_LED_WIFI	7   /* Синий WiFi LED на GPIO 7 */
#define BOARD_GPIO_LED_POWER	14  /* Зеленый LAN LED на GPIO 14 (как системный) */
#define BOARD_GPIO_LED_SATA	15  /* Красный/Оранжевый HDD LED на GPIO 15 */

/* Инверсия (Active Low) */
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

echo "=== Файл board.h успешно перезаписан ==="
