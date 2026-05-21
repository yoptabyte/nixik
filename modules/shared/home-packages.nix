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
  p7zip
  ripunzip
  unar

  # Terminal (Linux-only in nixpkgs)
  (if stdenv.hostPlatform.isLinux then ghostty else null)

  # AI coding agent
  opencode

  # Shell & prompt
  nushell
  starship
  tmux
  delta
]
