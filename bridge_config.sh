#!/bin/bash
# Скрипт для настройки мостов (bridge_config.sh)

# Проверка прав root
if [ "$(id -u)" -ne 0 ]; then
  echo "Этот скрипт должен быть запущен с правами root"
  exit 1
fi

# Основной блок скрипта
case "$1" in
  create)
    if [ -z "$2" ] || [ -z "$3" ]; then
      echo "Использование: $0 create <имя-моста> <интерфейс>"
      exit 1
    fi
    
    bridge_name=$2
    interface=$3
    
    echo "Создание моста $bridge_name с интерфейсом $interface..."
    
    # Создаем мост
    ip link add name $bridge_name type bridge
    
    # Добавляем интерфейс в мост
    ip link set dev $interface master $bridge_name
    ip link set dev $interface up
    ip link set dev $bridge_name up
    
    echo "Мост $bridge_name создан и включен"
    ip link show type bridge
    ;;
    
  delete)
    if [ -z "$2" ]; then
      echo "Использование: $0 delete <имя-моста>"
      exit 1
    fi
    
    bridge_name=$2
    
    echo "Удаление моста $bridge_name..."
    
    # Находим интерфейсы в мосте
    for iface in $(ls /sys/class/net/$bridge_name/brif/ 2>/dev/null); do
      echo "Отключение интерфейса $iface от моста"
      ip link set dev $iface nomaster
    done
    
    # Удаляем мост
    ip link delete $bridge_name type bridge
    echo "Мост $bridge_name удален"
    ;;
    
  show)
    echo "Список мостов в системе:"
    ip link show type bridge
    
    # Показываем интерфейсы для каждого моста
    for bridge in $(ip -o link show type bridge | cut -d: -f2 | tr -d ' '); do
      echo "Интерфейсы в мосте $bridge:"
      ls -1 /sys/class/net/$bridge/brif/ 2>/dev/null || echo "Нет интерфейсов"
      echo ""
    done
    ;;
    
  *)
    echo "Использование:"
    echo "  $0 create <имя-моста> <интерфейс> - создать мост"
    echo "  $0 delete <имя-моста> - удалить мост"
    echo "  $0 show - показать список мостов"
    ;;
esac