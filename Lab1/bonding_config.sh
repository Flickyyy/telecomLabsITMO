#!/bin/bash
# Практическая работа №1, часть 4
# Минимальный скрипт для настройки bond007

if [ "$(id -u)" -ne 0 ]; then
  echo "Нужны права root"
  exit 1
fi

load_module() {
  if ! lsmod | grep -q "^bonding"; then
    modprobe bonding || { echo "Не удалось загрузить bonding"; exit 1; }
  fi
}

usage() {
  cat <<EOT
Использование:
  $0 setup <iface1> <iface2> - создать bond007 в режиме balance-rr и запросить DHCP
  $0 status                 - показать /proc/net/bonding/bond007 и /proc/net/dev
  $0 cleanup                - удалить bond007 и вернуть интерфейсы
EOT
}

case "$1" in
  setup)
    iface1=$2
    iface2=$3
    if [ -z "$iface1" ] || [ -z "$iface2" ]; then
      echo "Укажите два интерфейса"
      exit 1
    fi
    load_module
    ip link delete bond007 >/dev/null 2>&1
    ip link add bond007 type bond
    echo balance-rr > /sys/class/net/bond007/bonding/mode
    for iface in "$iface1" "$iface2"; do
      ip link set "$iface" down
      ip addr flush dev "$iface"
      echo "+$iface" > /sys/class/net/bond007/bonding/slaves
    done
    ip link set bond007 up
    dhclient -r bond007 >/dev/null 2>&1
    dhclient bond007
    ip addr show bond007
    ;;
  status)
    if [ ! -f /proc/net/bonding/bond007 ]; then
      echo "bond007 не найден"
      exit 1
    fi
    cat /proc/net/bonding/bond007
    echo "---"
    cat /proc/net/dev
    ;;
  cleanup)
    if [ -d /sys/class/net/bond007 ]; then
      slaves=$(cat /sys/class/net/bond007/bonding/slaves)
      for iface in $slaves; do
        echo "-$iface" > /sys/class/net/bond007/bonding/slaves
        ip link set "$iface" up
      done
      ip link delete bond007 type bond
    fi
    echo "bond007 удален"
    ;;
  *)
    usage
    ;;
esac
