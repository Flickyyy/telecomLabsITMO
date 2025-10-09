#!/bin/bash
# Простой скрипт для вывода счетчиков пакетов интерфейса из /proc/net/dev

IFACE=${1:-bond007}
COUNT=${2:-1}

if ! grep -qE "^\\s*$IFACE:" /proc/net/dev; then
  echo "Интерфейс $IFACE не найден в /proc/net/dev"
  exit 1
fi

for ((i=1; i<=COUNT; i++)); do
  line=$(grep -E "^\\s*$IFACE:" /proc/net/dev)
  stats=${line#*:}
  set -- $stats
  rx_packets=$2
  tx_packets=${10}

  echo "-----"
  date '+%Y-%m-%d %H:%M:%S'
  echo "Интерфейс: $IFACE"
  echo "Receive-packets: $rx_packets"
  echo "Transmit-packets: $tx_packets"

  if [ $COUNT -gt 1 ] && [ $i -lt $COUNT ]; then
    sleep 1
  fi
done
