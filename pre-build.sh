#!/bin/bash

# Указываем правильный путь с учетом папки репозитория прошивки
BOARD_H_PATH="rt-n56u/trunk/user/shared/boards/WT3020/board.h"
BOARD_C_PATH="rt-n56u/trunk/user/shared/boards/WT3020/board.c"

# Проверяем, существует ли файл, чтобы избежать падения sed
if [ -f "$BOARD_H_PATH" ]; then
    # 1. Меняем GPIO светодиода Ethernet на 44 и ставим инверсию (ACTIVE_LOW)
    sed -i 's/#define BOARD_GPIO_LED_ETH.*/#define BOARD_GPIO_LED_ETH          44/' $BOARD_H_PATH
    sed -i 's/#define BOARD_GPIO_LED_ETH_INV.*/#define BOARD_GPIO_LED_ETH_INV      1/' $BOARD_H_PATH

    # 2. Меняем GPIO кнопки Reset на 13 и ставим инверсию
    sed -i 's/#define BOARD_GPIO_BTN_RESET.*/#define BOARD_GPIO_BTN_RESET        13/' $BOARD_H_PATH
    sed -i 's/#define BOARD_GPIO_BTN_RESET_INV.*/#define BOARD_GPIO_BTN_RESET_INV    1/' $BOARD_H_PATH
else
    echo "Ошибка: Файл board.h не найден по пути $BOARD_H_PATH"
    exit 1
fi

if [ -f "$BOARD_C_PATH" ]; then
    # 3. Вставляем инициализацию PAD_MODE_NAND в board.c после открытия функции board_init(void)
    sed -i '/void board_init(void)/a \ \ \ \ mips_sys_set_padmode(PAD_MODE_NAND, PAD_MODE_GPIO);' $BOARD_C_PATH
else
    echo "Ошибка: Файл board.c не найден по пути $BOARD_C_PATH"
    exit 1
fi
