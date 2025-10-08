#!/bin/bash
# Практическая работа №1, часть 2
# Настройка интерфейса и моста через nmcli

if [ "$(id -u)" -ne 0 ]; then
  echo "Нужны права root"
  exit 1
fi

if ! command -v nmcli >/dev/null 2>&1; then
  echo "nmcli не найден"
  exit 1
fi

usage() {
  cat <<EOT
Использование:
  $0 physical <iface>   - настроить интерфейс по сценарию #1 (10.100.0.2/24)
  $0 bridge <iface>     - создать мост br0 с IP 10.100.0.3 и добавить iface
  $0 up                 - активировать соединения lab-eth и lab-br0
  $0 show               - показать состояние nmcli и MAC br0
  $0 delete             - удалить созданные соединения
EOT
}

case "$1" in
  physical)
    iface=${2:-enp0s3}
    nmcli con delete lab-eth >/dev/null 2>&1
    nmcli con add type ethernet ifname "$iface" con-name lab-eth autoconnect no
    nmcli con mod lab-eth ipv4.addresses 10.100.0.2/24 \
      ipv4.gateway 10.100.0.1 ipv4.dns "8.8.8.8" ipv4.method manual
    echo "Создано соединение lab-eth для $iface"
    ;;
  bridge)
    iface=${2:-enp0s3}
    nmcli con delete lab-br0 >/dev/null 2>&1
    nmcli con delete lab-br0-slave >/dev/null 2>&1
    nmcli con add type bridge ifname br0 con-name lab-br0 autoconnect no
    nmcli con mod lab-br0 ipv4.addresses 10.100.0.3/24 ipv4.method manual
    nmcli con add type bridge-slave ifname "$iface" master lab-br0 con-name lab-br0-slave
    echo "Создан мост br0 и добавлен интерфейс $iface"
    ;;
  up)
    nmcli con up lab-eth
    nmcli con up lab-br0
    nmcli con up lab-br0-slave
    ;;
  show)
    nmcli -f NAME,TYPE,DEVICE con show --active
    echo "MAC br0:" && ip link show br0 2>/dev/null | grep -o "link/ether .*"
    ;;
  delete)
    nmcli con delete lab-br0-slave >/dev/null 2>&1
    nmcli con delete lab-br0 >/dev/null 2>&1
    nmcli con delete lab-eth >/dev/null 2>&1
    echo "Удалены соединения lab-eth/lab-br0"
    ;;
  *)
    usage
    ;;
esac
