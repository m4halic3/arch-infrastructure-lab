# arch-system-autopilot

[![ShellCheck](https://github.com/m4halic3/arch-system-autopilot/actions/workflows/shellcheck.yml/badge.svg)](https://github.com/m4halic3/arch-system-autopilot/actions/workflows/shellcheck.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
![Shell](https://img.shields.io/badge/shell-bash-4EAA25?logo=gnubash&logoColor=white)
![Arch Linux](https://img.shields.io/badge/Arch%20Linux-1793D1?logo=arch-linux&logoColor=white)

Automação de manutenção de sistema para Arch Linux: mantém a partição raiz
saudável limpando cache do `pacman`, imagens/volumes órfãos do Docker,
runtimes não usados do Flatpak e logs antigos do `journald` — tudo agendado
via `systemd timer`, sem intervenção manual.

Criado a partir de um problema real (partição raiz chegando a 98% de uso
por acúmulo de cache e imagens Docker) — diagnóstico completo em
[`docs/TROUBLESHOOTING.md`](docs/TROUBLESHOOTING.md).

## Por que isso é útil

Em sistemas Arch com partição raiz pequena, `/var/lib/docker`,
`/var/lib/flatpak` e o cache do `pacman` crescem silenciosamente até o
disco encher — e quando isso acontece, o sistema começa a travar até para
operações básicas, porque o kernel não consegue mais gravar arquivos
temporários. Esse tipo de problema é comum em:

- Notebooks com SSDs pequenos (40-60GB no `/`)
- Ambientes de desenvolvimento com Docker usado com frequência
- Instalações Arch de longa duração sem rotina de manutenção

Este projeto resolve isso automatizando a limpeza recorrente, para que o
problema nunca mais chegue a um estado crítico.

## O que este projeto faz

- Limpa o cache de pacotes do `pacman`, mantendo apenas a versão instalada
- Remove containers parados, imagens e volumes Docker não utilizados
- Remove runtimes Flatpak órfãos
- Reduz logs do `journald` para um tamanho máximo configurável
- Roda tudo automaticamente, uma vez por semana, com baixa prioridade de
  CPU/IO, via `systemd timer`
- Tem modo `--dry-run` para auditar o que seria feito antes de confiar
  no script

## Instalação rápida

```bash
git clone https://github.com/m4halic3/arch-system-autopilot.git
cd arch-system-autopilot
sudo ./install.sh
```

Isso instala os scripts em `/usr/local/bin` e ativa o timer semanal.

Verifique o agendamento:

```bash
systemctl list-timers cleanup.timer
```

## Uso manual

```bash
# Ver o que seria limpo, sem executar de fato
sudo cleanup-system.sh --dry-run

# Rodar a limpeza agora
sudo cleanup-system.sh

# Relatório rápido de uso de disco
disk-report.sh
```

## Estrutura do repositório

```
.
├── install.sh                  # instalador em um comando
├── scripts/
│   ├── cleanup-system.sh       # lógica principal de limpeza
│   └── disk-report.sh          # diagnóstico rápido de uso de disco
├── systemd/
│   ├── cleanup.service         # unidade oneshot, baixa prioridade
│   └── cleanup.timer           # agendamento semanal com jitter
├── docs/
│   ├── ARCHITECTURE.md         # como as peças se conectam
│   └── TROUBLESHOOTING.md      # o incidente real que originou o projeto
└── .github/workflows/          # CI com ShellCheck
```

Mais detalhes de design em [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md).

## Pré-requisitos

- Arch Linux (ou derivada) com `systemd`
- `sudo` configurado
- Docker e/ou Flatpak são opcionais — o script detecta o que está
  instalado e pula o que não está presente

## Testado em

- Arch Linux, kernel `linux-lts`, Hyprland (Wayland)
- Hardware modesto: AMD Ryzen 3 2200U, 16GB RAM, GPU integrada Vega 3

## Roadmap

- [ ] Suporte a outras distros (`apt`, `dnf`)
- [ ] Notificação desktop (`notify-send`) ao final da limpeza
- [ ] Exportação de métricas para Prometheus/Grafana

## Contribuindo

Issues e sugestões são bem-vindas. Veja [`CONTRIBUTING.md`](CONTRIBUTING.md)
para detalhes de como propor mudanças.

## Licença

[MIT](LICENSE) © Mariana Alice