# Troubleshooting: Crise de Armazenamento (caso real)

Este projeto nasceu de um incidente real: a partição raiz (`/`) de um
notebook com Arch Linux + Hyprland chegou a **98% de uso**, deixando o
sistema instável (I/O wait alto, travamentos ao rodar comandos simples).

## Diagnóstico

O primeiro passo foi identificar os maiores consumidores de espaço na
partição raiz, sem entrar em outras partições montadas:

```bash
sudo du -xh / 2>/dev/null | sort -rh | head -n 10
```

Resultado do caso real:

| Diretório | Tamanho |
|---|---|
| `/var` | 22G |
| `/usr` | 20G |
| `/var/lib` | 17G |
| `/var/lib/containerd` | 12G |
| `/usr/lib` | 8.7G |
| `/var/lib/flatpak` | 4.4G |

O maior vilão era o **containerd/Docker**: imagens, containers parados e
volumes órfãos acumulados ao longo de meses de desenvolvimento.

## Ações que resolveram

1. **Cache de pacotes do pacman**
   ```bash
   sudo pacman -Sc --noconfirm
   sudo paccache -rk1
   ```

2. **Imagens e volumes Docker não utilizados** (o maior ganho: ~12,7 GB)
   ```bash
   sudo docker system prune -af --volumes
   ```

3. **Runtimes órfãos do Flatpak**
   ```bash
   flatpak uninstall --unused -y
   ```

4. **Logs antigos do journald**
   ```bash
   sudo journalctl --vacuum-size=200M
   ```

Resultado: uso da partição raiz caiu de **98% para 71%**.

## Armadilhas encontradas

- **`journalctl` sem sudo falha silenciosamente** com "Permissão negada" ao
  tentar apagar journals antigos — sempre rodar com privilégios de root.
- **Downloads de pacotes interrompidos** deixam arquivos temporários
  (`/var/cache/pacman/pkg/download-*`) que o `pacman -Sc` não remove
  sozinho. Nesse caso, é necessário removê-los manualmente:
  ```bash
  sudo rm -rf /var/cache/pacman/pkg/download-*
  ```
- **`du` pode travar** em sistemas com disco quase cheio (>95%), pois o
  kernel tem dificuldade de alocar espaço para operações temporárias. Se
  isso acontecer, priorize liberar espaço óbvio primeiro (cache do
  pacman, `docker system prune`) antes de rodar varreduras completas.

## Prevenção

A automação deste repositório (`cleanup.timer` + `cleanup-system.sh`)
existe justamente para que esse tipo de crise não se repita: a limpeza
roda semanalmente em segundo plano, sem intervenção manual.

Como boa prática adicional, considere isolar `/var/lib/docker` em uma
partição própria (ou em `/home`, que tende a ter mais espaço livre) em
instalações futuras, já que esse diretório cresce de forma imprevisível.
