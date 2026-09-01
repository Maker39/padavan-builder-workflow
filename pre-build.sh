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

/* Назначение GPIO по схеме Kimax */
#define BOARD_GPIO_BTN_RESET	13
#undef  BOARD_GPIO_BTN_WPS

#define BOARD_GPIO_LED_WIFI	7
#define BOARD_GPIO_LED_POWER	14
#define BOARD_GPIO_LED_SATA	15

/* Настройки инверсии */
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

echo "=== 2. Безопасный патч общей логики инициализации портов ==="
BOARDS_C_FILE="padavan-ng/trunk/user/shared/boards.c"

if [ -f "$BOARDS_C_FILE" ]; then
    echo "Файл boards.c найден. Внедряем хак регистров для MT7620A..."
    # Находим функцию board_init и вставляем в её начало прямую запись в регистр pinmux (перевод пинов 14 и 15 в GPIO)
    # Используем синтаксис, понятный компилятору без сторонних библиотек
    sed -i '/void board_init(void)/!b;n;a \    *(volatile unsigned int *)(0xb0000060) &= ~(0x1F << 15);' "$BOARDS_C_FILE"
else
    echo "Предупреждение: boards.c не найден по этому пути."
fi

echo "=== Скрипт pre-build.sh успешно завершен ==="
