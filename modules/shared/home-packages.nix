{ pkgs }:

with pkgs; [
  # Git tools
  lazygit
  lazydocker
  jujutsu

  # Useful CLI tools
  ripgrep
  fd
  fzf
  bat
  eza
  btop
  yazi
  zoxide
  fastfetch
  onefetch

  # Archive tools
  zip
  unzip
  p7zip
  ripunzip
  unar
  zstd

  # Media players
  vlc
  audacity

  # Terminal (Linux-only in nixpkgs)
  (if stdenv.hostPlatform.isLinux then ghostty else null)

  # AI coding agent
  opencode
  t3code

  # Binary cache push
  cachix

  # Shell & prompt
  nushell
  starship
  tmux
  delta
]
