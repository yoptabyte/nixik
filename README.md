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
- **GPU**: Intel HD Graphics 530 + NVIDIA GeForce GTX 1050 Mobile
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
- **Voxtype** dictation: Super+Ctrl+X to toggle, F9 to hold and speak; the multilingual Whisper `large-v3-turbo` model downloads when its Hyprland service first starts and runs with Vulkan GPU acceleration
- Voxtype uses Flash Attention; NVIDIA PRIME hosts select the NVIDIA Vulkan driver explicitly so recognition does not run on the integrated Intel GPU
- Voxtype inserts text through the clipboard with Shift+Insert and restores the previous clipboard; this avoids garbled Cyrillic from simulated character typing
- Waybar shows an 18px microphone for Voxtype readiness, a pulsing red **● Recording** while recording, and a yellow **Transcribing…** indicator while transcribing; both dictation shortcuts use the same indicator

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

### Meeting recording

Linux includes [Tapeback](https://github.com/yastcher/tapeback) 0.10.1, packaged
locally with transcription, a tray icon and LLM provider dependencies. Launch
**Tapeback** from the application menu or run `tapeback tray`; recording starts
only when requested. From a terminal, use `tapeback start` and Ctrl+C to stop.
Notes go to `~/ZVOnki/meetings/` and audio recordings to
`~/ZVOnki/attachments/audio/`. The multilingual Whisper model downloads on the
first transcription.

The session defaults to Russian (`TAPEBACK_LANGUAGE=ru`) and CPU inference
(`TAPEBACK_DEVICE=cpu`), including on machines with NVIDIA. Log in again after
rebuilding to load these defaults. Override the language for one recording with
`TAPEBACK_LANGUAGE=auto tapeback start` or `TAPEBACK_LANGUAGE=en tapeback start`.

`tapeback setup --no-diarize --no-summarize` disables the optional stages.
Speaker diarization dependencies (pyannote/PyTorch) are not bundled. To enable
summaries, configure a provider and its key in `~/.config/tapeback/.env`, then
run `tapeback setup --summarize`. Summaries use the meeting's language; cloud
providers receive the transcript. Keep credentials in that local file. Change
`TAPEBACK_VAULT_PATH` in `modules/nixos/productivity.nix` to use another directory
or an Obsidian vault. Session environment variables take precedence over the file.

### Herdr Telegram replies

`packages/herdr-telegram-agents.nix` pins Telegram Agents 0.17.4 to an exact
commit and dependency hashes. `packages/herdr-telegram-full-replies.patch`
preserves complete replies, including multi-part Claude messages. The package
includes SQLite and installs agent hooks with Python supplied by `nix shell`.
Agents that have not been initialized are skipped; rerun the integration helper
after installing and starting Claude Code for the first time.

In an active agent's Telegram topic, `/git diff remote` includes local commits,
staged/unstaged edits and new non-ignored files since the merge base with its
upstream (or `origin/HEAD` for detached HEAD/Jujutsu). It uses the tracking
reference from the last `git fetch` and leaves
the real index unchanged. Long output arrives as a `.patch` file. Plain
`/git diff` still shows tracked, uncommitted changes against `HEAD`.

Append `md` to any diff command to always receive a Markdown file:
`/git diff remote md` (all local changes since the remote merge base),
`/git diff md` (tracked uncommitted edits), or `/git diff staged md`.
Short and empty diffs also arrive as `.md` documents with a fenced diff block.

`/git files` lists local tracked and non-ignored new files; `/git files src`
narrows the list to a directory. `/git file src/example.py` sends the current
local file as `example.py.md`, including uncommitted edits, without a push.
Paths are relative to the repository root; type spaces without quotes.
Symlinks, binary files, Git metadata and paths outside the repository are
excluded. Files and diffs have a 5 MB cap; partial views are explicitly marked.

To answer a queued Codex question, send `/keys shift+left`, then `/screen`.
Choose with `/keys up` or `/keys down` and confirm with `/keys enter`.

The Linux desktop enables `modules/nixos/herdr-telegram.nix`. Its user service
registers the package as a **local** Herdr plugin, so `herdr plugin update`
cannot replace it. To build and register it without rebuilding the system:

```bash
nix-build packages/herdr-telegram-bundle.nix -A telegram -o result-herdr-telegram
./result-herdr-telegram/bin/herdr-agent-integrations --herdr "$(command -v herdr)"
herdr plugin link "$(readlink -f result-herdr-telegram)/share/herdr/plugins/permgps.telegram-agents"
herdr plugin action invoke permgps.telegram-agents.restart
```

Update the source revision and hashes in the package recipe deliberately;
Nix reapplies the patch and runs reply-delivery tests before installation.
Keep Telegram bot tokens and group settings in each machine's existing private
Herdr plugin configuration. Separate machines need separate Telegram bots.

`packages/herdr-telegram-bundle.nix` also exposes the matching `herdr` package
for another NixOS host. Import `modules/nixos/herdr-telegram.nix`, enable
`programs.herdr-telegram`, set `users`, and enable `server.enable` for a
persistent headless server. The source bundle on `forgejo-laptop` lives under
`~/nixos/herdr-telegram`; its Telegram bot is configured separately.

Connect to that server's Herdr with
`ssh -t forgejo-laptop '~/.nix-profile/bin/herdr'`, then run
`herdr plugin action invoke permgps.telegram-agents.setup` inside a Herdr pane.
Enter the server bot's token in the setup popup and select its forum group.
The bootstrap user services keep running after SSH disconnects; the NixOS
module takes over their marked unit links on the next system switch.

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

### Unavailable CachyOS binary cache

The lantian cache was shut down after a server compromise; see the
[upstream notice](https://github.com/xddxdd/nix-cachyos-kernel/issues/110).
This configuration no longer adds that cache or trusts its signing key.
Until you rebuild and activate the updated configuration, `/etc/nix/nix.conf`
still includes the old cache. Override the complete substituter list to enter
the development shell:

```bash
nix-shell --option substituters 'https://cache.nixos.org/ https://nix-community.cachix.org https://yoptanix.cachix.org'
```

Use the same override when rebuilding (replace `xps15` with your host):

```bash
sudo nixos-rebuild switch \
  --file nilla.nix --attr 'systems.nixos."xps15".result' \
  --option substituters 'https://cache.nixos.org/ https://nix-community.cachix.org https://yoptanix.cachix.org'
```

### Fonts

[Comic True Mono](https://github.com/CptIdea/ComicTrueMono) with Nerd Font icons
is the default font for terminals, editors, bars, notifications and launchers.
`packages/comic-true-mono-nerd-font.nix` patches the pinned upstream Regular,
Italic, Bold and Bold Italic files with the official Nerd Fonts Patcher.
The checked-in upstream Bold Italic file lacks Cyrillic, so it is regenerated
from the complete Bold face using upstream's 12.7-degree slant and centering.
The installed family is **ComicTrueMono Nerd Font Mono** and includes the
complete Russian alphabet, including Ё/ё, in the same family as Latin.
Linux also uses it for generic monospace, sans-serif and serif families and
GTK interfaces. JetBrains Mono remains a fallback for unsupported characters.
Rebuild and restart applications to apply changes.

The `app-fonts` user service also updates GTK/GSettings and XFCE font overrides,
registered Obsidian vaults, Vesktop QuickCSS and Zen's profile defaults and UI
CSS. It changes font settings only, preserves other settings and creates
`.before-comic-font` backups before its first edit. Run `app-fonts` to apply it
again; restart Zen to load its profile changes. Websites that explicitly choose
their own fonts keep those fonts.

Nixvim includes [gitlens.nvim](https://github.com/pradhyu/gitlens.nvim):
`<leader>gb` shows line blame and `<leader>gD` opens the corresponding commit diff.

GOverlay uses the local `packages/goverlay.nix` override to fix Lazarus's
wrapper: removing rpath arguments must also collapse and trim spaces in
`NIX_LDFLAGS`. Otherwise `makeBinaryWrapper` rejects empty segments and the
Lazarus dependency fails during installation.

Build phases (`fixupPhase`, `patchPhase`, etc.) and compiler warnings are normal
build output. A failed derivation is reported with `error: Cannot build`.

Godot 4.7 needs `harfbuzz-vector` in addition to HarfBuzz's raster and ICU
libraries. The local `packages/godot.nix` override enables vector support only
for Godot's dependency, fixing `No package 'harfbuzz-vector' found` with the
pinned nixpkgs recipe.

The ChatGPT desktop package adds `tpm2-tss` to its build inputs so
`autoPatchelfHook` can resolve the `libtss2-*` dependencies of the bundled
`remote-control-device-key.node` module.

Audacity 4.0 uses the local `packages/audacity.nix` override to disable unity
compilation for `muse_extensions_qml`. With Qt 6.12, combining its generated
QML and moc sources makes `Type` ambiguous. Compiling them separately keeps
QML caching enabled and avoids the name collision.

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

The shared kernel default is in `modules/nixos/laptop.nix`. Hosts importing
`modules/nixos/gaming.nix` use CachyOS BORE instead; currently this is `xps15`.
The kernel is pinned through npins to the `release` branch of
[nix-cachyos-kernel](https://github.com/xddxdd/nix-cachyos-kernel/tree/release),
using its original nixpkgs for the kernel and the system's nixpkgs for
external modules such as NVIDIA. The generic x86-64 build avoids requiring AVX
or LTO support from external modules. Update it with
`npins update nix-cachyos-kernel`.

The local module aggregation override supports the pinned kernel's older
packaging, which has no `modules.cer`. It skips certificate aggregation only
for the matching kernel version when its built configuration explicitly has
`CONFIG_MODULE_SIG` disabled. Module dependency generation still runs; kernels
with signing enabled retain nixpkgs' certificate checks.

The upstream binary cache is disabled following its server compromise. CachyOS
remains selected, so missing kernel outputs may require a lengthy local build.
The cache override under Build troubleshooting bypasses the old daemon settings
until the updated configuration is activated.

A rebuild does not format disks. The new kernel takes effect after reboot.

### Gaming on Wayland

The gaming module enables Steam, Proton-GE, Protontricks, Gamescope, GameMode,
and 64/32-bit OpenGL and Vulkan drivers. Lutris, Heroic, Wine, Winetricks,
MangoHud, GOverlay, `vulkaninfo`, `vkcube`, `glxinfo`, and `vainfo` are installed.
Steam's module also installs controller udev rules. Hyprland's XWayland support
allows X11 games to run inside the Wayland session.

In Steam, enable Steam Play for the desired games; select GE-Proton in a game's
Compatibility settings if needed. Set its launch options to:

```text
game-run %command%
```

`game-run` requests GameMode, enables MangoHud, and selects NVIDIA on hosts with
PRIME offload enabled. It also works outside Steam: `game-run lutris` or
`game-run wine /path/to/game.exe`. GameMode uses the Intel `powersave` governor
for dynamic frequency selection, raises process priority, and inhibits the
screensaver while games are running. This governor still allows turbo; it is
not the same setting as the desktop's power-saver profile.
The module also increases `vm.max_map_count` to 1048576 for games with many mappings.

The XPS host enables Intel thermald. To reduce game load, start with a 60 FPS
limit (or 30 if needed), preferably in the game's own settings. For MangoHud:

```bash
MANGOHUD_CONFIG=fps_limit=60,cpu_temp,gpu_temp game-run ./start-game.sh
```

Steam launch options:

```text
MANGOHUD_CONFIG=fps_limit=60,cpu_temp,gpu_temp game-run %command%
```

In Lutris, keep `game-run` as the command prefix and add the environment
variable `MANGOHUD_CONFIG` with value `fps_limit=60,cpu_temp,gpu_temp` under
System options. Use `sensors` and `nvidia-smi` to inspect temperatures. These
settings reduce load but cannot guarantee prevention of thermal shutdowns;
repeated shutdowns also require checking cooling and power delivery.

On the XPS 9500, the firmware exposes a `cool` thermal profile in addition to
`quiet`, `balanced`, and `performance`. Dell's `cool` profile increases fan
speed, but can also reduce performance; it is not a separate fan-only control.
To try it temporarily:

```bash
echo cool | sudo tee /sys/firmware/acpi/platform_profile
```

Changing the desktop power profile can overwrite this choice. To further reduce
CPU heat for all applications, temporarily disable Intel turbo (at a cost in
CPU performance):

```bash
echo 1 | sudo tee /sys/devices/system/cpu/intel_pstate/no_turbo
```

Write `0` to the same file to restore turbo. The default is normally restored
after reboot; firmware or power-management software can also change it.

For optional Gamescope scaling, use this Steam launch option (adjust resolution
and frame limit to the game/display):

```text
game-run gamescope -w 1280 -h 720 -W 1920 -H 1080 -r 60 -f -- %command%
```

Reboot to use the kernel. Previous generations remain selectable in systemd-boot.
After booting, inspect the graphics stack with `vulkaninfo --summary` and
`glxinfo -B`; repeat with `nvidia-offload` to check the discrete GPU, and use
`uname -r` to see the running kernel. Config comments name older NVIDIA cards;
check `lspci -nn` on the target machine when changing driver branches.

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
