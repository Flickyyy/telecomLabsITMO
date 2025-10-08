# Практическая работа №1: консольные утилиты Linux

Скрипты помогают выполнить четыре части лабораторной работы без лишних действий. Все команды нужно запускать на виртуальных машинах CentOS и Debian. Перед началом сделайте файлы исполняемыми:

```bash
chmod +x *.sh
```

## Часть 1 — `net_config.sh`

Меню запускается без параметров. Скрипт показывает сведения об интерфейсе, настраивает статический сценарий (10.100.0.2/24, шлюз 10.100.0.1, DNS 8.8.8.8) и запрашивает адрес через DHCP.

```bash
sudo ./net_config.sh
```

## Часть 2 — `bridge_config.sh`

Последовательно выполните команды nmcli.

```bash
sudo ./bridge_config.sh physical enp0s3   # сценарий №1 для физического интерфейса
sudo ./bridge_config.sh bridge enp0s3     # создаём br0 с адресом 10.100.0.3
sudo ./bridge_config.sh up                # активируем соединения
sudo ./bridge_config.sh show              # проверяем и видим MAC br0
```

Удаление настроек:

```bash
sudo ./bridge_config.sh delete
```

## Часть 3 — `netplan_config.sh`

Создаём YAML с двумя адресами и применяем netplan на Debian.

```bash
sudo ./netplan_config.sh write enp0s3
sudo ./netplan_config.sh show
sudo ./netplan_config.sh apply
```

## Часть 4 — `bonding_config.sh` и `net_stats.sh`

Настройка bond007 и сбор счётчиков пакетов.

```bash
sudo ./bonding_config.sh setup enp0s8 enp0s9
sudo ./bonding_config.sh status

# сбор Receive/Transmit три раза
./net_stats.sh bond007 3

sudo ./bonding_config.sh cleanup
```

## Примечания

- Для сетевых операций требуются права root (sudo).
- Имена интерфейсов могут отличаться, проверьте `ip addr`.
- Скрипты меняют текущую конфигурацию и не правят системные файлы навсегда.