#!/usr/bin/env bash
#
# cleanup-system.sh
#
# Rotina de manutenção para Arch Linux: limpa cache do pacman, imagens Docker
# não utilizadas, runtimes órfãos do Flatpak e logs antigos do journald.
#
# Autora: Mariana Alice
# Licença: MIT
#
# Uso:
#   sudo ./cleanup-system.sh          # roda a limpeza completa
#   sudo ./cleanup-system.sh --dry-run  # apenas mostra o que seria feito

set -euo pipefail

LOGFILE="/var/log/system-cleanup.log"
DRY_RUN=false

if [[ "${1:-}" == "--dry-run" ]]; then
    DRY_RUN=true
fi

log() {
    echo "$1" | tee -a "$LOGFILE"
}

run() {
    if $DRY_RUN; then
        log "[DRY-RUN] $*"
    else
        "$@" >>"$LOGFILE" 2>&1 || log "[AVISO] Falha ao executar: $*"
    fi
}

require_root() {
    if [[ $EUID -ne 0 ]]; then
        echo "Este script precisa ser executado com sudo/root." >&2
        exit 1
    fi
}

disk_usage_root() {
    df -h / | awk 'NR==2 {print $5}'
}

main() {
    require_root

    log "==================================================="
    log "Limpeza iniciada em $(date '+%Y-%m-%d %H:%M:%S')"
    log "Uso do disco (/) antes: $(disk_usage_root)"
    log "==================================================="

    log "-> Limpando cache do pacman (mantendo última versão instalada)..."
    run pacman -Sc --noconfirm
    if command -v paccache >/dev/null 2>&1; then
        run paccache -rk1
    fi

    if command -v docker >/dev/null 2>&1; then
        log "-> Limpando containers, imagens e volumes órfãos do Docker..."
        run docker system prune -af --volumes
    fi

    if command -v flatpak >/dev/null 2>&1; then
        log "-> Removendo runtimes Flatpak não utilizados..."
        run flatpak uninstall --unused -y
    fi

    log "-> Reduzindo logs do journald para 200MB..."
    run journalctl --vacuum-size=200M

    log "-> Limpando arquivos temporários órfãos..."
    if $DRY_RUN; then
        log "[DRY-RUN] rm -rf /var/tmp/*"
    else
        find /var/tmp/ -mindepth 1 -delete 2>>"$LOGFILE" || log "[AVISO] Falha ao limpar /var/tmp"
    fi

    log "==================================================="
    log "Uso do disco (/) depois: $(disk_usage_root)"
    log "Limpeza finalizada em $(date '+%Y-%m-%d %H:%M:%S')"
    log "==================================================="
}

main "$@"