#!/bash/bin

echo "=== ФИНАЛЬНАЯ КОНФИГУРАЦИЯ KIMAX BS-U35WF В PADAVAN ==="

# 1. Находим файлы конфигурации платы WT3020H16M
BOARD_H=$(find . -name "board.h" | grep -i "WT3020" | grep -v "uboot" | head -n 1)
KERNEL_CONFIG=$(find . -name "kernel-3.4.x.config" | grep -i "WT3020" | head -n 1)

if [ -n "$BOARD_H" ] && [ -f "$BOARD_H" ]; then
    echo "ПАТЧ: Найдена конфигурация платы: $BOARD_H"
    
    # Объявляем 1 физический порт для коммутатора
    sed -i 's/#define BOARD_NUM_ETH_EPHY.*/#define BOARD_NUM_ETH_EPHY     1/g' "$BOARD_H"
    
    # Отключаем 5-портовую схему (она ломает роутинг на однопортовых платах)
    sed -i 's/#define BOARD_HAS_5P.*/\/\/#define BOARD_HAS_5P/g' "$BOARD_H"
    
    # Настройка аппаратных LED-линков встроенного свитча (чтобы диод мигал на Port 4)
    sed -i 's/#define BOARD_HAS_EPHY_LNK.*/#define BOARD_HAS_EPHY_LNK     1/g' "$BOARD_H"
    sed -i 's/#define BOARD_HAS_EPHY_WLM.*/#define BOARD_HAS_EPHY_WLM     1/g' "$BOARD_H"
    
    # Отключаем привязку светодиодов через чистое GPIO (чтобы не дублировать)
    sed -i 's/#define BOARD_GPIO_LED_WAN.*/#define BOARD_GPIO_LED_WAN     -1/g' "$BOARD_H"
    sed -i 's/#define BOARD_GPIO_LED_LAN.*/#define BOARD_GPIO_LED_LAN     -1/g' "$BOARD_H"
    sed -i 's/#define BOARD_GPIO_LED_INVERT.*/#define BOARD_GPIO_LED_INVERT  0/g' "$BOARD_H"
fi

if [ -n "$KERNEL_CONFIG" ] && [ -f "$KERNEL_CONFIG" ]; then
    echo "ПАТЧ: Найдена конфигурация ядра: $KERNEL_CONFIG"
    
    # Смена маппинга портов в драйвере raeth:
    # Делаем Port 4 (который физически распаян на Kimax) основным LAN портом прошивки
    sed -i 's/CONFIG_RAETH_ESW_PORT_WAN.*/CONFIG_RAETH_ESW_PORT_WAN=4/g' "$KERNEL_CONFIG"
    sed -i 's/CONFIG_RAETH_ESW_PORT_LAN1.*/CONFIG_RAETH_ESW_PORT_LAN1=4/g' "$KERNEL_CONFIG"
else
    echo "ВНИМАНИЕ: kernel-3.4.x.config не найден, маппинг портов через ядро может не примениться."
fi

echo "=== ЗАВЕРШЕНИЕ СБОРКИ KIMAX ==="
