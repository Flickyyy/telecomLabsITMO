#!/bin/bash
# Скрипт для базовой настройки сети (net_config.sh)

# Функция для отображения информации об интерфейсе
show_info() {
  echo "=== Информация об интерфейсе $1 ==="
  ip addr show $1
  echo "--- MAC-адрес ---"
  ip link show $1 | grep -o "link/ether.*"
  echo "--- Состояние интерфейса ---"
  ip link show $1 | grep -E "state (UP|DOWN)"
}

# Основной блок скрипта
if [ -z "$1" ]; then
  echo "Использование:"
  echo "  $0 info <интерфейс> - показать информацию"
  echo "  $0 static <интерфейс> <ip> <маска> [шлюз] - настроить статический IP"
  echo "  $0 dhcp <интерфейс> - настроить DHCP"
  exit 1
fi



command=$1
interface=$2

case "$command" in
  info)
    [ -z "$interface" ] && { echo "Укажите интерфейс!"; exit 1; }
    show_info $interface
    ;;
  static)
    [ -z "$4" ] && { echo "Использование: $0 static <интерфейс> <ip> <маска> [шлюз]"; exit 1; }
    echo "Настройка IP $3/$4 для $interface..."
    ip addr flush dev $interface
    ip addr add $3/$4 dev $interface
    ip link set dev $interface up
    [ ! -z "$5" ] && ip route add default via $5
    show_info $interface
    ;;
  dhcp)
    [ -z "$interface" ] && { echo "Укажите интерфейс!"; exit 1; }
    echo "Настройка DHCP для $interface..."
    dhclient -v $interface
    show_info $interface
    ;;
  *)
    echo "Неизвестная команда: $command"
    echo "Доступные команды: info, static, dhcp"
    exit 1
    ;;
esac