# Практическая работа №4 — проектирование локальной сети в Cisco Packet Tracer

## 1. Цель и результат работы
- Собрать модель корпоративной сети в Cisco Packet Tracer c сегментацией по VLAN и общим DHCP‑сервером.
- Настроить L2/L3 коммутаторы, точку доступа, медиаконвертеры и сервер.
- Подготовить комплект артефактов для отчёта: файл модели, команды конфигурации, вывод диагностических команд, документацию в табличном виде и скриншоты из Packet Tracer.

## 2. Перечень требуемого оборудования в симуляторе
| Оборудование | Количество | Назначение |
| --- | --- | --- |
| Cisco Catalyst 3560-24PS | 1 | L3-коммутатор в аппаратной, маршрутизация между VLAN, DHCP relay |
| Cisco Catalyst 2960-24TT | 2 | L2-коммутаторы в центральном и дополнительном офисах |
| Repeater-PT | 2 | Медиаконвертеры на концах оптоволоконного участка 350 м |
| Access Point-PT | 1 | Точка Wi-Fi в доп. офисе |
| Server | 1 | DHCP, при необходимости DNS/файловые сервисы |
| PC/Laptop | 22 | Рабочие станции пользователей |
| Printer | 2 | Сетевые принтеры |
| IP Camera (Webcam) | 3 | Камеры наблюдения |
| Кабель Copper Straight-Through | по потребности | Соединение ПК/принтеров с коммутаторами |
| Кабель Fiber (Singlemode) | 1 | Связь между зданиями через медиаконвертеры |
| Коммутационные модули PT-REPEATER-NM-1FFE | 2 | Для установки в повторители, чтобы получить оптические порты |

> **Примечание.** Для участка 350 м используем оптоволоконный канал. В каждом медиаконвертере отключаем питание (кнопка `I/O`), вытаскиваем RJ-45 модуль и ставим `PT-REPEATER-NM-1FFE`, затем подключаем Fiber Singlemode.

## 3. План выполнения работы
1. **Подготовка**
   - Установить Cisco Packet Tracer (через VPN, если требуется).
   - Просмотреть главы 1–2 справки для повторения интерфейса.
2. **Проектирование**
   - Нарисовать логическую схему сети (где какие устройства и каналы).
   - Определить комнаты/стойки: центральный офис, аппаратная, дополнительный офис.
   - Назначить VLAN и IP-подсети группам оборудования.
   - Спланировать портовую нумерацию каждой стойки (см. таблицы ниже, можно адаптировать под свой монтаж).
3. **Сборка модели в Packet Tracer**
   - В режиме `Physical` создать два здания: **HeadOffice** (с комнатами *Central Office*, *Service Room*) и **RemoteOffice**.
   - Расставить оборудование по помещениям.
   - Протянуть медиу точь-в-точь: медные патч-корды внутри, оптика между зданиями через повторители.
4. **Конфигурирование**
   - Настроить VLAN, режимы портов, IP-интерфейсы и DHCP relay на коммутаторе 3560.
   - Настроить статические VLAN на коммутаторах 2960.
   - Назначить статический IP серверу, поднять сервис DHCP (и DNS при необходимости).
   - Сконфигурировать Wi-Fi точку с SSID и паролем, включить VLAN 10 на транке к точке доступа.
5. **Тестирование**
   - Проверить получение адресов по DHCP в каждой VLAN.
   - Пропинговать шлюз своей VLAN, сервер, затем устройства других VLAN.
   - Убедиться в получении шлюзов и DNS (если настроен).
6. **Документирование**
   - Сохранить файл `lab4.pkt`.
   - Зафиксировать командные выводы (`show vlan brief`, `show ip interface brief`, `show interfaces status`).
   - Заполнить таблицы VLAN, IP-подсетей, портов и соединений.
   - Сделать скриншоты логической схемы, физического вида, окна DHCP и проверочных пингов.
   - Сформировать отчёт в DOCX/PDF по шаблону ниже.

