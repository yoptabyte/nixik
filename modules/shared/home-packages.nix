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
  fetch
  onefetch

  # Archive tools
  zip
  unzip
  p7zip
  ripunzip
  unar
  zstd

  # Media players
  audacity

  # Binary cache push
  cachix

  # Shell & prompt
  nushell
  starship
  tmux
  delta
] ++ lib.optionals stdenv.hostPlatform.isLinux [
  # Darwin installs these applications through Homebrew.
  vlc
  ghostty
]
