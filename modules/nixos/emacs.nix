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
    evil-collection
    general

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

        ;; Scrolling
        (setq scroll-margin 8
              scroll-conservatively 101
              scroll-preserve-screen-position t
              auto-window-vscroll nil)

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
        ;; General (leader key framework)
        ;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        (use-package general
          :ensure nil
          :demand t
          :config
          (general-evil-setup t)

          ;; Global leader (SPC in normal mode)
          (general-create-definer my/leader-keys
            :states '(normal visual emacs)
            :keymaps 'override
            :prefix "SPC")

          ;; Local leader (, in normal mode) — for mode-specific
          (general-create-definer my/local-leader-keys
            :states '(normal visual emacs)
            :keymaps 'override
            :prefix ",")

          ;; Window prefix
          (my/leader-keys
            "w" '(:ignore t :which-key "window")
            "wh" '(evil-window-left :which-key "left")
            "wj" '(evil-window-down :which-key "down")
            "wk" '(evil-window-up :which-key "up")
            "wl" '(evil-window-right :which-key "right")
            "ww" '(other-window :which-key "other")
            "wH" '((lambda () (interactive) (evil-window-decrease-width 2)) :which-key "decrease width")
            "wJ" '((lambda () (interactive) (evil-window-increase-height 2)) :which-key "increase height")
            "wK" '((lambda () (interactive) (evil-window-decrease-height 2)) :which-key "decrease height")
            "wL" '((lambda () (interactive) (evil-window-increase-width 2)) :which-key "increase width")
            "w|" '(evil-window-vsplit :which-key "vsplit")
            "w-" '(evil-window-split :which-key "split")
            "wd" '(evil-window-delete :which-key "delete"))

          ;; Buffer prefix
          (my/leader-keys
            "b" '(:ignore t :which-key "buffer")
            "bb" '(consult-buffer :which-key "switch")
            "bn" '(next-buffer :which-key "next")
            "bp" '(previous-buffer :which-key "prev")
            "bd" '(kill-buffer :which-key "kill")
            "br" '(revert-buffer :which-key "revert"))

          ;; File prefix
          (my/leader-keys
            "f" '(:ignore t :which-key "file")
            "ff" '(consult-find :which-key "find")
            "fw" '(consult-ripgrep :which-key "grep")
            "fb" '(consult-buffer :which-key "buffer")
            "fo" '(consult-recent-file :which-key "recent")
            "fr" '(consult-recent-file :which-key "recent")
            "fs" '(save-buffer :which-key "save"))

          ;; Open prefix
          (my/leader-keys
            "o" '(:ignore t :which-key "open")
            "ot" '(treemacs :which-key "treemacs")
            "oe" '(eval-expression :which-key "eval"))

          ;; Git prefix
          (my/leader-keys
            "g" '(:ignore t :which-key "git")
            "gg" '(magit-status :which-key "status")
            "gb" '(magit-blame-addition :which-key "blame")
            "gc" '(magit-commit-create :which-key "commit")
            "gd" '(magit-diff-working-tree :which-key "diff")
            "gl" '(magit-log-buffer-file :which-key "log"))

          ;; LSP prefix (Eglot)
          (my/leader-keys
            "l" '(:ignore t :which-key "lsp")
            "la" '(eglot-code-actions :which-key "actions")
            "ld" '(xref-find-definitions :which-key "definition")
            "lD" '(eglot-find-declaration :which-key "declaration")
            "lf" '(eglot-format :which-key "format")
            "lh" '(eldoc-doc-buffer :which-key "hover doc")
            "li" '(eglot-find-implementation :which-key "implementation")
            "lr" '(xref-find-references :which-key "references")
            "lR" '(eglot-rename :which-key "rename")
            "ls" '(eldoc :which-key "signature")
            "lt" '(eglot-find-typeDefinition :which-key "type def"))

          ;; Direct keys (no prefix)
          (my/leader-keys
            "q" '(quit-window :which-key "quit")
            "Q" '(save-buffers-kill-terminal :which-key "quit emacs")
            "/" '(comment-line :which-key "comment")))

        ;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        ;; Evil Mode
        ;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
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

          ;; K380 Graphite theme colours
          (set-face-attribute 'centaur-tabs-default nil
            :background "#28261F" :foreground "#C8C8C0")
          (set-face-attribute 'centaur-tabs-selected nil
            :background "#302E26" :foreground "#C8C8C0" :bold t)
          (set-face-attribute 'centaur-tabs-unselected nil
            :background "#28261F" :foreground "#888882")
          (set-face-attribute 'centaur-tabs-selected-modified nil
            :background "#302E26" :foreground "#E8A020" :bold t)
          (set-face-attribute 'centaur-tabs-unselected-modified nil
            :background "#28261F" :foreground "#E8A020")
          (set-face-attribute 'centaur-tabs-active-bar-face nil
            :background "#F0C040" :height 3)
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
        ;; Server (only if not already running)
        ;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        (unless (server-running-p)
          (server-start))

        (provide 'init)
        ;;; init.el ends here
      '';
    };
  };
}
