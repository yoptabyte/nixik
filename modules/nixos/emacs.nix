{ config, lib, pkgs, ... }:

let
  myEmacs = (pkgs.emacs.pkgs.withPackages (epkgs: with epkgs; [
    # Core / UI
    vertico
    orderless
    marginalia
    consult
    which-key

    # Evil
    evil
    evil-leader
    evil-collection

    # Editing
    drag-stuff

    # Sidebar / Tabs
    treemacs
    treemacs-evil
    treemacs-magit
    centaur-tabs

    # Git
    magit
    diff-hl

    # Modeline / Icons
    doom-modeline
    nerd-icons
    nerd-icons-completion

    # Terminal
    vterm

    # Language support
    nix-mode
    treesit-grammars.with-all-grammars
  ]));
in
{
  environment.systemPackages = [ myEmacs ];

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
      ".emacs.d/themes/k380-graphite-theme.el".source = ../../modules/home/files/k380-graphite-theme.el;

      ".emacs.d/init.el".text = ''
        ;;; init.el --- Doom-like Emacs configuration  -*- lexical-binding: t; -*-

        ;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        ;; Theme
        ;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        (add-to-list 'custom-theme-load-path "~/.emacs.d/themes")
        (load-theme 'k380-graphite t)

        ;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        ;; UI Basics
        ;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        (menu-bar-mode -1)
        (tool-bar-mode -1)
        (scroll-bar-mode -1)
        (set-fringe-mode 10)
        (setq inhibit-startup-message t
              initial-scratch-message nil
              visible-bell t
              ring-bell-function 'ignore)

        (set-face-attribute 'default nil :font "JetBrainsMono Nerd Font" :height 140)
        (global-display-line-numbers-mode t)
        (setq display-line-numbers-type 'relative)
        (setq-default cursor-type 'bar)

        ;; Transparent background for Ghostty
        (set-frame-parameter (selected-frame) 'alpha-background 100)
        (add-to-list 'default-frame-alist '(alpha-background . 100))

        ;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        ;; Backup / Autosave
        ;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        (setq make-backup-files nil
              auto-save-default nil)

        ;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        ;; Package bootstrap (Nix provides everything)
        ;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        (require 'use-package)
        (setq use-package-always-ensure nil)

        ;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        ;; Evil Mode + Leader
        ;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        (setq my/leader-key " ")

        (use-package evil
          :ensure nil
          :demand t
          :init
          (setq evil-want-integration t
                evil-want-keybinding nil
                evil-want-C-u-scroll t
                evil-want-C-i-jump nil
                evil-want-C-d-scroll t
                evil-want-C-w-delete t
                evil-want-C-w-kill t
                evil-respect-visual-line-mode t)
          :config
          (evil-mode 1)
          (setq evil-undo-system 'undo-redo)
          (setq evil-emacs-state-cursor '("red" box))
          (setq evil-normal-state-cursor '("#f0c040" box))
          (setq evil-insert-state-cursor '("#f0c040" bar))
          (setq evil-visual-state-cursor '("#f0c040" block))

          ;; Window navigation (C-h/j/k/l)
          (define-key evil-normal-state-map (kbd "C-h") 'evil-window-left)
          (define-key evil-normal-state-map (kbd "C-j") 'evil-window-down)
          (define-key evil-normal-state-map (kbd "C-k") 'evil-window-up)
          (define-key evil-normal-state-map (kbd "C-l") 'evil-window-right)

          ;; Window resize (C-arrow)
          (define-key evil-normal-state-map (kbd "<C-up>")    (lambda () (interactive) (evil-window-increase-height 2)))
          (define-key evil-normal-state-map (kbd "<C-down>")  (lambda () (interactive) (evil-window-decrease-height 2)))
          (define-key evil-normal-state-map (kbd "<C-left>")   (lambda () (interactive) (evil-window-decrease-width 2)))
          (define-key evil-normal-state-map (kbd "<C-right>")  (lambda () (interactive) (evil-window-increase-width 2)))

          ;; Window swap (C-S-h/j/k/l)
          (define-key evil-normal-state-map (kbd "C-S-h") 'windmove-swap-states-left)
          (define-key evil-normal-state-map (kbd "C-S-j") 'windmove-swap-states-down)
          (define-key evil-normal-state-map (kbd "C-S-k") 'windmove-swap-states-up)
          (define-key evil-normal-state-map (kbd "C-S-l") 'windmove-swap-states-right)
          (define-key evil-normal-state-map (kbd "<C-S-left>")  'windmove-swap-states-left)
          (define-key evil-normal-state-map (kbd "<C-S-down>")  'windmove-swap-states-down)
          (define-key evil-normal-state-map (kbd "<C-S-up>")    'windmove-swap-states-up)
          (define-key evil-normal-state-map (kbd "<C-S-right>") 'windmove-swap-states-right)

          ;; Zoom (C-+/C--/C-0)
          (define-key evil-normal-state-map (kbd "C-=") 'text-scale-increase)
          (define-key evil-normal-state-map (kbd "C-+") 'text-scale-increase)
          (define-key evil-normal-state-map (kbd "C--") 'text-scale-decrease)
          (define-key evil-normal-state-map (kbd "C-0") 'text-scale-reset))

        (use-package evil-leader
          :ensure nil
          :demand t
          :after evil
          :config
          (global-evil-leader-mode)
          (setq evil-leader/leader my/leader-key)
          (setq evil-leader/in-all-states t)

          ;; Quit / Save
          (evil-leader/set-key "q" 'quit-window)
          (evil-leader/set-key "Q" 'save-buffers-kill-terminal)
          (evil-leader/set-key "w" 'save-buffer)

          ;; Window navigation (SPC w prefix)
          (evil-leader/set-key "wh" 'evil-window-left)
          (evil-leader/set-key "wj" 'evil-window-down)
          (evil-leader/set-key "wk" 'evil-window-up)
          (evil-leader/set-key "wl" 'evil-window-right)
          (evil-leader/set-key "ww" 'other-window)

          ;; Resize windows
          (evil-leader/set-key "wH" (lambda () (interactive) (evil-window-decrease-width 2)))
          (evil-leader/set-key "wJ" (lambda () (interactive) (evil-window-increase-height 2)))
          (evil-leader/set-key "wK" (lambda () (interactive) (evil-window-decrease-height 2)))
          (evil-leader/set-key "wL" (lambda () (interactive) (evil-window-increase-width 2)))

          ;; Splits
          (evil-leader/set-key "|" 'evil-window-vsplit)
          (evil-leader/set-key "-" 'evil-window-split)

          ;; Buffers
          (evil-leader/set-key "n" 'next-buffer)
          (evil-leader/set-key "p" 'previous-buffer)
          (evil-leader/set-key "d" 'kill-buffer)
          (evil-leader/set-key "bn" 'next-buffer)
          (evil-leader/set-key "bp" 'previous-buffer)
          (evil-leader/set-key "bd" 'kill-buffer)
          (evil-leader/set-key "bb" 'consult-buffer)

          ;; Find (consult) — Doom-style SPC f prefix
          (evil-leader/set-key "ff" 'consult-find)
          (evil-leader/set-key "fw" 'consult-ripgrep)
          (evil-leader/set-key "fb" 'consult-buffer)
          (evil-leader/set-key "fh" 'consult-info)
          (evil-leader/set-key "fo" 'consult-recent-file)
          (evil-leader/set-key "fk" 'consult-yank-pop)
          (evil-leader/set-key "fm" 'consult-mark)
          (evil-leader/set-key "fr" 'consult-register)
          (evil-leader/set-key "ft" 'consult-theme)
          (evil-leader/set-key "fd" 'treemacs)

          ;; Open — Doom-style SPC o prefix
          (evil-leader/set-key "o" 'treemacs)

          ;; Git (magit)
          (evil-leader/set-key "gg" 'magit-status)
          (evil-leader/set-key "gs" 'magit-status)
          (evil-leader/set-key "gb" 'magit-blame-addition)
          (evil-leader/set-key "gc" 'magit-commit-create)
          (evil-leader/set-key "gl" 'magit-log-buffer-file)
          (evil-leader/set-key "gd" 'magit-diff-working-tree)
          (evil-leader/set-key "gj" 'magit-section-forward-sibling)
          (evil-leader/set-key "gk" 'magit-section-backward-sibling)

          ;; LSP (Eglot)
          (evil-leader/set-key "la" 'eglot-code-actions)
          (evil-leader/set-key "ld" 'xref-find-definitions)
          (evil-leader/set-key "lD" 'eglot-find-declaration)
          (evil-leader/set-key "lf" 'eglot-format)
          (evil-leader/set-key "lh" 'eldoc-doc-buffer)
          (evil-leader/set-key "li" 'eglot-find-implementation)
          (evil-leader/set-key "lr" 'xref-find-references)
          (evil-leader/set-key "lR" 'eglot-rename)
          (evil-leader/set-key "ls" 'eldoc)
          (evil-leader/set-key "lt" 'eglot-find-typeDefinition)

          ;; Comment
          (evil-leader/set-key "/" 'comment-line))

        (use-package evil-collection
          :ensure nil
          :demand t
          :after evil
          :config
          (setq evil-collection-mode-list
                '(dashboard dired ibuffer magit term vterm))
          (evil-collection-init))

        ;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        ;; Drag stuff
        ;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        (use-package drag-stuff
          :ensure nil
          :demand t
          :bind
          (:map evil-visual-state-map
                ("J" . drag-stuff-down)
                ("K" . drag-stuff-up)))

        ;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        ;; Completion (Vertico + Orderless + Marginalia)
        ;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        (use-package vertico
          :ensure nil
          :demand t
          :init
          (vertico-mode 1)
          :config
          (setq vertico-cycle t))

        (use-package orderless
          :ensure nil
          :demand t
          :config
          (setq completion-styles '(orderless basic))
          (setq completion-category-defaults nil)
          (setq completion-category-overrides
                '((file (styles partial-completion)))))

        (use-package marginalia
          :ensure nil
          :demand t
          :init
          (marginalia-mode 1))

        ;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        ;; Nerd Icons
        ;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        (use-package nerd-icons
          :ensure nil
          :demand t)

        (use-package nerd-icons-completion
          :ensure nil
          :demand t
          :after marginalia
          :config
          (nerd-icons-completion-mode 1))

        ;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        ;; Consult
        ;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        (use-package consult
          :ensure nil
          :demand t
          :bind
          (([remap switch-to-buffer] . consult-buffer)
           ([remap switch-to-buffer-other-window] . consult-buffer-other-window)
           ([remap yank-pop] . consult-yank-pop))
          :config
          (setq consult-narrow-key "<"
                consult-line-numbers-widen t))

        ;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        ;; Which-key
        ;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        (use-package which-key
          :ensure nil
          :demand t
          :config
          (which-key-mode 1)
          (setq which-key-idle-delay 0.3
                which-key-sort-order 'which-key-key-order-alpha))

        ;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        ;; Treemacs
        ;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        (use-package treemacs
          :ensure nil
          :demand t
          :config
          (setq treemacs-width 35
                treemacs-indentation 2
                treemacs-position 'left
                treemacs-follow-after-init t
                treemacs-no-png-images nil
                treemacs-is-never-other-window nil
                treemacs-silent-refresh t
                treemacs-silent-filewatch t)
          (treemacs-follow-mode t)
          (treemacs-filewatch-mode t)
          (treemacs-fringe-indicator-mode t)

          (defun my/treemacs-enlarge-width ()
            "Increase treemacs window width by 2."
            (interactive)
            (setq treemacs-width (+ treemacs-width 2))
            (treemacs-set-width treemacs-width))
          (defun my/treemacs-shrink-width ()
            "Decrease treemacs window width by 2."
            (interactive)
            (when (> treemacs-width 15)
              (setq treemacs-width (- treemacs-width 2))
              (treemacs-set-width treemacs-width)))
          (defun my/treemacs-enlarge-height ()
            "Increase treemacs window height by 2."
            (interactive)
            (let ((next-win (next-window)))
              (when (window-live-p next-win)
                (select-window next-win)
                (shrink-window 2)
                (select-window (get-buffer-window (get-buffer "*Treemacs*"))))))
          (defun my/treemacs-shrink-height ()
            "Decrease treemacs window height by 2."
            (interactive)
            (let ((next-win (next-window)))
              (when (window-live-p next-win)
                (select-window next-win)
                (enlarge-window 2)
                (select-window (get-buffer-window (get-buffer "*Treemacs*"))))))

          :bind
          (:map treemacs-mode-map
                ("C-h" . evil-window-left)
                ("C-l" . evil-window-right)
                ("C-j" . evil-window-down)
                ("C-k" . evil-window-up)
                ("<C-left>"  . my/treemacs-shrink-width)
                ("<C-right>" . my/treemacs-enlarge-width)
                ("<C-up>"    . my/treemacs-shrink-height)
                ("<C-down>"  . my/treemacs-enlarge-height)
                ("C-=" . text-scale-increase)
                ("C--" . text-scale-decrease)))

        (use-package treemacs-evil
          :ensure nil
          :demand t
          :after (treemacs evil)
          :config
          (evil-define-key 'normal treemacs-mode-map
            (kbd "C-=") #'text-scale-increase
            (kbd "C--") #'text-scale-decrease))

        (use-package treemacs-magit
          :ensure nil
          :demand t
          :after (treemacs magit)
          :config
          (setq treemacs-show-changed-files-as-modified t)
          (treemacs-git-mode 'extended))

        ;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        ;; Diff-hl
        ;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        (use-package diff-hl
          :ensure nil
          :demand t
          :config
          (setq diff-hl-draw-borders nil
                diff-hl-use-fringe t)
          (global-diff-hl-mode 1)
          (diff-hl-margin-mode 1)
          (custom-set-faces
           '(diff-hl-insert ((t (:background "#3D5A3D" :foreground "#A8D8A0"))))
           '(diff-hl-change ((t (:background "#5A5A2E" :foreground "#F0C040"))))
           '(diff-hl-delete ((t (:background "#5A2E2E" :foreground "#E8A020"))))))

        ;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        ;; Centaur Tabs
        ;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        (use-package centaur-tabs
          :ensure nil
          :demand t
          :config
          (setq centaur-tabs-style "box"
                centaur-tabs-set-icons t
                centaur-tabs-gray-out-icons 'buffer
                centaur-tabs-set-bar 'under
                centaur-tabs-set-modified-marker t
                centaur-tabs-modified-marker "●"
                centaur-tabs-height 32
                centaur-tabs-show-navigation-buttons nil
                centaur-tabs-cycle-scope 'tabs)
          (centaur-tabs-mode 1)
          :bind
          ("C-<prior>" . centaur-tabs-backward)
          ("C-<next>"  . centaur-tabs-forward))

        ;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        ;; Magit
        ;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        (use-package magit
          :ensure nil
          :demand t
          :bind ("C-x g" . magit-status))

        ;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        ;; Modeline
        ;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        (use-package doom-modeline
          :ensure nil
          :demand t
          :init
          (doom-modeline-mode 1)
          :config
          (setq doom-modeline-height 25))

        ;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        ;; Nix
        ;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        (use-package nix-mode
          :ensure nil
          :mode "\\.nix\\'")

        ;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        ;; Eglot (LSP)
        ;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        (use-package eglot
          :ensure nil
          :demand t
          :hook ((python-mode python-ts-mode rust-ts-mode nix-mode) . eglot-ensure))

        ;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        ;; Treesitter
        ;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        (setq major-mode-remap-alist
              '((python-mode . python-ts-mode)
                (rust-mode . rust-ts-mode)
                (js-mode . js-ts-mode)
                (typescript-mode . typescript-ts-mode)
                (json-mode . json-ts-mode)))

        ;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        ;; Server
        ;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        (server-start)

        (provide 'init)
        ;;; init.el ends here
      '';
    };
  };
}
