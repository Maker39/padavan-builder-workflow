#!/bin/bash

echo "=== Подмена ProductID для профиля MI-MINI ==="

# Автоматически находим файл board.h для профиля MI-MINI в исходниках
MINI_BOARD_H=$(find . -name "board.h" | grep "MI-MINI" | head -n 1)

if [ -f "$MINI_BOARD_H" ]; then
    echo "Файл board.h найден: $MINI_BOARD_H"
    
    # Меняем ProductID, чтобы веб-интерфейс WT3020 принял прошивку
    sed -i 's/define BOARD_PID.*/define BOARD_PID\t\t"WT3020H16M"/g' "$MINI_BOARD_H"
    sed -i 's/define BOARD_NAME.*/define BOARD_NAME\t\t"WT3020H16M"/g' "$MINI_BOARD_H"
    sed -i 's/define BOARD_DESC.*/define BOARD_DESC\t\t"Blueendless Kimax BS-U35-WF"/g' "$MINI_BOARD_H"
    
    echo "ProductID успешно изменен на WT3020H16M!"
else
    echo "Предупреждение: board.h для MI-MINI еще не распакован."
fi
