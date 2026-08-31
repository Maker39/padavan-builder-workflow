#!/bin/bash

# Название целевой платы
BOARD_NAME="WT3020H16M"
BOARD_DIR="padavan-ng/trunk/configs/boards/NEXX/${BOARD_NAME}"

echo "=== 1. Перезапись пользовательского board.h ==="
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

echo "=== 2. Корректировка дерева устройств DTS ядра ==="

# Находим точный файл DTS для WT3020 в ядре Linux
DTS_FILE=$(find padavan-ng/trunk/linux -name "WT3020*.dts" | head -n 1)

if [ -f "$DTS_FILE" ]; then
    echo "DTS файл найден: $DTS_FILE. Переписываем структуру пинов."
    
    cat << 'EOF' > "$DTS_FILE"
/dts-v1/;

/include/ "mt7620a.dtsi"

/ {
	compatible = "nexx,wt3020", "ralink,mt7620a-soc";
	model = "Blueendless Kimax BS-U35-WF";

	gpio-leds {
		compatible = "gpio-leds";

		wifi {
			label = "wt3020:blue:wifi";
			gpios = <&gpio0 7 1>;
		};

		power {
			label = "wt3020:blue:power";
			gpios = <&gpio0 14 1>;
		};
	};

	gpio-keys-polled {
		compatible = "gpio-keys-polled";
		#address-cells = <1>;
		#size-cells = <0>;
		poll-interval = <20>;

		reset {
			label = "reset";
			gpios = <&gpio0 13 1>;
			linux,code = <0x102>;
		};
	};
};

&gpio0 {
	status = "okay";
};

&pinctrl {
	state_default: pinctrl0 {
		gpio {
			ralink,group = "ephy", "wled";
			ralink,function = "gpio";
		};
	};
};

&ethernet {
	mtd-mac-address = <&factory 0x4>;
	ralink,port-map = "llllw";
};

&wmac {
	ralink,mtd-eeprom = <&factory 0>;
};

&ehci {
	status = "okay";
};

&ohci {
	status = "okay";
};
EOF
    echo "DTS успешно заменен."
else
    echo "ОШИБКА: DTS файл не найден в структуре директорий!"
fi

echo "=== Скрипт подготовки выполнен без использования опасных sed ==="