## 4. VLAN и IP-план
| VLAN | Имя | Назначение | Подсеть | Шлюз | DHCP | Особенности |
| --- | --- | --- | --- | --- | --- | --- |
| 10 | USERS | ПК центрального офиса + Wi-Fi клиенты | 10.10.0.0/24 | 10.10.0.1 | DHCP (10.10.0.10–10.10.0.250) | SSID для Wi-Fi, доступ к ресурсам офиса |
| 20 | REMOTE | ПК и принтеры дополнительного офиса | 10.20.0.0/24 | 10.20.0.1 | DHCP (10.20.0.10–10.20.0.250) | Трафик идёт через оптику |
| 30 | CAMERAS | IP-камеры во всех помещениях | 10.30.0.0/24 | 10.30.0.1 | DHCP (10.30.0.10–10.30.0.150) | Изолировать от пользовательского трафика |
| 40 | SERVER | Серверная сеть | 10.40.0.0/24 | 10.40.0.254 | статический IP (сервер) | Под сервер, можно оставить DHCP pool для будущих сервисов |
| 999 | MGMT | Управление (native VLAN) | 192.168.9.0/24 (опционально) | — | — | Отделить служебный трафик, не обязательно выдавать IP |

## 5. Назначения портов по умолчанию
При необходимости подстройте номера портов под вашу схему, сохраняя роли.

### SW-CENTRAL (2960-24TT)
| Порт | Назначение | VLAN |
| --- | --- | --- |
| Fa0/1–Fa0/18 | Рабочие станции центрального офиса | 10 |
| Fa0/19 | Принтер центрального офиса | 10 |
| Fa0/20 | IP-камера центрального офиса | 30 |
| Fa0/21 | Транк к SW-CORE | trunk (10,30,40), native 999 |
| Fa0/22–Fa0/24 | Резерв | shutdown |

### SW-CORE (3560-24PS)
| Порт | Назначение | VLAN/Режим |
| --- | --- | --- |
| Fa0/1 | Сервер DHCP | access 40 |
| Fa0/2 | Транк к SW-CENTRAL | trunk (10,30,40), native 999 |
| Fa0/3 | Транк к SW-REMOTE | trunk (10,20,30,40), native 999 |
| Fa0/4 | Камера аппаратной | access 30 |
| Остальные | Резерв под расширение | shutdown |

### SW-REMOTE (2960-24TT)
| Порт | Назначение | VLAN |
| --- | --- | --- |
| Fa0/1 | Транк на SW-CORE | trunk (10,20,30,40), native 999 |
| Fa0/2–Fa0/5 | Рабочие станции доп. офиса | 20 |
| Fa0/6 | Камера доп. офиса | 30 |
| Fa0/7 | Точка доступа (транк) | trunk (10,20,30), native 999 |
| Fa0/8 | Принтер доп. офиса | 20 |
| Fa0/9–Fa0/24 | Резерв | shutdown |

## 6. Настройка коммутаторов (CLI-скрипты)

### SW-CENTRAL (2960-24TT)
```text
enable
configure terminal
hostname SW-CENTRAL
no ip domain-lookup

vlan 10
 name CENTRAL_USERS
exit
vlan 30
 name CAMERAS
exit
vlan 40
 name SERVER
exit
vlan 999
 name MGMT_NATIVE
exit

interface range fa0/1 - 18
 switchport mode access
 switchport access vlan 10
 spanning-tree portfast
 no shutdown
exit

interface fa0/19
 description CENTRAL-PRINTER
 switchport mode access
 switchport access vlan 10
 spanning-tree portfast
 no shutdown
exit

interface fa0/20
 description CAM-CENTRAL
 switchport mode access
 switchport access vlan 30
 spanning-tree portfast
 no shutdown
exit

interface fa0/21
 description TRK-TO-SW-CORE
 switchport trunk encapsulation dot1q
 switchport mode trunk
 switchport trunk allowed vlan 10,30,40
 switchport trunk native vlan 999
 no shutdown
exit

interface range fa0/22 - 24
 shutdown
exit

line con 0
 logging synchronous
exit

end
write memory
```

