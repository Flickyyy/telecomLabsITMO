#!/bin/bash
# Скрипт для настройки бондинга (bonding_config.sh)

# Проверка прав root
if [ "$(id -u)" -ne 0 ]; then
  echo "Этот скрипт должен быть запущен с правами root"
  exit 1
fi

# Функция для проверки наличия модуля bonding
check_bonding_module() {
  if ! lsmod | grep -q bonding; then
    echo "Загрузка модуля bonding..."
    modprobe bonding
    if [ $? -ne 0 ]; then
      echo "Ошибка загрузки модуля bonding!"
      exit 1
    fi
    echo "Модуль bonding загружен."
  else
    echo "Модуль bonding уже загружен."
  fi
}

# Основной блок скрипта
case "$1" in
  create)
    if [ -z "$2" ] || [ -z "$3" ] || [ -z "$4" ]; then
      echo "Использование: $0 create <имя-bond> <режим> <интерфейс1> [интерфейс2...]"
      echo "Режимы: 0 (balance-rr), 1 (active-backup), 2 (balance-xor), 3 (broadcast)"
      exit 1
    fi
    
    bond_name=$2
    mode=$3
    shift 3  # Смещаем параметры, чтобы получить список интерфейсов
    
    # Проверяем модуль бондинга
    check_bonding_module
    
    # Создаем bond-интерфейс
    echo "Создание bond-интерфейса $bond_name в режиме $mode..."
    ip link add $bond_name type bond
    echo $mode > /sys/class/net/$bond_name/bonding/mode
    
    # Добавляем интерфейсы в bond
    for iface in "$@"; do
      echo "Добавление интерфейса $iface в $bond_name..."
      ip link set $iface down
      ip addr flush dev $iface
      echo "+$iface" > /sys/class/net/$bond_name/bonding/slaves
      ip link set $iface up
    done
    
    # Включаем bond-интерфейс
    ip link set $bond_name up
    echo "Bond-интерфейс $bond_name создан и включен."
    
    # Показываем информацию о созданном bond
    cat /proc/net/bonding/$bond_name
    ;;
    
  delete)
    if [ -z "$2" ]; then
      echo "Использование: $0 delete <имя-bond>"
      exit 1
    fi
    
    bond_name=$2
    
    # Проверяем существование bond
    if [ ! -d /sys/class/net/$bond_name ]; then
      echo "Bond-интерфейс $bond_name не существует!"
      exit 1
    fi
    
    echo "Удаление bond-интерфейса $bond_name..."
    
    # Получаем список интерфейсов в bond
    slaves=$(cat /sys/class/net/$bond_name/bonding/slaves 2>/dev/null)
    
    # Удаляем интерфейсы из bond
    for iface in $slaves; do
      echo "Удаление интерфейса $iface из $bond_name..."
      echo "-$iface" > /sys/class/net/$bond_name/bonding/slaves
      ip link set $iface up
    done
    
    # Удаляем bond-интерфейс
    ip link delete $bond_name type bond
    echo "Bond-интерфейс $bond_name удален."
    ;;
    
  stats)
    if [ -z "$2" ]; then
      echo "Использование: $0 stats <имя-bond>"
      exit 1
    fi
    
    bond_name=$2
    
    # Проверяем существование bond
    if [ ! -d /sys/class/net/$bond_name ]; then
      echo "Bond-интерфейс $bond_name не существует!"
      exit 1
    fi
    
    echo "=== Статистика bond-интерфейса $bond_name ==="
    cat /proc/net/bonding/$bond_name
    echo ""
    echo "=== Статистика трафика ==="
    ip -s link show $bond_name
    ;;
    
  *)
    echo "Использование:"
    echo "  $0 create <имя-bond> <режим> <интерфейс1> [интерфейс2...] - создать bond"
    echo "  $0 delete <имя-bond> - удалить bond"
    echo "  $0 stats <имя-bond> - показать статистику bond"
    echo ""
    echo "Режимы бондинга:"
    echo "  0 - balance-rr: Циклическая отправка пакетов"
    echo "  1 - active-backup: Один интерфейс активный, другой в резерве"
    echo "  2 - balance-xor: Распределение на основе XOR"
    echo "  3 - broadcast: Отправка всех пакетов на все интерфейсы"
    echo "  4 - 802.3ad: IEEE 802.3ad LACP"
    echo "  5 - balance-tlb: Адаптивная балансировка исходящего трафика"
    echo "  6 - balance-alb: Адаптивная балансировка нагрузки"
    ;;
esac