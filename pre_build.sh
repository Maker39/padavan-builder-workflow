#!/bin/bash

# Находим точный путь к board.c в структуре папок padavan-ng
BOARD_C=$(find . -name "board.c" | grep "user/shared/board.c" | head -n 1)

if [ -n "$BOARD_C" ] && [ -f "$BOARD_C" ]; then
    echo "FIRMWARE PATCH: Нашли файл $BOARD_C, внедряем гашение GPIO!"
    
    # Делаем инъекцию кода в функцию board_init (гасим пины 39-45)
    sed -i '/void board_init(void)/,!b; { /{/a\    {\n        int p;\n        for(p=39; p<=45; p++) {\n            gpio_set_value(p, 0);\n        }\n    }' "$BOARD_C"
else
    echo "FIRMWARE PATCH ERROR: Не смогли найти файл user/shared/board.c!"
fi
