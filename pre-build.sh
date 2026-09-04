# Внедряем код гашения GPIO в главный файл инициализации борды (board.c)
# Он отработает в самом конце загрузки ядра
BOARD_C="user/shared/board.c"

if [ -f "$BOARD_C" ]; then
    # Находим функцию board_init и сразу после её открытия ({) вставляем принудительный вывод в 0 для пинов 39-45
    sed -i '/void board_init(void)/,!b; { /{/a\    {\n        int p;\n        for(p=39; p<=45; p++) {\n            gpio_set_value(p, 0);\n        }\n    }' "$BOARD_C"
fi
