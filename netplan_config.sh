#!/bin/bash
# Скрипт для настройки сети по протоколу Netplan (для Debian/Ubuntu)
# netplan_config.sh

# Проверка прав root
if [ "$(id -u)" -ne 0 ]; then
  echo "Этот скрипт должен быть запущен с правами root"
  exit 1
fi

# Проверка наличия Netplan
if ! command -v netplan &>/dev/null; then
  echo "Netplan не установлен. Скрипт предназначен для систем с Netplan (Ubuntu/Debian)."
  exit 1
fi

# Функция для создания базовой конфигурации
create_basic_config() {
  local interface=$1
  local config_path="/etc/netplan/01-netcfg.yaml"
  
  echo "Создание базовой конфигурации Netplan для $interface..."
  
  cat > $config_path <<EOF
# Netplan конфигурация, созданная скриптом
network:
  version: 2
  renderer: networkd
  ethernets:
    $interface:
      dhcp4: yes
EOF

  echo "Конфигурация создана в $config_path"
  cat $config_path
}

# Функция для настройки статического IP
configure_static() {
  local interface=$1
  local ip_addr=$2
  local netmask=$3
  local gateway=$4
  local config_path="/etc/netplan/01-netcfg.yaml"
  
  echo "Настройка статического IP для $interface..."
  
  cat > $config_path <<EOF
# Netplan конфигурация, созданная скриптом
network:
  version: 2
  renderer: networkd
  ethernets:
    $interface:
      addresses:
        - $ip_addr/$netmask
      gateway4: $gateway
      nameservers:
        addresses: [8.8.8.8, 8.8.4.4]
EOF

  echo "Конфигурация создана в $config_path"
  cat $config_path
}

# Функция для настройки моста
configure_bridge() {
  local bridge_name=$1
  local interface=$2
  local config_path="/etc/netplan/01-netcfg.yaml"
  
  echo "Настройка моста $bridge_name с интерфейсом $interface..."
  
  cat > $config_path <<EOF
# Netplan конфигурация, созданная скриптом
network:
  version: 2
  renderer: networkd
  ethernets:
    $interface:
      dhcp4: no
  bridges:
    $bridge_name:
      interfaces: [$interface]
      dhcp4: yes
EOF

  echo "Конфигурация создана в $config_path"
  cat $config_path
}

# Применение конфигурации Netplan
apply_config() {
  echo "Применение конфигурации Netplan..."
  netplan apply
  echo "Конфигурация применена."
}

# Основной блок скрипта
case "$1" in
  basic)
    [ -z "$2" ] && { echo "Использование: $0 basic <интерфейс>"; exit 1; }
    create_basic_config $2
    apply_config
    ;;
    
  static)
    [ -z "$5" ] && { echo "Использование: $0 static <интерфейс> <ip-адрес> <маска> <шлюз>"; exit 1; }
    configure_static $2 $3 $4 $5
    apply_config
    ;;
    
  bridge)
    [ -z "$3" ] && { echo "Использование: $0 bridge <имя-моста> <интерфейс>"; exit 1; }
    configure_bridge $2 $3
    apply_config
    ;;
    
  apply)
    apply_config
    ;;
    
  *)
    echo "Использование:"
    echo "  $0 basic <интерфейс> - базовая конфигурация с DHCP"
    echo "  $0 static <интерфейс> <ip-адрес> <маска> <шлюз> - настройка статического IP"
    echo "  $0 bridge <имя-моста> <интерфейс> - настройка моста"
    echo "  $0 apply - применить существующую конфигурацию"
    ;;
esac