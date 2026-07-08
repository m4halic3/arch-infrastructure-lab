# Changelog

Este projeto segue [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/)
e [Semantic Versioning](https://semver.org/lang/pt-BR/).

## [1.0.0] - 2026-07-08

### Adicionado
- Script `cleanup-system.sh` com modo `--dry-run` e logging estruturado
- Script `disk-report.sh` para diagnóstico rápido de uso de disco
- Unidades systemd (`cleanup.service` + `cleanup.timer`) para agendamento
  semanal com baixa prioridade de CPU/IO
- `install.sh` para instalação em um único comando
- Documentação de arquitetura e troubleshooting (`docs/`)
