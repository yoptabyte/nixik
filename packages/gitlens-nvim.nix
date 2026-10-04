{ vimUtils, fetchFromGitHub, vimPlugins }:

vimUtils.buildVimPlugin {
  pname = "gitlens.nvim";
  version = "unstable-a010a66";
  src = fetchFromGitHub {
    owner = "pradhyu";
    repo = "gitlens.nvim";
    rev = "a010a6630aef338e76c5fe05f80e475b8534defa";
    sha256 = "08l2z2ddarcd1b7yfj1jlc05p9cc4cnsi3nwa0zy7l4mlmd33h25";
  };
  dependencies = [ vimPlugins.plenary-nvim ];
  # Upstream puts the module at the repository root; require("gitlens")
  # needs it under lua/ on Neovim's runtime path.
  preInstall = ''
    mkdir -p lua/gitlens
    mv init.lua lua/gitlens/init.lua
  '';
}
