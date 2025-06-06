#!/bin/bash
set -e

echo "=== Создание тестовых сервисов и рабочих директорий ==="
sudo mkdir -p /opt/misc/service1 /opt/misc/service2

echo "=== Создание демон-скриптов ==="
sudo tee /opt/misc/service1/foobar-daemon <<'EOF'
#!/bin/bash
while true; do
    echo "Service1 is running $(date)" >> /opt/misc/service1/service.log
    sleep 5
done
EOF

sudo tee /opt/misc/service2/foobar-daemon <<'EOF'
#!/bin/bash
while true; do
    echo "Service2 is running $(date)" >> /opt/misc/service2/service.log
    sleep 10
done
EOF

sudo chmod +x /opt/misc/service1/foobar-daemon /opt/misc/service2/foobar-daemon

echo "=== Создание systemd юнитов ==="
sudo tee /etc/systemd/system/foobar-service1.service <<'EOF'
[Unit]
Description=Foobar Test Service 1

[Service]
WorkingDirectory=/opt/misc/service1
ExecStart=/opt/misc/service1/foobar-daemon
Restart=always

[Install]
WantedBy=multi-user.target
EOF

sudo tee /etc/systemd/system/foobar-service2.service <<'EOF'
[Unit]
Description=Foobar Test Service 2

[Service]
WorkingDirectory=/opt/misc/service2
ExecStart=/opt/misc/service2/foobar-daemon
Restart=always

[Install]
WantedBy=multi-user.target
EOF

echo "=== Активация и запуск сервисов ==="
sudo systemctl daemon-reload
sudo systemctl enable --now foobar-service1 foobar-service2

echo "=== Проверка статуса сервисов ==="
sudo systemctl status foobar-service1 foobar-service2 --no-pager

echo "=== Проверка логов сервисов ==="
journalctl -u foobar-service1 -u foobar-service2 --since "1 minute ago" --no-pager