{ config, lib, pkgs, ... }:
{
  # Terminal environment variable
  environment.sessionVariables = {
    TERMINAL = "ghostty";
  };

  # Ghostty is installed via hjem user packages
}
