#!/bin/bash
# Скрипт для сбора статистики сетевых интерфейсов (net_stats.sh)

# Функция для сбора базовой статистики
show_basic_stats() {
  local interface=$1
  echo "=== Базовая статистика интерфейса $interface ==="
  ip -s link show $interface
}

# Функция для сбора расширенной статистики с помощью ethtool
show_ethtool_stats() {
  local interface=$1
  if command -v ethtool &>/dev/null; then
    echo "=== Статистика ethtool для $interface ==="
    ethtool -S $interface 2>/dev/null || echo "Ethtool не поддерживает сбор статистики для $interface"
  else
    echo "Утилита ethtool не установлена. Для установки: sudo yum install -y ethtool"
  fi
}

# Функция для мониторинга трафика в реальном времени
monitor_traffic() {
  local interface=$1
  local interval=${2:-2}
  
  echo "Мониторинг трафика на $interface (интервал: $interval сек). Нажмите Ctrl+C для выхода."
  echo "----------------------------------------------------------------"
  
  while true; do
    clear
    date
    RX_BYTES_OLD=$(cat /sys/class/net/$interface/statistics/rx_bytes 2>/dev/null || echo 0)
    TX_BYTES_OLD=$(cat /sys/class/net/$interface/statistics/tx_bytes 2>/dev/null || echo 0)
    sleep $interval
    RX_BYTES_NEW=$(cat /sys/class/net/$interface/statistics/rx_bytes 2>/dev/null || echo 0)
    TX_BYTES_NEW=$(cat /sys/class/net/$interface/statistics/tx_bytes 2>/dev/null || echo 0)
    
    RX_DIFF=$(( (RX_BYTES_NEW - RX_BYTES_OLD) / interval ))
    TX_DIFF=$(( (TX_BYTES_NEW - TX_BYTES_OLD) / interval ))
    
    echo "Интерфейс: $interface"
    echo "Скорость приема: $(( RX_DIFF / 1024 )) KB/s"
    echo "Скорость передачи: $(( TX_DIFF / 1024 )) KB/s"
    echo "----------------------------------------------------------------"
    ip -s link show $interface | grep -A 6 $interface
    echo "----------------------------------------------------------------"
  done
}

# Основной блок скрипта
case "$1" in
  basic)
    [ -z "$2" ] && { echo "Использование: $0 basic <интерфейс>"; exit 1; }
    show_basic_stats $2
    ;;
    
  detail)
    [ -z "$2" ] && { echo "Использование: $0 detail <интерфейс>"; exit 1; }
    show_basic_stats $2
    show_ethtool_stats $2
    ;;
    
  monitor)
    [ -z "$2" ] && { echo "Использование: $0 monitor <интерфейс> [интервал]"; exit 1; }
    monitor_traffic $2 $3
    ;;
    
  all)
    echo "=== Статистика всех интерфейсов ==="
    for iface in $(ls /sys/class/net/ | grep -v lo); do
      show_basic_stats $iface
      echo ""
    done
    ;;
    
  *)
    echo "Использование:"
    echo "  $0 basic <интерфейс> - показать базовую статистику"
    echo "  $0 detail <интерфейс> - показать детальную статистику"
    echo "  $0 monitor <интерфейс> [интервал] - мониторинг в реальном времени"
    echo "  $0 all - статистика всех интерфейсов"
    ;;
esac