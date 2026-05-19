{ pkgs }:

with pkgs; [
  # Git tools
  lazygit
  lazydocker

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
  p7zip
  ripunzip
  unar

  # Terminal
  ghostty

  # Shell & prompt
  nushell
  starship
  tmux
  delta
]
