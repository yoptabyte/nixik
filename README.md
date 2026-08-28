# NixOS Configuration (Non-Flake)

A modular NixOS configuration for **Dell XPS 15 9550**, **ThinkPad X390**, and **MacBook**, built without flakes using **Npins + Nilla + Hjem**.

## Stack

| Purpose | Tool |
|---|---|
| Dependency pinning | [npins](https://github.com/andir/npins) |
| Project management | [Nilla](https://github.com/nilla-nix/nilla) |
| Home configuration | [Hjem](https://github.com/feel-co/hjem) + [Hjem-Rum](https://github.com/snugnug/hjem-rum) |
| VCS | [Jujutsu (jj)](https://github.com/jj-vcs/jj) |
| Editor | [Nixvim](https://github.com/nix-community/nixvim) + Emacs |
| Window managers | Hyprland (Wayland) and XMonad (X11) on Linux; AeroSpace on macOS |

## Hardware

Linux hardware configs live in `hosts/<name>/hardware-configuration.nix`.
The MacBook uses nix-darwin, AeroSpace and SketchyBar; Ghostty and VLC are
installed through Homebrew.

The **Dell XPS 15 9550** (`hosts/xps15_9550/`):

- **CPU**: Intel Core i7-6700HQ
- **GPU**: Intel HD Graphics 530 + NVIDIA GeForce GTX 960M (PRIME offload)
- **Display**: 15.6" 4K touchscreen
- **RAM**: 16 GB DDR4

## Structure

```
nixos-config/
├── hosts/                         # Hardware and per-host differences
│   ├── macbook/
│   ├── thinkpad_x390/
│   └── xps15_9550/
├── modules/
│   ├── nixos/
│   │   ├── workstation.nix        # Shared Linux workstation imports
│   │   ├── laptop.nix             # Boot, network, audio, users, Docker
│   │   ├── desktop/
│   │   │   ├── default.nix        # Sessions, Ly, keyboard
│   │   │   ├── hyprland.nix       # Wayland desktop and services
│   │   │   ├── xmonad.nix         # X11 desktop, st, dmenu and dotfiles
│   │   │   └── vicinae.nix        # Launcher service
│   │   └── ...                    # Applications grouped by purpose
│   ├── home/
│   │   ├── hjem/                  # Shared files and per-host additions
│   │   ├── files/                 # Configuration grouped by application
│   │   └── nixvim.nix
│   ├── shared/                    # Shared packages and Emacs init
│   └── darwin/
├── wallpapers/                    # Desktop wallpapers (GIF, PNG)
├── packages/                      # Local Herdr and Hyprland plugin builds
├── xlibre-build-options/
├── npins/                         # Dependency pins
├── nilla.nix                      # Project entry point
└── shell.nix
```

## Key Features

### Desktop
- **Hyprland** with Gruvbox Light, Waybar, Mako notifications, Hyprlock/Hypridle, and the animated `wallpapers/garden_rain.gif` wallpaper via [awww](https://codeberg.org/LGFae/awww)
- **XMonad** is the second session (X11)
- **Ly** display manager
- US / RU keyboard layouts with Caps Lock switching
- **Vicinae** on Super+D and **dmenu** on Super+P or Super+Shift+D in both window managers
- **Hyprexpo** workspace overview on Super+G; **Phantomat** canvas on Super+Ctrl+G and canvas overview on Super+Ctrl+Shift+G
- Hyprland screenshots: Print copies a selected area to the clipboard; Super+Print saves it under `~/Pictures/`
- **Voxtype** dictation: Super+Ctrl+X to toggle, F9 to hold and speak; the multilingual model downloads when its Hyprland service first starts

### Terminal & Shell
- **Ghostty** — GPU-accelerated terminal using Gruvbox Light
- **Tmux** — custom theme, Vi keys, integration with Claude / Codex / Opencode
- **Herdr** — Gruvbox Light and tmux-style Ctrl+B, pane navigation, tabs, and agent popups
- **Nushell** — default shell with git aliases and Starship prompt; fzf, zoxide, eza and bat are available as CLI tools
- **fetch** — animated system information from [areofyl/fetch](https://github.com/areofyl/fetch)

### Editors
- **Nixvim** — LSP, Telescope, floating Neo-tree, Treesitter, Gruvbox Light and rainbow indent guides; tabline and the 80-column marker are disabled
- **Emacs** — Vertico/Consult/Orderless/Marginalia, Evil mode, Magit, Eglot LSP and Gruvbox Light; Linux uses a PGTK daemon for Wayland and a Lucid daemon for X11

Nixvim's leader key is Space. In normal mode:

| Keys | Action |
|---|---|
| `Space b b` or `Space f b` | Search and select buffers with Telescope; Enter opens the selection |
| `Space b n` / `Space b p` | Next / previous buffer |
| `Space b i` | Enter a buffer number or name, then Enter |
| `Space c` / `Space C` | Close / force-close the current buffer |

The indent highlight groups are registered in `indent-blankline.luaConfig.pre`
before plugin setup, and restored when the colorscheme changes.

### Themes
Hyprland, Waybar, Mako, Vicinae, Ghostty, Herdr, Nixvim and Emacs use
**Gruvbox Light**. Helix and Zed use **Kanagawa Lotus**; tmux has a custom
light palette in its per-host config.

Gruvbox colors include background `#fbf1c7`, foreground `#3c3836`, red
`#9d0006`, yellow `#b57614`, blue `#076678`, orange `#af3a03`, green
`#79740e`, purple `#8f3f71` and aqua `#427b58`.

K380 Graphite and Kanagawa Lotus Emacs themes, IntelliJ color schemes and
additional Vicinae themes remain available under `modules/home/files/`,
grouped by application. Desktop image assets live in `wallpapers/`.

### System
- **NVIDIA PRIME** offload (Intel iGPU + NVIDIA dGPU)
- **PipeWire** audio
- **XLibre overlay** — custom X11 server build with selected drivers (see `xlibre-build-options/`)
- **Bluetooth**, **NetworkManager**, **Power Profiles Daemon**
- **systemd-boot** keeps the five most recent generations in the EFI partition
- **LLM tools** on Linux: Node.js 22, nix-ld and Ollama; agent CLIs are installed separately with npm into `~/.npm-global`

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

## Build troubleshooting

Build phases (`fixupPhase`, `patchPhase`, etc.) and compiler warnings are normal
build output. A failed derivation is reported with `error: Cannot build`.
The local Herdr package builds the vendored Ghostty library with the LLVM
backend and uses GCC's compiler runtime instead of Zig's bundled runtime,
avoiding invalid ELF unwind data and runtime symbols (`.eh_frame_hdr refers to overlapping FDEs`). The rectangular selection patch is retained.

`No space left on device` during bootloader installation means the build may
have succeeded while activation failed. Check `df -h /boot` and `findmnt /boot`.
The shared `boot.loader.systemd-boot.configurationLimit = 5` limits boot-menu
generations and their kernel/initrd files when the bootloader is updated;
it does not delete Nix store generations. A read-only or damaged EFI filesystem
must be addressed before retrying activation.

## Kernel and filesystems

The shared kernel default is in `modules/nixos/laptop.nix`; override
`boot.kernelPackages` in a host configuration to select another kernel.
A rebuild does not format disks. The new kernel takes effect after reboot.

Mount definitions and UUIDs stay in each host's `hardware-configuration.nix`.
Changing `fsType` only changes how NixOS mounts a partition; it does not convert
ext4 to XFS. To migrate the root filesystem, back up the data, create XFS on the
intended partition from a live system, restore the data, and update its UUID and
`fsType`. Formatting that partition destroys its existing contents. Do not set
`fsType = "xfs"` while the partition still contains ext4.

## XLibre

This configuration uses the **[XLibre](https://codeberg.org/takagemacoed/xlibre-overlay)** overlay to replace the stock NixOS X11 server with a custom-built Xorg. Driver selection and build flags are controlled in `xlibre-build-options/`:

- `driver-choice.nix` — selects which X11 drivers to include/exclude
- `my-xlibre-xserver-build-options.nix` — custom meson build flags

This is loaded via the `xlibre-overlay` npins input in `nilla.nix`.

## Emacs Notes

Linux Emacs is installed via custom `withPackages` package sets for
`pkgs.emacs-pgtk` and an Athena/Lucid override of `pkgs.emacs`, with:

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

The active Emacs theme file is `modules/home/files/emacs/gruvbox-light-theme.el`;
Kanagawa Lotus and K380 Graphite remain available in the same directory.

The Linux module provides `emacs-lucid` and `emacsclient-lucid` wrappers for
the Athena build (`withAthena = true`, GTK/PGTK disabled). See
`modules/nixos/emacs.nix` for the package overrides and daemon definitions.

## VCS (Jujutsu)

This repo uses **jj** instead of git for daily work. Git is kept colocated (`.git/` + `.jj/`) so that Nilla's `builtins.fetchGit` still works.

```bash
# Allow the wallpaper GIFs into the initial snapshot (largest is about 31 MiB)
jj status --config snapshot.max-new-file-size=41943040

# Finalize the current change and start a fresh working-copy change
jj commit -m "message"

# Move main to the finalized change, then push if desired
jj bookmark set main -r @-
jj git push --bookmark main --remote origin

# View log
jj log
```

Remote: `git@github.com:yoptabyte/nixik.git`

## License

MIT — see [LICENSE](LICENSE).
