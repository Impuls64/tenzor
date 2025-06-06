#!/bin/bash
set -e

echo "=== Остановка и очистка тестовых юнитов ==="

# 1. Определяем список тестовых сервисов
SERVICES=("foobar-service1" "foobar-service2")

# 2. Остановка и отключение сервисов
echo "1. Останавливаем и отключаем сервисы..."
for service in "${SERVICES[@]}"; do
    if systemctl list-unit-files | grep -q "^${service}.service"; then
        echo "Останавливаем ${service}.service..."
        sudo systemctl stop "${service}.service" 2>/dev/null || true
        sudo systemctl disable "${service}.service" 2>/dev/null || true
    fi
done

# 3. Принудительное завершение именно демонов
echo "2. Завершаем процессы демонов..."
for service in "${SERVICES[@]}"; do
    # Ищем PID демонов по рабочей директории
    for pid in $(pgrep -f "/opt/misc/${service}/foobar-daemon" 2>/dev/null || true); do
        echo "Завершаем процесс демона ${service} (PID: $pid)"
        sudo kill -9 "$pid" 2>/dev/null || true
    done
    for pid in $(pgrep -f "/srv/data/${service}/foobar-daemon" 2>/dev/null || true); do
        echo "Завершаем процесс демона ${service} (PID: $pid)"
        sudo kill -9 "$pid" 2>/dev/null || true
    done
done

# 4. Обновление конфигурации systemd
echo "3. Обновляем конфигурацию systemd..."
sudo systemctl daemon-reload
sudo systemctl reset-failed

# 5. Удаление конфигурационных файлов
echo "4. Удаляем файлы конфигурации..."
for service in "${SERVICES[@]}"; do
    if [ -f "/etc/systemd/system/${service}.service" ]; then
        echo "Удаляем /etc/systemd/system/${service}.service"
        sudo rm -f "/etc/systemd/system/${service}.service"
    fi
done

# 6. Удаление рабочих директорий
echo "5. Удаляем рабочие директории..."
for service in "${SERVICES[@]}"; do
    for dir in "/opt/misc/${service}" "/srv/data/${service}" "/home/kali/srv/data/${service}"; do
        if [ -d "$dir" ]; then
            echo "Удаляем директорию $dir"
            sudo rm -rf "$dir"
        fi
    done
done

# 7. Очистка журналов
echo "6. Очищаем журналы..."
sudo journalctl --rotate
sudo journalctl --vacuum-time=1s 2>/dev/null || true

# Проверка результатов
echo ""
echo "=== Результаты очистки ==="
echo "Список юнитов:"
systemctl list-units 'foobar-*' 2>/dev/null || echo "Юниты не найдены"

echo ""
echo "Запущенные процессы демонов:"
found=0
for service in "${SERVICES[@]}"; do
    if pgrep -f "/opt/misc/${service}/foobar-daemon" >/dev/null || \
       pgrep -f "/srv/data/${service}/foobar-daemon" >/dev/null; then
        echo "Обнаружен работающий демон для ${service}:"
        pgrep -af "${service}"
        found=1
    fi
done
[ $found -eq 0 ] && echo "Демоны не найдены"

echo ""
echo "Остаточные файлы:"
found=0
for service in "${SERVICES[@]}"; do
    for dir in "/opt/misc/${service}" "/srv/data/${service}" "/home/kali/srv/data/${service}"; do
        if [ -d "$dir" ]; then
            echo "Найдена директория: $dir"
            found=1
        fi
    done
done
[ $found -eq 0 ] && echo "Остаточные файлы не найдены"

echo ""
echo "=== Очистка завершена ==="