#!/bin/bash

# Название вашей целевой платы
BOARD_NAME="WT3020H16M"
BOARD_DIR="padavan-ng/trunk/configs/boards/NEXX/${BOARD_NAME}"

echo "=== 1. Формирование чистого board.h под Kimax BS-U35-WF ==="
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

/* Принудительное переопределение GPIO аппаратного уровня */
#define BOARD_GPIO_BTN_RESET	13  /* Сброс на GPIO 13 */
#undef  BOARD_GPIO_BTN_WPS

#define BOARD_GPIO_LED_WIFI	7   /* Синий WiFi */
#define BOARD_GPIO_LED_POWER	14  /* Зеленый LAN */
#define BOARD_GPIO_LED_SATA	15  /* Красный/Оранжевый HDD */

/* Инверсия сигналов */
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

/* СИСТЕМНЫЙ ХАК: Принудительное освобождение GPIO 14 и 15 из регистров MT7620А */
/* Перенаправляем функции драйвера board_init на инициализацию регистров pinmux */
#define BOARD_INIT_CUSTOM                                                 \
    do {                                                                  \
        /* Чтение и модификация регистра PMX_EPHY_LED_AN (offset 0x60) */ \
        /* Переводим пины EPHY (14 и 15) в режим GPIO, отключая LED LAN */\
        *((volatile uint32_t *)(0xb0000060)) &= ~(0x1F << 15);            \
    } while (0)

EOF

echo "=== Скрипт подготовки успешно завершен! ==="
