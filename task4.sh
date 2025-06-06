#!/bin/bash
set -e

# Изменяем базовый путь на домашний каталог пользователя
BASE_DIR="$HOME/srv/data"

units=$(systemctl list-unit-files --no-legend 'foobar-*' | awk '{print $1}')

if [ -z "$units" ]; then
    echo "Не найдено юнитов с именем 'foobar-*'"
    exit 0
fi

echo "Найдены следующие юниты:"
echo "$units"
echo ""

for unit in $units; do
    echo "Обработка юнита: $unit"
    service_name=${unit#foobar-}
    service_name=${service_name%.service}
    
    echo "Название сервиса: $service_name"
    echo "Остановка юнита $unit..."
    sudo systemctl stop "$unit"
    
    old_working_dir="/opt/misc/$service_name"
    new_working_dir="$BASE_DIR/$service_name"
    
    if [ ! -d "$old_working_dir" ]; then
        echo "Предупреждение: старая рабочая директория $old_working_dir не существует"
    else
        echo "Создание новой директории $new_working_dir..."
        mkdir -p "$new_working_dir"
        
        echo "Перенос файлов из $old_working_dir в $new_working_dir..."
        cp -a "$old_working_dir"/. "$new_working_dir"/
    fi
    
    unit_file="/etc/systemd/system/$unit"
    if [ ! -f "$unit_file" ]; then
        echo "Ошибка: файл юнита $unit_file не найден"
        continue
    fi
    
    backup_file="${unit_file}.bak"
    echo "Создание резервной копии конфига: $backup_file"
    sudo cp "$unit_file" "$backup_file"
    
    echo "Обновление путей в конфиге..."
    sudo sed -i "s|WorkingDirectory=/opt/misc/$service_name|WorkingDirectory=$BASE_DIR/$service_name|g" "$unit_file"
    sudo sed -i "s|ExecStart=/opt/misc/$service_name/|ExecStart=$BASE_DIR/$service_name/|g" "$unit_file"
    
    echo "Перечитывание конфигурации systemd..."
    sudo systemctl daemon-reload
    
    echo "Запуск юнита $unit..."
    sudo systemctl start "$unit"
    
    echo "Юнит $unit успешно обновлен и запущен"
    echo ""
done

echo "Все юниты обработаны успешно"