### SW-CORE (3560-24PS)
```text
enable
configure terminal
hostname SW-CORE
no ip domain-lookup

vlan 10
 name USERS
exit
vlan 20
 name REMOTE
exit
vlan 30
 name CAMERAS
exit
vlan 40
 name SERVER
exit
vlan 999
 name MGMT_NATIVE
exit

interface vlan 10
 ip address 10.10.0.1 255.255.255.0
 ip helper-address 10.40.0.1
 no shutdown
exit

interface vlan 20
 ip address 10.20.0.1 255.255.255.0
 ip helper-address 10.40.0.1
 no shutdown
exit

interface vlan 30
 ip address 10.30.0.1 255.255.255.0
 ip helper-address 10.40.0.1
 no shutdown
exit

interface vlan 40
 ip address 10.40.0.254 255.255.255.0
 no shutdown
exit

ip routing

interface fa0/1
 description SRV-DHCP
 switchport mode access
 switchport access vlan 40
 spanning-tree portfast
 no shutdown
exit

interface fa0/2
 description TRK-TO-SW-CENTRAL
 switchport trunk encapsulation dot1q
 switchport mode trunk
 switchport trunk allowed vlan 10,30,40
 switchport trunk native vlan 999
 no shutdown
exit

interface fa0/3
 description TRK-TO-SW-REMOTE
 switchport trunk encapsulation dot1q
 switchport mode trunk
 switchport trunk allowed vlan 10,20,30,40
 switchport trunk native vlan 999
 no shutdown
exit

interface fa0/4
 description CAM-SERVICE
 switchport mode access
 switchport access vlan 30
 spanning-tree portfast
 no shutdown
exit

interface range fa0/5 - 24
 shutdown
exit

line con 0
 logging synchronous
exit

end
write memory
```

### SW-REMOTE (2960-24TT)
```text
enable
configure terminal
hostname SW-REMOTE
no ip domain-lookup

vlan 10
 name WIFI_USERS
exit
vlan 20
 name REMOTE_OFFICE
exit
vlan 30
 name CAMERAS
exit
vlan 40
 name SERVER
exit
vlan 999
 name MGMT_NATIVE
exit

interface fa0/1
 description TRK-TO-SW-CORE
 switchport trunk encapsulation dot1q
 switchport mode trunk
 switchport trunk allowed vlan 10,20,30,40
 switchport trunk native vlan 999
 no shutdown
exit

interface range fa0/2 - 5
 description REMOTE-WORKSTATIONS
 switchport mode access
 switchport access vlan 20
 spanning-tree portfast
 no shutdown
exit

interface fa0/6
 description CAM-REMOTE
 switchport mode access
 switchport access vlan 30
 spanning-tree portfast
 no shutdown
exit

interface fa0/7
 description AP-TRUNK
 switchport trunk encapsulation dot1q
 switchport mode trunk
 switchport trunk allowed vlan 10,20,30
 switchport trunk native vlan 999
 no shutdown
exit

interface fa0/8
 description REMOTE-PRINTER
 switchport mode access
 switchport access vlan 20
 spanning-tree portfast
 no shutdown
exit

interface range fa0/9 - 24
 description SPARE
 shutdown
exit

line con 0
 logging synchronous
exit

end
write memory
```


## 8. Настройка DHCP на сервере
1. Во вкладке `Desktop` задать статический IP:
   - `IP Address`: `10.40.0.1`
   - `Subnet Mask`: `255.255.255.0`
   - `Default Gateway`: `10.40.0.254`
   - `DNS Server`: `0.0.0.0`
