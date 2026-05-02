{ config, lib, pkgs, ... }:
{
  # LLM agent packages from nixpkgs
  environment.systemPackages = [
    pkgs.claude-code   # Anthropic Claude Code CLI
    pkgs.codex         # OpenAI Codex CLI
    pkgs.opencode      # OpenCode agent
    pkgs.ollama
  ];

  # Ollama system service (local LLMs)
  services.ollama = {
    enable = true;
    # acceleration = "cuda"; # uncomment if you have an NVIDIA GPU
    # acceleration = "rocm"; # uncomment if you have an AMD GPU
  };
}
