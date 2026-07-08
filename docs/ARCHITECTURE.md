# Arquitetura

Este projeto é composto por três camadas simples e desacopladas:

```
┌─────────────────────────────┐
│   systemd/cleanup.timer     │  agenda a execução (semanal, com jitter)
└──────────────┬───────────────┘
               │ dispara
               ▼
┌─────────────────────────────┐
│  systemd/cleanup.service     │  roda como oneshot, prioridade baixa
└──────────────┬───────────────┘
               │ executa
               ▼
┌─────────────────────────────┐
│ scripts/cleanup-system.sh    │  lógica de limpeza (pacman/docker/flatpak/journald)
└───────────────────────────────┘
```

## Por que systemd timer em vez de cron?

- Integração nativa com logs (`journalctl -u cleanup.service`)
- `Persistent=true`: se o notebook estiver desligado no horário agendado, a
  tarefa roda assim que o sistema for ligado novamente
- `RandomizedDelaySec`: evita que a rotina sempre rode no exato mesmo minuto
- `Nice=19` e `IOSchedulingClass=idle`: a limpeza roda em baixa prioridade,
  sem competir por CPU/IO com o que você está fazendo naquele momento

## Por que `set -euo pipefail` no script?

Evita que o script continue executando silenciosamente após um erro (por
exemplo, uma variável não definida ou um comando que falhou), o que poderia
mascarar problemas em produção.

## Modo dry-run

`cleanup-system.sh --dry-run` mostra todos os comandos que seriam
executados, sem de fato apagar nada. Útil para auditar o que o script faz
antes de confiar nele em uma máquina nova.