2. Перейти `Services → DHCP`, включить `DHCP`.
3. Создать пулы:

| Pool Name | Default Gateway | DNS Server | Start IP | Subnet Mask | Maximum Users |
| --- | --- | --- | --- | --- | --- |
| VLAN10 | 10.10.0.1 | 0.0.0.0 | 10.10.0.10 | 255.255.255.0 | 240 |
| VLAN20 | 10.20.0.1 | 0.0.0.0 | 10.20.0.10 | 255.255.255.0 | 240 |
| VLAN30 | 10.30.0.1 | 0.0.0.0 | 10.30.0.10 | 255.255.255.0 | 240 |
| VLAN40 | 10.40.0.1 | 0.0.0.0 | 10.40.0.10 | 255.255.255.0 | 240 |

4. Сохранить настройки кнопкой `Save`.

## 9. Проверка работоспособности
1. На одном ПК каждой VLAN в `Desktop → IP Configuration` выбрать `DHCP`. Убедиться, что адреса выдаются из нужного пула, шлюз совпадает со столбцом `Default Gateway`.
2. Выполнить команды `ping`:
   - До шлюза своей VLAN (`ping 10.10.0.1`, `ping 10.20.0.1`, `ping 10.30.0.1`).
   - До сервера `10.40.0.1` и шлюза VLAN 40 (`10.40.0.254`).
   - Между ПК разных VLAN (для проверки маршрутизации на L3 коммутаторе).
3. На SW-CORE выполнить:
   ```text
   show vlan brief
   show ip interface brief
   show interfaces status
   ```
   Сохранить текст вывода для отчёта.
4. При необходимости проверить таблицу маршрутизации: `show ip route`.

## 10. Структура отчёта (DOCX/PDF)
Рекомендуемый каркас (можно собрать в Markdown и экспортировать):

1. **Титульный лист**
   - ВУЗ, кафедра, дисциплина.
   - Тема работы, ФИО, группа, преподаватель.
   - Дата выполнения.
2. **Цель работы**
3. **Теоретическая часть (кратко)**
   - Определения VLAN, L2/L3-коммутатора, медиаконвертера, DHCP, портов access/trunk.
4. **Исходные данные и требования**
   - Кратко переписать задание.
   - Список оборудования.
5. **Проектирование сети**
   - Логическая схема (вставить скрин `Logical` из Packet Tracer).
   - Физическая схема/план размещения (скрин `Physical`).
   - Таблицы VLAN, устройств, портов (см. шаблоны ниже).
6. **Конфигурирование**
   - Команды для каждого коммутатора (см. раздел 6, можно вставить в приложение).
   - Скрин вкладки DHCP.
   - Скрин настроек точки доступа.
7. **Тестирование**
   - Скрины успешных DHCP-запросов.
   - Скриншоты ping между VLAN.
   - Текстовый вывод `show`-команд.
8. **Выводы**
   - Что сделано, чему научились, какие проблемы возникли и как решены.
9. **Приложения** (если требуется)
   - Файл конфигураций в текстовом виде.
   - Ссылка/QR на `lab4.pkt`.

### Таблицы для документации (копируйте в отчёт)

#### VLAN
| VLAN | Имя | Назначение | Подсеть | Шлюз | DHCP-диапазон |
| --- | --- | --- | --- | --- | --- |
| 10 | USERS | ПК центрального офиса, Wi-Fi | 10.10.0.0/24 | 10.10.0.1 | 10.10.0.10–10.10.0.250 |
| 20 | REMOTE | ПК/принтеры доп. офиса | 10.20.0.0/24 | 10.20.0.1 | 10.20.0.10–10.20.0.250 |
| 30 | CAMERAS | IP-камеры | 10.30.0.0/24 | 10.30.0.1 | 10.30.0.10–10.30.0.150 |
| 40 | SERVER | Серверы | 10.40.0.0/24 | 10.40.0.254 | статические |
| 999 | MGMT | Native VLAN | 192.168.9.0/24 | — | — |

