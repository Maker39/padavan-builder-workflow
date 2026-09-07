#!/bin/bash

# Находим путь к файлу board.h для выбранного профиля платы (например, WT3020)
# В зависимости от базового конфига, замените WT3020 на имя вашей целевой платы, если выбрали другую
BOARD_H_PATH="trunk/user/shared/boards/WT3020H16M/board.h"
BOARD_C_PATH="trunk/user/shared/boards/WT3020H16M/board.c"

# 1. Меняем GPIO светодиода Ethernet на 44
sed -i 's/#define BOARD_GPIO_LED_ETH.*/#define BOARD_GPIO_LED_ETH          44/' $BOARD_H_PATH
sed -i 's/#define BOARD_GPIO_LED_ETH_INV.*/#define BOARD_GPIO_LED_ETH_INV      1/' $BOARD_H_PATH

# 2. Меняем GPIO кнопки Reset на 13
sed -i 's/#define BOARD_GPIO_BTN_RESET.*/#define BOARD_GPIO_BTN_RESET        13/' $BOARD_H_PATH
sed -i 's/#define BOARD_GPIO_BTN_RESET_INV.*/#define BOARD_GPIO_BTN_RESET_INV    1/' $BOARD_H_PATH

# 3. Добавляем освобождение банка пинов (PAD_MODE_NAND -> GPIO) в board.c
# Вставляем команду инициализации сразу после открытия главной функции board_init
sed -i '/void board_init(void)/!b;n;a\    mips_sys_set_padmode(PAD_MODE_NAND, PAD_MODE_GPIO);' $BOARD_C_PATH
