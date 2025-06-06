#!/bin/bash

# Скрипт для переноса systemd юнитов и обновления их путей

set -e

# Получаем список всех юнитов, начинающихся с 'foobar-'
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
    
    # Получаем название сервиса из имени юнита
    service_name=${unit#foobar-}
    service_name=${service_name%.service}
    
    echo "Название сервиса: $service_name"
    
    # Останавливаем юнит
    echo "Остановка юнита $unit..."
    systemctl stop "$unit"
    
    # Определяем текущие пути
    old_working_dir="/opt/misc/$service_name"
    new_working_dir="/srv/data/$service_name"
    
    # Проверяем существование старой директории
    if [ ! -d "$old_working_dir" ]; then
        echo "Предупреждение: старая рабочая директория $old_working_dir не существует"
    else
        # Создаем новую директорию
        echo "Создание новой директории $new_working_dir..."
        mkdir -p "$new_working_dir"
        
        # Переносим файлы
        echo "Перенос файлов из $old_working_dir в $new_working_dir..."
        cp -a "$old_working_dir"/. "$new_working_dir"/
        
        # Удаляем старую директорию (опционально)
        # echo "Удаление старой директории..."
        # rm -rf "$old_working_dir"
    fi
    
    # Получаем текущий конфиг юнита
    unit_file="/etc/systemd/system/$unit"
    if [ ! -f "$unit_file" ]; then
        echo "Ошибка: файл юнита $unit_file не найден"
        continue
    fi
    
    # Создаем резервную копию
    backup_file="${unit_file}.bak"
    echo "Создание резервной копии конфига: $backup_file"
    cp "$unit_file" "$backup_file"
    
    # Обновляем пути в конфиге
    echo "Обновление путей в конфиге..."
    sed -i "s|WorkingDirectory=/opt/misc/$service_name|WorkingDirectory=/srv/data/$service_name|g" "$unit_file"
    sed -i "s|ExecStart=/opt/misc/$service_name/|ExecStart=/srv/data/$service_name/|g" "$unit_file"
    
    # Перечитываем конфигурацию systemd
    echo "Перечитывание конфигурации systemd..."
    systemctl daemon-reload
    
    # Запускаем юнит
    echo "Запуск юнита $unit..."
    systemctl start "$unit"
    
    echo "Юнит $unit успешно обновлен и запущен"
    echo ""
done

echo "Все юниты обработаны успешно"