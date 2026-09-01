#!/bin/bash

# Название вашей целевой платы
BOARD_NAME="WT3020H16M"
BOARD_DIR="padavan-ng/trunk/configs/boards/NEXX/${BOARD_NAME}"

echo "=== Создание директории платы (на случай, если исходники еще не скачаны) ==="
mkdir -p "${BOARD_DIR}"

echo "=== Формирование чистого board.h под Kimax BS-U35-WF ==="
cat << 'EOF' > "${BOARD_DIR}/board.h"
/* Blueendless Kimax BS-U35-WF (WT3020H16M Mod) */
#define BOARD_PID		"WT3020H16M"
#define BOARD_NAME		"WT3020H16M"
#define BOARD_DESC		"Blueendless Kimax BS-U35-WF"
#define BOARD_VENDOR_NAME	"Nexx Digital"
#define BOARD_VENDOR_URL	"http://nexxdigital.ru"
#define BOARD_MODEL_URL		"http://nexxdigital.ru"
#define BOARD_BOOT_TIME		25
#define BOARD_FLASH_TIME	120

/* Назначение GPIO по схеме Kimax BS-U35-WF */
#define BOARD_GPIO_BTN_RESET	13  /* Физическая кнопка Reset */
#undef  BOARD_GPIO_BTN_WPS

#define BOARD_GPIO_LED_WIFI	7   /* Синий WiFi LED */
#define BOARD_GPIO_LED_POWER	14  /* Зеленый LAN/Power LED */

/* Настройки инверсии (Active Low для Kimax) */
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

echo "=== Проверка: Файл board.h успешно создан ==="
ls -la "${BOARD_DIR}"
