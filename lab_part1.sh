#!/usr/bin/env bash
# Минимальный меню-скрипт для Части 1 (только runtime-настройки)

set -e

need_root() {
  if [ "$EUID" -ne 0 ]; then
    echo "Запусти от root: sudo $0 [iface]"
    exit 1
  fi
}

pick_iface() {
  if [ -n "${1:-}" ]; then
    IFACE="$1"
  else
    IFACE="$(ip -br link | awk '$1!="lo"{print $1; exit}')"
  fi
  if [ -z "$IFACE" ]; then
    echo "Не найден интерфейс (кроме lo)."
    exit 1
  fi
}

nic_info() {
  echo "=== NIC info: $IFACE ==="
  ip -br link show "$IFACE"
  [ -f "/sys/class/net/$IFACE/address" ] && echo "MAC: $(cat /sys/class/net/$IFACE/address)"
  if command -v ethtool >/dev/null 2>&1; then
    ethtool "$IFACE" 2>/dev/null | egrep 'Speed:|Duplex:|Link detected:' || echo "ethtool: нет данных (виртуальный/неподдерживаемый?)"
    echo "--- драйвер/шина:"
    ethtool -i "$IFACE" 2>/dev/null || true
  else
    echo "Установи ethtool для скорости/дуплекса: sudo dnf install -y ethtool"
  fi
}

show_ipv4() {
  echo "=== IPv4: $IFACE ==="
  ip -4 addr show dev "$IFACE" || true
  echo "--- Маршруты для $IFACE:"
  ip route show dev "$IFACE" || true
  echo "--- Маршрут по умолчанию:"
  ip route show default || true
  echo "--- DNS (из /etc/resolv.conf):"
  [ -f /etc/resolv.conf ] && grep -E '^nameserver ' /etc/resolv.conf || echo "(нет записей nameserver)"
}

set_static() {
  local IP=10.100.0.2 MASK=/24 GW=10.100.0.1 DNS=8.8.8.8
  echo "=== Статика: $IP$MASK, gw $GW, DNS $DNS на $IFACE ==="
  ip link set "$IFACE" up
  ip -4 addr flush dev "$IFACE"
  ip addr add "$IP$MASK" dev "$IFACE"
  ip route replace default via "$GW" dev "$IFACE"
  # Попробуем временно задать DNS через systemd-resolved, если он есть
  if command -v resolvectl >/dev/null 2>&1; then
    resolvectl dns "$IFACE" "$DNS" || true
    resolvectl domain "$IFACE" "~." || true
  else
    echo "resolvectl не найден. Для резолва используй, например: dig @${DNS} ya.ru"
  fi
  show_ipv4
}

set_dhcp() {
  echo "=== DHCP на $IFACE ==="
  ip link set "$IFACE" up
  if command -v dhclient >/dev/null 2>&1; then
    dhclient -r "$IFACE" 2>/dev/null || true
    dhclient "$IFACE"
  else
    echo "dhclient не найден. Установи: sudo dnf install -y dhcp-client"
    return 1
  fi
  show_ipv4
}

menu() {
  while true; do
    echo
    echo "===== Меню ($IFACE) ====="
    echo "1) Инфо: модель/скорость/дуплекс/линк/MAC"
    echo "2) Показать IPv4/GW/DNS"
    echo "3) Статика 10.100.0.2/24, gw 10.100.0.1, DNS 8.8.8.8"
    echo "4) DHCP (dhclient)"
    echo "5) Сменить интерфейс"
    echo "0) Выход"
    read -rp "Выбор: " c
    case "$c" in
      1) nic_info ;;
      2) show_ipv4 ;;
      3) set_static ;;
      4) set_dhcp ;;
      5) read -rp "Интерфейс: " IFACE ;;
      0) exit 0 ;;
      *) echo "Неверный выбор" ;;
    esac
  done
}

need_root
pick_iface "$1"
echo "Совет: на время Части 1 останови NetworkManager: sudo systemctl stop NetworkManager"
menu