#!/bin/bash
# Практическая работа №1, часть 1
# Скрипт для базовой настройки IPv4 без использования сетевых менеджеров

SCENARIO_IP="10.100.0.2"
SCENARIO_MASK="24"
SCENARIO_GW="10.100.0.1"
SCENARIO_DNS="8.8.8.8"

require_root() {
  if [ "$(id -u)" -ne 0 ]; then
    echo "Для этой операции нужны права root. Перезапустите скрипт через sudo."
    exit 1
  fi
}

show_info() {
  local iface=$1
  echo "==== Сведения об интерфейсе $iface ===="

  echo "Модель сетевой карты:"
  if command -v lspci >/dev/null 2>&1; then
    lspci | grep -i ethernet
  else
    echo "lspci не установлен"
  fi

  echo "\nКанальная скорость и duplex:"
  if command -v ethtool >/dev/null 2>&1; then
    ethtool "$iface" 2>/dev/null | grep -E "Speed|Duplex|Link detected"
  else
    echo "ethtool не установлен"
  fi

  echo "\nMAC-адрес:"
  cat "/sys/class/net/$iface/address" 2>/dev/null || echo "нет данных"

  echo "\nIPv4 адрес:"
  ip -4 addr show "$iface"

  echo "\nШлюз по умолчанию:"
  ip route show default

  echo "\nDNS из /etc/resolv.conf:"
  grep nameserver /etc/resolv.conf 2>/dev/null || echo "записей не найдено"
}

configure_static() {
  local iface=$1
  require_root

  echo "Настраиваем $iface по сценарию #1"
  ip addr flush dev "$iface"
  ip addr add "$SCENARIO_IP/$SCENARIO_MASK" dev "$iface"
  ip link set "$iface" up
  ip route replace default via "$SCENARIO_GW" dev "$iface"
  printf "nameserver %s\n" "$SCENARIO_DNS" > /etc/resolv.conf
  show_info "$iface"
}

configure_dhcp() {
  local iface=$1
  require_root

  echo "Запрашиваем адрес у DHCP для $iface"
  dhclient -r "$iface" >/dev/null 2>&1
  dhclient "$iface"
  show_info "$iface"
}

main_menu() {
  while true; do
    echo ""
    echo "=== Меню ==="
    echo "1) Показать сведения об интерфейсе"
    echo "2) Настроить статический адрес (сценарий #1)"
    echo "3) Настроить получение адреса через DHCP"
    echo "4) Выход"
    read -rp "Выберите пункт: " choice

    case $choice in
      1)
        read -rp "Интерфейс: " iface
        [ -n "$iface" ] && show_info "$iface"
        ;;
      2)
        read -rp "Интерфейс для настройки: " iface
        [ -n "$iface" ] && configure_static "$iface"
        ;;
      3)
        read -rp "Интерфейс для настройки: " iface
        [ -n "$iface" ] && configure_dhcp "$iface"
        ;;
      4)
        echo "Выход"
        exit 0
        ;;
      *)
        echo "Неизвестный пункт"
        ;;
    esac
  done
}

if [ $# -eq 0 ]; then
  main_menu
else
  echo "Скрипт работает через меню без параметров. Просто запустите ./net_config.sh"
  exit 1
fi
