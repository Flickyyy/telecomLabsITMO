#!/bin/bash
# Практическая работа №1, часть 3
# Подготовка конфигурации Netplan с двумя адресами

FILE="/etc/netplan/lab-netcfg.yaml"

# определяем, каким демоном управляется сеть
detect_renderer() {
  if systemctl list-unit-files --type=service 2>/dev/null | grep -q '^NetworkManager\.service'; then
    echo "NetworkManager"
  elif systemctl list-unit-files --type=service 2>/dev/null | grep -q '^systemd-networkd\.service'; then
    echo "networkd"
  else
    echo "networkd"
  fi
}

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

backup_existing_configs() {
  shopt -s nullglob
  for cfg in /etc/netplan/*.yaml /etc/netplan/*.yml; do
    [ "$cfg" = "$FILE" ] && continue
    if [ -e "$cfg" ]; then
      mv "$cfg" "$cfg.bak-lab" 2>/dev/null && \
        echo "Старый файл перемещён: $cfg -> $cfg.bak-lab"
    fi
  done
  shopt -u nullglob
}

case "$1" in
  write)
    iface=${2:-enp0s3}
    renderer=$(detect_renderer)
    backup_existing_configs
    cat > "$FILE" <<CFG
# Создано для лабораторной работы №1
network:
  version: 2
  renderer: $renderer
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
    chmod 600 "$FILE"
    if [ "$renderer" = "networkd" ]; then
      systemctl enable --now systemd-networkd.service >/dev/null 2>&1 || \
        echo "Предупреждение: systemd-networkd не удалось запустить автоматически"
    fi
    echo "Файл записан: $FILE (renderer: $renderer)"
    ;;
  apply)
    renderer=$(detect_renderer)
    netplan apply
    if [ "$renderer" = "networkd" ]; then
      systemctl restart systemd-networkd.service >/dev/null 2>&1 || \
        echo "Предупреждение: не удалось перезапустить systemd-networkd"
    elif [ "$renderer" = "NetworkManager" ]; then
      systemctl restart NetworkManager.service >/dev/null 2>&1 || \
        echo "Предупреждение: не удалось перезапустить NetworkManager"
    fi
    ;;
  show)
    cat "$FILE"
    ;;
  *)
    usage
    ;;
esac
