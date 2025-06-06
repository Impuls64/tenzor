## Тестовые задания Tenzor 
  
```bash
git clone https://github.com/Impuls64/tenzor
```

### Для запуска заданий использовал следующие команды:

#### Задание 1
```bash
python3 task1.py
```

#### Задание 2: (проверял на своём репозитории файлы bash и python)
```bash
python3 task2.py https://github.com/Impuls64/mesin python-scripts 1.0.0
```
```bash
python3 task2.py https://github.com/Impuls64/mesin bash-scripts 1.0.0
```

#### Задание 3:
Создаём файл .json с номерами версий командой:
```bash
echo '{"Sh1":"3.7.*", "Sh2":"3.*.1", "Sh3":"1.2.3.*"}' > config.json
```

Запускаем основной код скрипта python командой:
```bash
python task3.py 1.2.3 config.json
```

#### Задание 4:

Изменяем разрешение на запуск - для файла task4.sh командой:
```bash
chmod +x task4.sh
```
Запускаем основной скрипт командой:
```bash
./task4.sh 
```

Проверка задания 4 - создал 2 файла (для создания daemon и последующего удаления после тестирования скрипта)
```bash
chmod +x cleanup_task4.sh for_test_task4.sh
```

Запускаем скрипт по созданию daemon:
```bash
./for_test_task4.sh
```

Запускаем основной код для переноса daemon 
```bash
./task4.sh
```

Запускаем очистку
```bash
./cleanup_task4.sh
```

Проверка удаления daemon:
```bash
systemctl status foobar-service1.service foobar-service2.service foobar-service1.service
```