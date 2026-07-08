# Contribuindo

Contribuições são bem-vindas! Este é um projeto pequeno e focado, então o
processo é simples:

1. Abra uma *issue* descrevendo o problema ou a melhoria proposta.
2. Faça um fork do repositório e crie uma branch a partir da `main`:
   ```bash
   git checkout -b minha-melhoria
   ```
3. Teste suas alterações localmente. Para os scripts shell, rode o
   [ShellCheck](https://www.shellcheck.net/) antes de abrir o PR:
   ```bash
   shellcheck scripts/*.sh install.sh
   ```
4. Abra um Pull Request explicando o que foi alterado e por quê.

## Ideias de contribuição

- Suporte a outras distros (Debian/Ubuntu com `apt`, Fedora com `dnf`)
- Notificação via `notify-send`/`dunst` ao final da limpeza
- Métricas exportadas para Prometheus/Grafana
- Testes automatizados com [bats-core](https://github.com/bats-core/bats-core)
