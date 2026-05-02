{ config, lib, pkgs, ... }:

let
  # Emacs with packages pre-installed via Nix.
  #
  # Note on emacs-lucid:
  # `emacs-lucid` is not available as a top-level nixpkgs attribute.
  # If you prefer the Lucid (Athena) toolkit instead of GTK,
  # replace `pkgs.emacs` below with an override such as:
  #
  #   (pkgs.emacs.override {
  #     withGTK3 = false;
  #     withX    = true;
  #     withLucid = true;   # may vary by nixpkgs version
  #   })
  #
  # On some channels the override is:
  #   (pkgs.emacs.override { withXwidgets = false; withGTK3 = false; withLucid = true; })
  #
  # Referenced configs:
  #   - https://codeberg.org/haditim/dotemacs  (lightweight Doom replacement)
  #   - https://github.com/emacs-twist/twist.nix (flake-based pkg manager — not used here)
  #
  # Since this repo uses a non-flake npins + nilla setup, we keep things simple:
  # standard nixpkgs Emacs + a vanilla init.el managed through hjem.

  myEmacs = (pkgs.emacs.pkgs.withPackages (epkgs: with epkgs; [
    vertico
    orderless
    marginalia
    consult
    which-key
    evil
    evil-collection
    magit
    doom-modeline
    nerd-icons
    nix-mode
    treesit-grammars.with-all-grammars
  ]));
in
{
  environment.systemPackages = [ myEmacs ];

  # Emacs daemon — matches the existing nushell aliases `em` and `em-kill`
  systemd.user.services.emacs = {
    description = "Emacs text editor daemon";
    after = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    wantedBy = [ "graphical-session.target" ];

    serviceConfig = {
      Type = "simple";
      ExecStart = "${lib.getExe myEmacs} --fg-daemon";
      ExecStop = "${lib.getExe myEmacs}client -e '(kill-emacs)'";
      Restart = "on-failure";
    };
  };

  hjem.users.yoptabyte = {
    files = {
      # ── Theme ───────────────────────────────────────
      ".emacs.d/themes/k380-graphite-theme.el".source = ../../modules/home/files/k380-graphite-theme.el;

      # ── Init ────────────────────────────────────────
      ".emacs.d/init.el".text = ''
        ;;; init.el --- Emacs configuration  -*- lexical-binding: t; -*-

        ;; ━━ Theme ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        (add-to-list 'custom-theme-load-path "~/.emacs.d/themes")
        (load-theme 'k380-graphite t)

        ;; ━━ UI ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        (menu-bar-mode -1)
        (tool-bar-mode -1)
        (scroll-bar-mode -1)
        (set-fringe-mode 10)
        (setq inhibit-startup-message t
              initial-scratch-message nil
              visible-bell t
              ring-bell-function 'ignore)

        ;; Font — matches Ghostty / nixvim setup
        (set-face-attribute 'default nil :font "JetBrainsMono Nerd Font" :height 140)

        ;; Line numbers (relative, like nixvim)
        (global-display-line-numbers-mode t)
        (setq display-line-numbers-type 'relative)

        ;; Cursor
        (setq-default cursor-type 'bar)

        ;; Transparent background for Ghostty
        (set-frame-parameter (selected-frame) 'alpha-background 100)
        (add-to-list 'default-frame-alist '(alpha-background . 100))

        ;; ━━ Backup / Autosave ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        (setq make-backup-files nil
              auto-save-default nil)

        ;; ━━ Package Management ━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        ;; Packages are provided by Nix via emacs.pkgs.withPackages.
        (require 'use-package)
        (setq use-package-always-ensure nil)

        ;; ━━ Completion Framework ━━━━━━━━━━━━━━━━━━━━━━━━━━
        (use-package vertico
          :init
          (vertico-mode))

        (use-package orderless
          :custom
          (completion-styles '(orderless basic))
          (completion-category-defaults nil)
          (completion-category-overrides '((file (styles partial-completion)))))

        (use-package marginalia
          :bind (:map minibuffer-local-map
                      ("M-A" . marginalia-cycle))
          :init
          (marginalia-mode))

        (use-package consult
          :bind (("C-s" . consult-line)
                 ("C-x b" . consult-buffer)
                 ("M-g g" . consult-goto-line)
                 ("M-g M-g" . consult-goto-line)))

        ;; ━━ Key Discovery ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        (use-package which-key
          :init
          (which-key-mode)
          :config
          (setq which-key-idle-delay 0.3))

        ;; ━━ Evil Mode ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        (use-package evil
          :init
          (setq evil-want-integration t
                evil-want-keybinding nil)
          :config
          (evil-mode 1))

        (use-package evil-collection
          :after evil
          :config
          (evil-collection-init))

        ;; ━━ Magit ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        (use-package magit
          :bind ("C-x g" . magit-status))

        ;; ━━ Modeline ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        (use-package doom-modeline
          :init
          (doom-modeline-mode 1)
          :config
          (setq doom-modeline-height 25))

        ;; ━━ Icons ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        (use-package nerd-icons)

        ;; ━━ Nix ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        (use-package nix-mode
          :mode "\\.nix\\'")

        ;; ━━ Eglot (LSP) ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        (use-package eglot
          :hook ((python-mode python-ts-mode rust-ts-mode nix-mode) . eglot-ensure))

        ;; ━━ Treesitter ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        (setq major-mode-remap-alist
              '((python-mode . python-ts-mode)
                (rust-mode . rust-ts-mode)
                (js-mode . js-ts-mode)
                (typescript-mode . typescript-ts-mode)
                (json-mode . json-ts-mode)))

        ;; ━━ Server ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        (server-start)

        (provide 'init)
        ;;; init.el ends here
      '';
    };
  };
}
