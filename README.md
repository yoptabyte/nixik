# Airranix-inspired non-flake NixOS configuration

Модульная конфигурация NixOS без флейков, использующая:

- **Npins** — pinning зависимостей (замена flakes inputs)
- **Nilla** — управление проектом (замена flakes outputs)
- **Hjem / Hjem-Rum** — управление home конфигурацией (замена Home Manager)
- **Jujutsu (jj)** — VCS для управления репозиторием

> **Примечание**: `sopsWarden` и `nilla-cli` упомянуты в планах, но пока не интегрированы. Основной workflow работает через `nix-build` + `npins`.

## Структура

```
nixos-config/
├── npins/
│   ├── default.nix              # Npins bootstrap (генерируется)
│   └── sources.json             # Закрепленные зависимости
├── nilla.nix                    # Корневой файл Nilla
├── shells/
│   ├── default.nix              # Включение shell модулей
│   └── nilla/
│       └── default.nix          # Dev shell с npins
├── modules/
│   ├── Settings.nix             # Общие настройки системы
│   ├── nixos/                   # Системные модули
│   │   ├── nix-settings.nix
│   │   ├── llm-agents.nix
│   │   ├── browsers.nix
│   │   ├── gaming.nix
│   │   ├── creative.nix
│   │   ├── productivity.nix
│   │   ├── terminal.nix
│   │   ├── social.nix
│   │   └── desktop/
│   │       └── sway.nix
│   └── home/                    # Home модули (Hjem)
│       ├── default.nix
│       └── hjem/
│           └── default.nix
├── hosts/
│   └── xps15_9550/
│       ├── configuration.nix    # Основной конфиг хоста (+ Hjem home)
│       └── hardware-configuration.nix
├── OPERATIONS.md                # Подробное руководство по эксплуатации
└── README.md                    # Этот файл
```

## Быстрый старт

### 1. Обновить зависимости (npins)

```bash
cd ~/nixos-config
nix-shell -p npins --run "npins update"
```

### 2. Собрать систему

```bash
nix-build --expr '
  let
    nixpkgs = import (import ./npins).nixpkgs.outPath {
      system = "x86_64-linux";
      config.allowUnfree = true;
    };
    pins = import ./npins;
  in
  (import (toString nixpkgs.path + "/nixos/lib/eval-config.nix") {
    system = "x86_64-linux";
    specialArgs = { inputs = pins; };
    modules = [ ./hosts/xps15_9550/configuration.nix ];
  }).config.system.build.toplevel
'
```

### 3. Применить систему

```bash
sudo ./result/bin/switch-to-configuration switch
```

> См. [OPERATIONS.md](./OPERATIONS.md) для подробного руководства по эксплуатации.

## Что сохранено из оригинальной конфигурации

Все пакеты и конфигурации остались:

- **Neovim** (nixvim) → сконфигурирован через Hjem `files`
- **Ghostty** → полная конфигурация с amber темой
- **Tmux** → кастомная тема, все биндинги, интеграция с claude/codex/opencode
- **Zsh** → powerlevel10k, fzf, zoxide, eza, bat алиасы
- **Nushell** → git алиасы
- **Yazi** → правила открытия файлов
- **Sway** → весь конфиг из `modules/nixos/desktop/sway.nix`
- **Пакеты**: obsidian, anki, qbittorrent, zathura, helix, zed, vesktop, ayugram, zen-browser, helium, claude-code, codex, opencode, antigravity, ollama, и т.д.
- **Системные настройки**: NVIDIA PRIME, PipeWire, Bluetooth, Sway, X11, Ly DM

## Миграция с Flakes

| Flakes | Non-Flake |
|---|---|
| `flake.nix` | `nilla.nix` |
| `flake.lock` | `npins/sources.json` |
| `nix flake update` | `npins update` |
| `nix develop` | `nix-shell` |
| `nix build .#nixosConfigurations.host` | `nix-build --expr '...'` |
| `home-manager` | `hjem` (через NixOS модуль) |

## Лицензия

MIT / Apache-2.0 (на выбор)
