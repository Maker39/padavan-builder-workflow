#!/bin/bash

# Название вашей целевой платы
BOARD_NAME="WT3020H16M"
BOARD_DIR="padavan-ng/trunk/configs/boards/NEXX/${BOARD_NAME}"

echo "=== 1. Корректировка пользовательского board.h ==="
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

echo "=== 2. Принудительный патч ядра Linux (DTS и Пинмаппинг) ==="

# Находим файлы DTS ядра в структуре padavan-ng
DTS_FILE=$(find padavan-ng/trunk/linux -name "WT3020*.dts" | head -n 1)
KERNEL_BOARD_C=$(find padavan-ng/trunk/linux -name "board.c" | grep "ralink" | head -n 1)

# Модифицируем DTS (Если ядро padavan-ng использует dts)
if [ -f "$DTS_FILE" ]; then
    echo "Патчим Device Tree ядра: $DTS_FILE"
    # Меняем пин кнопки reset с 1 на 13
    sed -i 's/gpios = <\&gpio0 1 /gpios = <\&gpio0 13 /gpios = <\&gpio0 13 /g" "$DTS_FILE"
    # Перепривязываем светодиоды ядра
    sed -i 's/gpios = <\&gpio0 7 /gpios = <\&gpio0 7 /g' "$DTS_FILE"     # WiFi
    sed -i 's/gpios = <\&gpio0 14 /gpios = <\&gpio0 14 /g' "$DTS_FILE"   # Power
fi

# Самый важный шаг: Заменяем дефолтные маски в коде инициализации платформы ядра
if [ -f "$KERNEL_BOARD_C" ]; then
    echo "Патчим архитектурный файл ядра: $KERNEL_BOARD_C"
    
    # Отключаем режим EPHY_LED (светодиоды сетевых портов), который на MT7620 
    # по умолчанию захватывает GPIO 14 и 15, мешая им работать как обычные GPIO для LED.
    # Переводим функции пинов "ephy" в режим "gpio".
    sed -i 's/rt2880_pinmux_data/ \
    \/\* Взлом шины пинов под Kimax \*\/ \
    #define BOARD_GPIO_BTN_RESET 13 \
    #define BOARD_GPIO_LED_WIFI 7 \
    #define BOARD_GPIO_LED_POWER 14 \
    #define BOARD_GPIO_LED_SATA 15 \
    rt2880_pinmux_data/g' "$KERNEL_BOARD_C"

    # Делаем прямую замену физических констант WT3020 в исполняемом коде ядра
    sed -i 's/(1)/ (13) /g' "$KERNEL_BOARD_C"  # Меняем старый сброс (GPIO 1)
fi

echo "=== 3. Прошивка глобального заголовка boards.h ==="
GLOBAL_BOARDS_H="padavan-ng/trunk/user/shared/boards.h"
if [ -f "$GLOBAL_BOARDS_H" ]; then
    sed -i 's/BOARD_GPIO_BTN_RESET.*1/BOARD_GPIO_BTN_RESET 13/g' "$GLOBAL_BOARDS_H"
fi

echo "=== Скрипт инъекции GPIO отработал успешно! ==="
