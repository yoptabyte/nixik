{ pkgs }:

with pkgs; [
  # Git tools
  gh
  lazygit
  jujutsu
  forgejo-cli

  #TUI
  lazydocker

  # Useful CLI tools
  fd
  fzf
  bat
  eza
  btop
  yazi
  fetch
  zoxide
  ripgrep
  onefetch

  # Archive tools
  zip
  unar
  zstd
  unzip
  p7zip
  ripunzip

  # Binary cache push
  cachix

  # Shell & prompt
  tmux
  delta
  nushell
  starship
] ++ lib.optionals stdenv.hostPlatform.isLinux [
  # Darwin installs these applications through Homebrew.
  vlc
  ghostty
]
