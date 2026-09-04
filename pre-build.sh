#!/bin/bash

echo "=== ЗАПУСК УНИВЕРСАЛЬНОГО GPIO ПАТЧА ==="

# Ищем БЕЗ привязки к жесткому пути user/shared/
BOARD_C=$(find . -name "board.c" | head -n 1)

if [ -n "$BOARD_C" ] && [ -f "$BOARD_C" ]; then
    echo "FIRMWARE PATCH: Нашли файл по пути: $BOARD_C"
    
    # Внедряем код гашения GPIO в функцию board_init
    # Исключаем пины SPI флешки (9-14), остальные переводим в безопасный режим
    sed -i '/void board_init(void)/,!b; { /{/a\    {\n        int p;\n        for(p=1; p<=45; p++) {\n            if(p >= 9 && p <= 14) continue;\n            gpio_set_value(p, 0);\n            gpio_set_value(p, 1);\n        }\n    }' "$BOARD_C"
    
    echo "FIRMWARE PATCH: Успешно внедрили Си-код."
else
    echo "FIRMWARE PATCH WARNING: board.c не найден. Пробуем альтернативный вариант с board.h..."
    
    # Если board.c спрятан глубоко, бьем по конфигурационным файлам плат
    BOARD_H=$(find . -name "board.h" | grep "WT3020" | head -n 1)
    if [ -n "$BOARD_H" ] && [ -f "$BOARD_H" ]; then
        echo "FIRMWARE PATCH: Нашли board.h: $BOARD_H"
        # Переопределяем все LED пины профиля в неактивное состояние (-1)
        sed -i 's/#define BOARD_GPIO_LED_.*/#define \0\n#undef \0\n#define \0 -1/g' "$BOARD_H"
    fi
fi

echo "=== ЗАВЕРШЕНИЕ УНИВЕРСАЛЬНОГО GPIO ПАТЧА ==="
