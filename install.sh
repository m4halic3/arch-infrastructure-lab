#!/usr/bin/env bash
#
# install.sh
#
# Instala os scripts em /usr/local/bin e registra o timer systemd
# que executa a limpeza semanalmente.

set -euo pipefail

if [[ $EUID -ne 0 ]]; then
    echo "Rode este instalador com sudo: sudo ./install.sh" >&2
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "-> Copiando scripts para /usr/local/bin ..."
install -Dm755 "$SCRIPT_DIR/scripts/cleanup-system.sh" /usr/local/bin/cleanup-system.sh
install -Dm755 "$SCRIPT_DIR/scripts/disk-report.sh" /usr/local/bin/disk-report.sh

echo "-> Instalando unidades systemd ..."
install -Dm644 "$SCRIPT_DIR/systemd/cleanup.service" /etc/systemd/system/cleanup.service
install -Dm644 "$SCRIPT_DIR/systemd/cleanup.timer" /etc/systemd/system/cleanup.timer

echo "-> Recarregando systemd e ativando o timer ..."
systemctl daemon-reload
systemctl enable --now cleanup.timer

echo
echo "Instalação concluída."
echo "Verifique o agendamento com: systemctl list-timers cleanup.timer"
echo "Rode uma limpeza manual com: sudo cleanup-system.sh"
