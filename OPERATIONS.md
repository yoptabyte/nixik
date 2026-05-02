# Эксплуатация конфигурации NixOS (non-flake, Nilla-based)

Этот документ описывает повседневные операции с non-flake конфигурацией на базе **Npins + Nilla + Nilla-NixOS + Hjem**.

## Содержание

- [Быстрый старт](#быстрый-старт)
- [Структура проекта](#структура-проекта)
- [Работа с npins (зависимости)](#работа-с-npins-зависимости)
- [Сборка и применение системы](#сборка-и-применение-системы)
- [Добавление пакетов](#добавление-пакетов)
- [Обновление системы](#обновление-системы)
- [Откат изменений](#откат-изменений)
- [Сборка мусора (GC)](#сборка-мусора-gc)
- [Работа с Hjem (home конфигурация)](#работа-с-hjem-home-конфигурация)
- [Troubleshooting](#troubleshooting)

---

## Быстрый старт

```bash
# 1. Перейти в директорию конфигурации
cd ~/nixos-config

# 2. Войти в devShell (nilla-cli, npins, nilla-nixos)
nix-shell

# 3. Собрать и применить систему
nilla-nixos switch

# Или только собрать (без применения)
nilla-nixos build

# 4. Обновить зависимости
npins update
```

---

## Структура проекта

```
nixos-config/
├── npins/
│   ├── default.nix          # Npins bootstrap (генерируется автоматически)
│   └── sources.json         # Закрепленные зависимости (замена flake.lock)
├── nilla.nix                # Корневой файл Nilla (единственная точка входа)
├── shells/
│   ├── default.nix          # Включение shell модулей
│   └── nilla/
│       └── default.nix      # DevShell с npins, nilla-cli, nilla-nixos
├── hosts/
│   └── xps15_9550/
│       ├── configuration.nix       # Основной конфиг хоста (+ Hjem home)
│       └── hardware-configuration.nix
├── modules/
│   ├── nixos/               # Системные модули
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
│   └── home/
│       ├── nixvim.nix
│       └── files/
├── xlibre-build-options/
│   └── driver-choice.nix    # Конфигурация XLibre драйверов
├── .gitignore
└── README.md
```

---

## Работа с npins (зависимости)

[Npins](https://github.com/andir/npins) — инструмент для pinning зависимостей в Nix без flakes. Все зависимости (nixpkgs, hjem, zen-browser, xlibre-overlay и др.) управляются через `npins/sources.json`.

### Обновление зависимостей

```bash
# Обновить ВСЕ pins (nixpkgs, hjem, и т.д.)
npins update

# Обновить только конкретный pin
npins update nixpkgs
npins update hjem

# Предпросмотр изменений (dry-run)
npins update --dry-run

# Показать текущие зависимости
npins show
```

### Добавление новой зависимости

```bash
# GitHub репозиторий (branch)
npins add github owner repo --branch main

# GitHub репозиторий (release)
npins add github owner repo --release-prefix v

# Git репозиторий (Codeberg и др.)
npins add git https://codeberg.org/owner/repo.git --branch main

# Примеры:
npins add github feel-co hjem --branch main
npins add github snugnug hjem-rum --branch main
npins add github zed-industries zed --branch main
npins add git https://codeberg.org/takagemacoed/xlibre-overlay.git --branch main
```

### Удаление зависимости

```bash
npins remove pin-name
```

### Как это работает

`npins/sources.json` — это lock-файл с хэшами, ревизиями и URL. `npins/default.nix` — загрузчик, который превращает JSON в Nix-выражения. `nilla.nix` автоматически подхватывает все pins и загружает их через Nilla loaders (flake-loader для flake-based репозиториев).

---

## Сборка и применение системы

### Основной способ: nilla-nixos (рекомендуется)

`nilla-nixos` — CLI для сборки NixOS конфигураций из Nilla проекта.

```bash
# Войти в devShell (где есть nilla-cli и nilla-nixos)
nix-shell

# Собрать систему для текущего hostname
nilla-nixos build

# Применить систему (switch)
nilla-nixos switch

# Собрать для конкретного hostname
nilla-nixos build --name xps15
nilla-nixos switch --name xps15
```

Под капотом `nilla-nixos switch` делает:
```bash
sudo nixos-rebuild switch \
  --file ./nilla.nix \
  --attr 'systems.nixos."xps15".result'
```

### Альтернативный способ: nixos-rebuild напрямую

Если nilla-cli не доступен, можно напрямую:

```bash
# Сборка
sudo nixos-rebuild build \
  --file nilla.nix \
  --attr 'systems.nixos."xps15".result'

# Применение
sudo nixos-rebuild switch \
  --file nilla.nix \
  --attr 'systems.nixos."xps15".result'

# Тест (без добавления в boot menu)
sudo nixos-rebuild test \
  --file nilla.nix \
  --attr 'systems.nixos."xps15".result'
```

### Альтернативный способ: nix-build (только сборка)

```bash
nix-build nilla.nix -A 'systems.nixos."xps15".result.config.system.build.toplevel'

# После сборки применить
sudo ./result/bin/switch-to-configuration switch
```

---

## Добавление пакетов

### Системные пакеты (для всех пользователей)

Редактируй соответствующий модуль в `modules/nixos/`:

```nix
# modules/nixos/productivity.nix
{ config, lib, pkgs, inputs, ... }:
{
  environment.systemPackages = with pkgs; [
    # Существующие пакеты...
    obsidian
    anki

    # Новый пакет
    neofetch
  ];
}
```

### Пакеты из npins inputs (flake-based репозитории)

Для пакетов, которые поставляются как flake outputs (zen-browser, zed, ayugram и др.):

```nix
# modules/nixos/browsers.nix
{ config, lib, pkgs, inputs, ... }:
let
  getPkg = name: fallback:
    let input = inputs.${name} or {}; in
    ((input.result.packages or {}).${pkgs.stdenv.hostPlatform.system} or {}).default or fallback;
in
{
  environment.systemPackages = [
    (getPkg "zen-browser" pkgs.firefox)
  ];
}
```

### Пользовательские пакеты (через Hjem)

Редактируй `hosts/xps15_9550/configuration.nix` в секции `hjem.users.yoptabyte.packages`:

```nix
hjem.users.yoptabyte = {
  enable = true;
  packages = with pkgs; [
    # Добавь новые пакеты сюда
    neofetch
    cmatrix
  ];
};
```

### Home файлы (конфигурации)

Также в `hjem.users.yoptabyte.files`:

```nix
hjem.users.yoptabyte.files = {
  ".config/neofetch/config.conf".text = ''
    # Конфигурация neofetch
    print_info() {
        info title
        info underline
        info "OS" distro
    }
  '';
};
```

### Добавить новый npins input и использовать в системе

```bash
# 1. Добавить зависимость
npins add github owner new-package --branch main

# 2. Использовать в модуле
# inputs.new-package.result.packages.x86_64-linux.default
```

---

## Обновление системы

### Полное обновление (все шаги)

```bash
cd ~/nixos-config

# 1. Обновить все pins
npins update

# 2. Проверить статус через jj
jj status

# 3. Собрать систему
nix-shell -p nilla-nixos --run "nilla-nixos build"

# 4. Применить
nix-shell -p nilla-nixos --run "nilla-nixos switch"

# Или внутри nix-shell:
nix-shell
nilla-nixos switch
```

### Обновить только nixpkgs

```bash
npins update nixpkgs
nix-shell
nilla-nixos switch
```

### Обновить только один flake-based пакет

```bash
npins update zen-browser
npins update zed
nix-shell
nilla-nixos switch
```

---

## Откат изменений

### Откат системы (NixOS generations)

```bash
# Просмотреть предыдущие поколения
sudo nix-env -p /nix/var/nix/profiles/system --list-generations

# Откатить к предыдущему поколению
sudo nixos-rebuild switch --rollback

# Или переключиться на конкретное поколение
sudo /nix/var/nix/profiles/system-42/bin/switch-to-configuration switch
```

### Откат npins

```bash
# Восстановить предыдущую версию sources.json через git
git checkout HEAD~1 -- npins/sources.json

# Или через jj
jj restore --from @- npins/sources.json
```

---

## Сборка мусора (GC)

### Ручная сборка

```bash
# Удалить недостижимые пути старше 7 дней
sudo nix-collect-garbage --delete-older-than 7d

# Удалить все недостижимые пути
sudo nix-collect-garbage -d
```

### Автоматическая сборка (уже настроена)

В `modules/nixos/nix-settings.nix`:

```nix
nix.gc = {
  automatic = true;
  dates = "weekly";
  options = "--delete-older-than 14d";
};
```

### Оптимизация хранилища

```bash
# Дедупликация (hardlinks)
sudo nix-store --optimise
```

---

## Работа с Hjem (home конфигурация)

[Hjem](https://github.com/feel-co/hjem) управляет home-конфигурацией через NixOS модуль (вместо standalone Home Manager).

### Где настраивать

Вся home конфигурация находится в `hosts/xps15_9550/configuration.nix` внутри:

```nix
hjem = {
  clobberByDefault = true;
  extraModules = [
    # Hjem-rum modules (дополнительные программы)
    inputs.hjem-rum.result.hjemModules.default
  ];
  users.yoptabyte = {
    enable = true;
    files = {
      # Конфигурационные файлы
    };
    packages = [
      # Пользовательские пакеты
    ];
  };
};
```

### Hjem-rum (дополнительные модули)

[Hjem-rum](https://github.com/snugnug/hjem-rum) — коллекция модулей для Hjem. Уже подключена через `extraModules`.

Пример использования hjem-rum модулей:

```nix
# В любом NixOS модуле:
hjem.users.yoptabyte.rum.programs.alacritty = {
  enable = true;
  settings = {
    window.padding = { x = 6; y = 3; };
  };
};
```

### Добавить файл конфигурации

```nix
hjem.users.yoptabyte.files = {
  ".config/nvim/init.lua".text = ''
    -- Neovim configuration
    vim.opt.number = true
  '';

  # Или скопировать из локального файла
  ".config/sway/config".source = ./sway-config;
};
```

### Добавить пакет для пользователя

```nix
hjem.users.yoptabyte.packages = with pkgs; [
  firefox
  thunderbird
  spotify
];
```

### Пересобрать home

Home конфигурация применяется автоматически при сборке NixOS системы:

```bash
nilla-nixos switch
```

Hjem создаёт systemd юнит `hjem-apply.service` который запускается при логине.

---

## Troubleshooting

### Ошибка: `A Nixpkgs instance is required for the NixOS system`

**Причина**: В `nilla.nix` не передан `pkgs` в `systems.nixos.<name>`.

**Решение**: Убедись, что в `nilla.nix` указан `pkgs`:

```nix
systems.nixos.xps15 = {
  pkgs = config.inputs.nixpkgs.result.x86_64-linux;
  modules = [ ./hosts/xps15_9550/configuration.nix ];
};
```

### Ошибка: `Your system configures nixpkgs with an externally created instance`

**Причина**: В модулях используется `nixpkgs.config.*`, но nixpkgs уже создан вне NixOS.

**Решение**: Убери `nixpkgs.config.*` из модулей — настройки передаются при создании nixpkgs в `nilla.nix`:

```nix
# nilla.nix
inputs.nixpkgs.settings.configuration.allowUnfree = true;
```

### Ошибка: `path '...' is not valid`

**Причина**: Проблема с `pkgs.path` при загрузке через Nilla.

**Решение**: Используй `nixos-rebuild --file nilla.nix --attr 'systems.nixos."xps15".result'` вместо `nix-build`.

### Ошибка: `attribute 'result' missing`

**Причина**: Input из npins загружается через Nilla, но не flake-based — у него нет `.result`.

**Решение**: Для flake-based inputs (которые имеют flake.nix) Nilla автоматически создаёт `.result`. Для raw git repos используй `.src` или `.outPath`.

### Ошибка: `attribute 'nixosModules' missing`

**Причина**: Input не загружен как flake.

**Решение**: В `nilla.nix` Nilla автоматически определяет loader по содержимому. Если в репозитории есть `flake.nix` — используется flake-loader. Проверь, что `inputs.<name>.result` существует:

```bash
nix-instantiate nilla.nix -A 'config.inputs.zen-browser.result' --eval
```

### Ошибка: `infinite recursion encountered`

**Причина**: Циклическая зависимость в модулях.

**Решение**: Проверь `imports` в модулях. Не импортируй модуль сам в себя.

### Ошибка сборки: `failed dependency`

**Причина**: Sandbox или недоступный binary cache.

**Решение**:

```bash
# Проверить настройки nix
nix show-config | grep sandbox

# Временно отключить sandbox (только для теста)
sudo nixos-rebuild build --option sandbox false ...
```

### Проверить eval без полной сборки

```bash
nix-instantiate nilla.nix \
  -A 'systems.nixos."xps15".result.config.system.build.toplevel' \
  2>&1 | head -n 5
```

Если не выдаёт ошибок сразу — eval проходит.

---

## Полезные алиасы

Добавь в `~/.config/zsh/.zshrc` (уже настроено через Hjem):

```zsh
# Nilla NixOS rebuild
alias nrs='nix-shell --run "nilla-nixos switch"'
alias nrb='nix-shell --run "nilla-nixos build"'

# Npins
alias npu='nix-shell -p npins --run "npins update"'
alias nps='nix-shell -p npins --run "npins show"'

# Garbage collection
alias ngc='sudo nix-collect-garbage --delete-older-than 7d'

# Quick edit config
alias ncfg='cd ~/nixos-config && nvim nilla.nix'
```

---

## Сравнение с Flakes

| Операция | Flakes | Non-Flake (Npins + Nilla) |
|---|---|---|
| Обновить зависимости | `nix flake update` | `npins update` |
| Собрать систему | `nixos-rebuild switch --flake .#host` | `nilla-nixos switch` |
| Добавить input | Править `flake.nix` | `npins add github owner repo` |
| Dev shell | `nix develop` | `nix-shell` |
| Lock файл | `flake.lock` | `npins/sources.json` |
| Entry point | `flake.nix` | `nilla.nix` |

---

## Ссылки

- [Npins](https://github.com/andir/npins)
- [Nilla](https://github.com/nilla-nix/nilla)
- [Nilla-NixOS](https://github.com/nilla-nix/nixos)
- [Nilla-CLI](https://github.com/nilla-nix/cli)
- [Hjem](https://github.com/feel-co/hjem)
- [Hjem-Rum](https://github.com/snugnug/hjem-rum)
- [Airranix (reference repo)](https://github.com/Airradda/Airranix)
