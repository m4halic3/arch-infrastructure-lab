#!/usr/bin/env bash
#
# disk-report.sh
#
# Mostra rapidamente o uso geral de disco e as 10 pastas mais pesadas
# dentro da partição raiz, sem varrer partições montadas separadamente
# (ex: /home em outro disco).
#
# Uso:
#   ./disk-report.sh

set -euo pipefail

echo "== Uso geral de disco =="
df -h --total | grep -E "(Sist|/$|total)"

echo
echo "== Top 10 diretórios mais pesados em / =="
sudo du -xh / 2>/dev/null | sort -rh | head -n 10
