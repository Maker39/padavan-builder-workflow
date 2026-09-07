#!/bin/bash

# Путь к папке вашей платы в исходниках Padavan (замените WT3020 на имя вашего профиля, если оно другое)
BOARD_DIR="configs/boards/NEXX/WT3020H16M"

# 1. Меняем GPIO светодиода Ethernet на 44 в board.h
sed -i 's/#define BOARD_GPIO_LED_ETH.*/#define BOARD_GPIO_LED_ETH          44/' "$BOARD_DIR/board.h"
sed -i 's/#define BOARD_GPIO_LED_ETH_INV.*/#define BOARD_GPIO_LED_ETH_INV      1/' "$BOARD_DIR/board.h"

# 2. Меняем GPIO кнопки Reset на 13 в board.h
sed -i 's/#define BOARD_GPIO_BTN_RESET.*/#define BOARD_GPIO_BTN_RESET        13/' "$BOARD_DIR/board.h"
sed -i 's/#define BOARD_GPIO_BTN_RESET_INV.*/#define BOARD_GPIO_BTN_RESET_INV    1/' "$BOARD_DIR/board.h"

# 3. Вставляем инициализацию PAD_MODE_NAND в начало функции board_init в board.c
# Это освободит банк gpio2 для работы светодиода на SPI Flash устройствах
sed -i '/void board_init(void)/!b;n;a\    mips_sys_set_padmode(PAD_MODE_NAND, PAD_MODE_GPIO);' "$BOARD_DIR/board.c"
