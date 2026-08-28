{ config, lib, pkgs, ... }:

let
  cfg = config.modules.nixos.emacs;
  emacsLucid = pkgs.emacs.override {
    withGTK3 = false;
    withPgtk = false;
    withAthena = true;
    withXwidgets = false;
  };
  zen-mode = epkgs: epkgs.trivialBuild {
    pname = "zen-mode";
    version = "20220105";
    src = pkgs.fetchFromGitHub {
      owner = "aki237";
      repo = "zen-mode";
      rev = "b5a1ed8e12bb0b2f5dccb8b89b04613f6fdedad0";
      sha256 = "sha256-16Pp/PPw67l6a0PMaYGRvQRe2DJbtiO6TFeFtHiAax8=";
    };
  };
  typst-mode = epkgs: epkgs.trivialBuild {
    pname = "typst-mode";
    version = "20230925";
    src = pkgs.fetchFromGitHub {
      owner = "Ziqi-Yang";
      repo = "typst-mode.el";
      rev = "5776fd4f3608350ff6a2b61b118d38165d342aa3";
      sha256 = "sha256-mqkcNDgx7lc6kUSFFwSATRT+UcOglkeu+orKLiU9Ldg=";
    };
    packageRequires = [ epkgs.polymode ];
  };
  teleganew = epkgs: epkgs.telega.overrideAttrs (_: {
    version = "20250602";
    src = pkgs.fetchFromGitHub {
      owner = "zevlg";
      repo = "telega.el";
      rev = "f70c1e1006fc47012780a2d885b22b0b93512c47";
      sha256 = "0n4b3gkmligrqyrzdpc2nczybbjphr4y3nm88ai9zpk9rz1aw5fv";
    };
  });
  nerd-icons-src = pkgs.fetchgit {
    url = "https://github.com/rainstormstudio/nerd-icons.el.git";
    rev = "674909974637ff0ec2b5ebf43f9a8aefa35d93e9";
    sha256 = "sha256-/UrUNZQcoJEprN5MDAnB4TtQjPZY1/3QwTWJfaQFLZM=";
  };
  # Override nerd-icons in both emacs package sets so deps (nerd-icons-completion, etc.) also use fixed src
  myEmacsPkgs = pkgs.emacs-pgtk.pkgs.overrideScope (final: prev: {
    nerd-icons = prev.nerd-icons.overrideAttrs (_: { src = nerd-icons-src; });
  });
  myEmacsLucidPkgs = emacsLucid.pkgs.overrideScope (final: prev: {
    nerd-icons = prev.nerd-icons.overrideAttrs (_: { src = nerd-icons-src; });
  });
  myEmacs = (myEmacsPkgs.withPackages (epkgs:
    basePackages epkgs ++ cfg.extraPackages epkgs));
  myEmacsLucid = (myEmacsLucidPkgs.withPackages (epkgs:
    basePackages epkgs ++ cfg.extraPackages epkgs));
  basePackages = epkgs: with epkgs; [
    vertico orderless marginalia consult which-key corfu doom-modeline
    evil evil-collection general
    drag-stuff
    treemacs treemacs-evil treemacs-magit
    magit diff-hl
    nerd-icons nerd-icons-completion
    vterm multi-vterm
    nix-mode markdown-mode scala-mode go-mode php-mode haskell-mode
    treesit-grammars.with-all-grammars
    pdf-tools
    ob-rust ob-go
    (teleganew epkgs)
    org-download
    # Dired enhancements
    nerd-icons-dired async dired-preview dired-open dired-narrow
    # direnv per-buffer integration (LSP servers from flakes)
    envrc
    # Clojure
    clojure-mode clojure-ts-mode cider
    paredit evil-paredit rainbow-delimiters
    # Scala (tree-sitter)
    scala-ts-mode
    # Vue SFC
    web-mode polymode
    # Typst
    (typst-mode epkgs)
    (zen-mode epkgs)
    # Java
    yasnippet yasnippet-snippets
    # Debug Adapter Protocol
    dape
    perspective
  ];
  # Wrapper to provide emacs-lucid and emacsclient-lucid without name collision
  myEmacsLucidWrapped = pkgs.runCommand "emacs-lucid-wrapped" {} ''
    mkdir -p $out/bin
    ln -s ${myEmacsLucid}/bin/emacs $out/bin/emacs-lucid
    ln -s ${myEmacsLucid}/bin/emacsclient $out/bin/emacsclient-lucid
    ln -s ${myEmacsLucid}/bin/emacs $out/bin/emacs30-lucid
  '';
in
{
  options.modules.nixos.emacs = {
    extraPackages = lib.mkOption {
      type = lib.types.functionTo (lib.types.listOf lib.types.package);
      default = epkgs: [];
      description = "Extra Emacs packages to include via withPackages";
    };
  };

  config = {
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    environment.systemPackages = [
      myEmacs myEmacsLucidWrapped pkgs.rust-analyzer pkgs.imagemagick pkgs.file
      # Java/Spring (jdtls, JDK, Maven) — НЕ системно: через flake devShell + envrc per-project
    ];

    systemd.user.services.emacs = {
      description = "Emacs daemon (pgtk/Wayland)";
      after = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      wantedBy = [ "graphical-session.target" ];
      unitConfig.ConditionEnvironment = "WAYLAND_DISPLAY";
      serviceConfig = {
        Type = "simple";
        ExecStart = "${lib.getExe myEmacs} --fg-daemon=pgtk";
        ExecStop = "${lib.getExe myEmacs}client -s pgtk -e '(kill-emacs)'";
        Restart = "on-failure";
      };
    };

    systemd.user.services.emacs-x11 = {
      description = "Emacs daemon (lucid/X11)";
      after = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      wantedBy = [ "graphical-session.target" ];
      unitConfig.ConditionEnvironment = "!WAYLAND_DISPLAY";
      serviceConfig = {
        Type = "simple";
        ExecStart = "${myEmacsLucid}/bin/emacs --fg-daemon=x11";
        ExecStop = "${myEmacsLucid}/bin/emacsclient -s x11 -e '(kill-emacs)'";
        Restart = "on-failure";
      };
    };

    hjem.users.yoptabyte = {
      files = {
        ".emacs.d/themes/k380-graphite-theme.el".source = ../../modules/home/files/emacs/k380-graphite-theme.el;
        ".emacs.d/themes/kanagawa-lotus-theme.el".source = ../../modules/home/files/emacs/kanagawa-lotus-theme.el;
        ".emacs.d/themes/gruvbox-light-theme.el".source = ../../modules/home/files/emacs/gruvbox-light-theme.el;
        ".emacs.d/init.el".source = ../../modules/shared/emacs-init.el;
      };
    };
  };
}
