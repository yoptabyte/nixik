# NixOS Configuration (Non-Flake)

A modular NixOS configuration for the **Dell XPS 15 9550** laptop, built without flakes using **Npins + Nilla + Hjem**.

## Stack

| Purpose | Tool |
|---|---|
| Dependency pinning | [npins](https://github.com/andir/npins) |
| Project management | [Nilla](https://github.com/nilla-nix/nilla) |
| Home configuration | [Hjem](https://github.com/feel-co/hjem) + [Hjem-Rum](https://github.com/snugnug/hjem-rum) |
| VCS | [Jujutsu (jj)](https://github.com/jj-vcs/jj) |
| Editor | [Nixvim](https://github.com/nix-community/nixvim) + Emacs |
| Window manager | Sway (Wayland) |

## Hardware

- **CPU**: Intel Core i7-6700HQ
- **GPU**: Intel HD Graphics 530 + NVIDIA GeForce GTX 960M (PRIME offload)
- **Display**: 15.6" 4K touchscreen
- **RAM**: 16 GB DDR4

## Structure

```
nixos-config/
├── hosts/
│   └── xps15_9550/
│       ├── configuration.nix       # Host config + Hjem home
│       └── hardware-configuration.nix
├── modules/
│   ├── nixos/                      # System modules
│   │   ├── browsers.nix
│   │   ├── creative.nix
│   │   ├── desktop/
│   │   │   ├── sway.nix            # Sway WM config
│   │   │   ├── cosmic.nix
│   │   │   ├── wayfire.nix
│   │   │   └── xfce.nix
│   │   ├── emacs.nix               # Emacs + k380-graphite theme
│   │   ├── gaming.nix
│   │   ├── llm-agents.nix
│   │   ├── nix-settings.nix
│   │   ├── productivity.nix
│   │   ├── social.nix
│   │   └── terminal.nix
│   └── home/
│       ├── files/                  # Static config files
│       │   ├── k380-graphite-theme.el
│       │   ├── p10k.zsh
│       │   ├── sway-config
│       │   └── ...
│       └── nixvim.nix              # Nixvim configuration
├── xlibre-build-options/           # XLibre X11 server overrides
│   ├── driver-choice.nix
│   └── my-xlibre-xserver-build-options.nix
├── npins/
│   ├── default.nix                 # Npins loader
│   └── sources.json                # Pinned dependencies
├── nilla.nix                       # Nilla project root
├── shell.nix                       # Dev shell (npins, nilla-cli)
└── README.md                       # This file
```

## Key Features

### Desktop
- **Sway** with custom keybindings and status bar (i3status-rust)
- **Ly** display manager
- US / RU keyboard layouts with Caps Lock switching

### Terminal & Shell
- **Ghostty** — GPU-accelerated terminal with amber/gold theme matching the entire setup
- **Tmux** — custom theme, Vi keys, integration with Claude / Codex / Opencode
- **Zsh** — Powerlevel10k, fzf, zoxide, eza, bat
- **Nushell** — structured shell with git aliases

### Editors
- **Nixvim** — Full IDE setup with LSP, Telescope, Neo-tree, Treesitter, custom K380 Graphite colorscheme
- **Emacs** — Daemon mode, Vertico/Consult/Orderless/Marginalia, Evil mode, Magit, Eglot LSP, **K380 Graphite theme**

### Themes
The **K380 Graphite** theme is shared across the entire stack:
- Nixvim (Lua highlights)
- Emacs (custom theme file)
- Ghostty (palette)
- Tmux (status bar)

Colors: warm dark background `#28261F`, gold accent `#F0C040`, sage green `#A8D8A0`, amber `#E8A020`.

### System
- **NVIDIA PRIME** offload (Intel iGPU + NVIDIA dGPU)
- **PipeWire** audio
- **XLibre overlay** — custom X11 server build with selected drivers (see `xlibre-build-options/`)
- **Bluetooth**, **NetworkManager**, **Power Profiles Daemon**

## Quick Start

### Enter dev shell

```bash
cd ~/nixos-config
nix-shell
```

### Update dependencies

```bash
npins update        # Update all pins
npins update nixpkgs # Update only nixpkgs
```

### Build / Switch system

```bash
# Build only
nilla-nixos build

# Build and switch
nilla-nixos switch

# Or directly with nixos-rebuild
sudo nixos-rebuild switch \
  --file nilla.nix \
  --attr 'systems.nixos."xps15".result'
```

## XLibre

This configuration uses the **[XLibre](https://codeberg.org/takagemacoed/xlibre-overlay)** overlay to replace the stock NixOS X11 server with a custom-built Xorg. Driver selection and build flags are controlled in `xlibre-build-options/`:

- `driver-choice.nix` — selects which X11 drivers to include/exclude
- `my-xlibre-xserver-build-options.nix` — custom meson build flags

This is loaded via the `xlibre-overlay` npins input in `nilla.nix`.

## Emacs Notes

Emacs is installed via `pkgs.emacs.pkgs.withPackages` with a curated set of packages:

| Package | Purpose |
|---|---|
| vertico | Vertical completion UI |
| orderless | Completion style |
| marginalia | Annotations in minibuffer |
| consult | Search/navigation commands |
| which-key | Keybinding discovery |
| evil + evil-collection | Vim emulation |
| magit | Git interface |
| doom-modeline | Mode line |
| nix-mode | Nix editing |
| treesit-grammars | Treesitter support |

The **K380 Graphite** theme file lives in `modules/home/files/k380-graphite-theme.el` and is loaded from `~/.emacs.d/themes/`.

> **Note on `emacs-lucid`**: `emacs-lucid` is not available as a top-level nixpkgs attribute. If you prefer the Lucid (Athena) toolkit over GTK, override `pkgs.emacs` with `withLucid = true`. See comments in `modules/nixos/emacs.nix`.

## VCS (Jujutsu)

This repo uses **jj** instead of git for daily work. Git is kept colocated (`.git/` + `.jj/`) so that Nilla's `builtins.fetchGit` still works.

```bash
# Commit (in jj it's just describe — files auto-track)
jj describe -m "message"

# Push to GitHub
jj git push --bookmark main --remote origin

# View log
jj log
```

Remote: `git@github.com:yoptabyte/nixik.git`

## License

MIT / Apache-2.0 (your choice)