#### Устройства
| Имя | Модель | Расположение | Назначение |
| --- | --- | --- | --- |
| SW-CENTRAL | Cisco 2960-24TT | Центральный офис | Доступ пользователей |
| SW-CORE | Cisco 3560-24PS | Аппаратная | Маршрутизация, DHCP relay |
| SW-REMOTE | Cisco 2960-24TT | Доп. офис | Подключение удалённых ПК |
| AP-REMOTE | AP-PT | Доп. офис | Wi-Fi для VLAN 10 |
| DHCP-SRV | Server | Аппаратная | DHCP/DNS |

#### Соединения
| Откуда | Порт | Куда | Порт | Тип кабеля |
| --- | --- | --- | --- | --- |
| SW-CENTRAL | Fa0/21 | SW-CORE | Fa0/2 | Copper |
| SW-REMOTE | Fa0/1 | SW-CORE | Fa0/3 | Fiber через Repeaters |
| SW-CORE | Fa0/1 | DHCP-SRV | Fa0 | Copper |
| SW-CENTRAL | Fa0/20 | CAM-CENTRAL | Fa0 | Copper |
| SW-REMOTE | Fa0/6 | CAM-REMOTE | Fa0 | Copper |
| SW-REMOTE | Fa0/7 | AP-REMOTE | Port0 | Copper |
| SW-CENTRAL | Fa0/19 | Printer0 | — | Copper |
| SW-REMOTE | Fa0/8 | Printer1 | — | Copper |

#### Порты (пример)
| Коммутатор | Порт | Описание | VLAN |
| --- | --- | --- | --- |
| SW-CENTRAL | Fa0/1 | Рабочее место 1 | 10 |
| SW-CENTRAL | Fa0/19 | Принтер | 10 |
| SW-CENTRAL | Fa0/21 | Связь с SW-CORE | trunk (10,30,40) |
| SW-CORE | Fa0/1 | DHCP-сервер | 40 |
| SW-CORE | Fa0/3 | Связь с SW-REMOTE | trunk (10,20,30,40) |
| SW-REMOTE | Fa0/2 | Рабочее место 1 | 20 |
| SW-REMOTE | Fa0/7 | Точка доступа | trunk (10,20,30) |

## 11. Подготовка приложений для отчёта
- **Файл модели**: сохранить `lab4.pkt` в папку проекта.
- **Скриншоты** (рекомендуемое имя):
  - `logical-topology.png`
  - `physical-layout.png`
  - `dhcp-settings.png`
  - `wifi-config.png`
  - `ping-tests.png`
- **Текст конфигураций**: сохранить CLI-скрипты (например, `configs/sw-core.txt`).
- **Вывод команд**: скопировать результаты `show` в текстовый файл `outputs/sw-core-show.txt` или вставить в отчёт.

## 12. Контрольные вопросы (понятийный минимум)
1. Что такое Tag-based VLAN? Как работает стандарт IEEE 802.1Q?
2. Разница между L2- и L3-коммутатором.
3. Назначение медиаконвертера в данной топологии.
4. Что делает Wi-Fi access point в контексте VLAN?
5. Порты access и trunk — различия и варианты использования.
6. Роли DHCP-сервера и DHCP-relay.

## 13. Советы по сдаче
- После завершения работы выполните `File → Save As` и сохраните модель с именем `Фамилия_Имя_Lab4.pkt`.
- Резервная копия: экспортировать отчёт в PDF.
- В теме письма для преподавателя: `№Группы ФИО Lab4` (например, `5555 Ivan Ivanov Lab4`).
- Проверьте, что по документации можно восстановить сеть без файла Packet Tracer.

Удачной защиты! Если понадобится автоматизировать генерацию конфигов или сформировать DOCX из Markdown — сообщите, добавим дополнительные скрипты.
