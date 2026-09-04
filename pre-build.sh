# Пути к конфигурационным файлам ядра (актуально для большинства форков Padavan)
KERNEL_DEFCONFIG="linux-3.4/arch/mips/configs/rt288x_defconfig"
KERNEL_CONFIG="linux-3.4/.config"

# Включаем CONFIG_GPIO_SYSFS в шаблоне конфигурации
if [ -f "$KERNEL_DEFCONFIG" ]; then
    sed -i 's/# CONFIG_GPIO_SYSFS is not set/CONFIG_GPIO_SYSFS=y/g' "$KERNEL_DEFCONFIG"
    # На всякий случай проверяем, если строки не было — добавляем в конец
    grep -q "CONFIG_GPIO_SYSFS=y" "$KERNEL_DEFCONFIG" || echo "CONFIG_GPIO_SYSFS=y" >> "$KERNEL_DEFCONFIG"
fi

# Включаем CONFIG_GPIO_SYSFS в текущем рабочем конфиге сборки
if [ -f "$KERNEL_CONFIG" ]; then
    sed -i 's/# CONFIG_GPIO_SYSFS is not set/CONFIG_GPIO_SYSFS=y/g' "$KERNEL_CONFIG"
    grep -q "CONFIG_GPIO_SYSFS=y" "$KERNEL_CONFIG" || echo "CONFIG_GPIO_SYSFS=y" >> "$KERNEL_CONFIG"
fi
