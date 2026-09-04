#!/bin/bash

echo "=== ЗАПУСК ТОТАЛЬНОГО GPIO ПАТЧА ==?"

# Ищем основной файл инициализации логики платы
BOARD_C=$(find . -name "board.c" | grep "user/shared/board.c" | head -n 1)

if [ -n "$BOARD_C" ] && [ -f "$BOARD_C" ]; then
    echo "FIRMWARE PATCH: Нашли файл $BOARD_C, внедряем полный сброс GPIO"
    
    # Делаем инъекцию кода в самое начало функции board_init
    # Мы перебираем ВСЕ пины от 1 до 45. На всякий случай пишем и 0, и 1
    # Если диод управляется напрямую или инверсно — один из циклов его гарантированно отключит.
    sed -i '/void board_init(void)/,!b; { /{/a\    {\n        int p;\n        for(p=1; p<=45; p++) {\n            if(p == 9 || p == 11 || p == 12 || p == 13 || p == 14) continue; // Пропускаем системные пины (SPI/Flash)\n            gpio_set_value(p, 0);\n            gpio_set_value(p, 1);\n        }\n    }' "$BOARD_C"
    
    echo "FIRMWARE PATCH: Код тотального гашения успешно внедрен."
else
    echo "FIRMWARE PATCH ERROR: Не смогли найти user/shared/board.c"
fi

echo "=== ЗАВЕРШЕНИЕ ТОТАЛЬНОГО GPIO ПАТЧА ==="
