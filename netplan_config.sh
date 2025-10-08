#!/bin/bash
# Практическая работа №1, часть 3
# Подготовка конфигурации Netplan с двумя адресами

FILE="/etc/netplan/lab-netcfg.yaml"

if [ "$(id -u)" -ne 0 ]; then
  echo "Запустите скрипт с sudo"
  exit 1
fi

if ! command -v netplan >/dev/null 2>&1; then
  echo "netplan не найден"
  exit 1
fi

usage() {
  cat <<EOT
Использование:
  $0 write <iface> - записать конфигурацию с адресами 10.100.0.4 и 10.100.0.5
  $0 apply        - применить netplan apply
  $0 show         - показать текущий файл $FILE
EOT
}

case "$1" in
  write)
    iface=${2:-enp0s3}
    cat > "$FILE" <<CFG
# Создано для лабораторной работы №1
network:
  version: 2
  renderer: networkd
  ethernets:
    $iface:
      addresses:
        - 10.100.0.4/24
        - 10.100.0.5/24
      routes:
        - to: 0.0.0.0/0
          via: 10.100.0.3
      nameservers:
        addresses: [8.8.8.8]
CFG
    echo "Файл записан: $FILE"
    ;;
  apply)
    netplan apply
    ;;
  show)
    cat "$FILE"
    ;;
  *)
    usage
    ;;
esac
