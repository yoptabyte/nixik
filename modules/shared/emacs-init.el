;;; init.el --- Doom-like Emacs configuration  -*- lexical-binding: t; -*-

;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
;; Startup optimizations (before everything else)
;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
(defvar my/file-name-handler-alist file-name-handler-alist)
(setq file-name-handler-alist nil
      gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 0.6)
(add-hook 'emacs-startup-hook
  (lambda ()
    (setq file-name-handler-alist my/file-name-handler-alist
          gc-cons-threshold (* 16 1024 1024)
          gc-cons-percentage 0.1)
    (message "Loaded in %.2fs with %d GCs"
             (float-time (time-subtract after-init-time before-init-time))
             gcs-done)))

;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
;; Theme
;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
(add-to-list 'custom-theme-load-path "~/.emacs.d/themes")
(load-theme 'k380-graphite t)

;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
;; UI Basics
;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

;; Fix dired with Nushell: try GNU ls first, fall back to BSD ls
(setq insert-directory-program
      (or (executable-find "gls")
          (and (file-executable-p "/opt/homebrew/bin/gls") "/opt/homebrew/bin/gls")
          "/run/current-system/sw/bin/ls"
          "ls"))
;; BSD ls doesn't support --dired
(when (equal insert-directory-program "ls")
  (setq dired-use-ls-dired nil))

;; Nushell doesn't understand bash-style backslash escaping.
;; Use bash for Emacs internals (dired, shell-command), and
;; nushell for interactive M-x shell.
(setq shell-file-name "/run/current-system/sw/bin/bash")
(setq explicit-shell-file-name (executable-find "nu"))

;; Ensure Nix-installed tools (rg, fd, etc.) are in exec-path
(dolist (dir (list "/run/current-system/sw/bin"
                   "/etc/profiles/per-user/yoptabyte/bin"
                   (expand-file-name "~/.nix-profile/bin")))
  (when (file-directory-p dir)
    (add-to-list 'exec-path dir)))

(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(set-fringe-mode 10)
(setq inhibit-startup-message t
      initial-scratch-message nil
      visible-bell t
      ring-bell-function 'ignore)

(set-face-attribute 'default nil :font "ZedMono Nerd Font" :height 140)
(global-display-line-numbers-mode t)
(setq display-line-numbers-type 'relative)
(setq-default cursor-type 'bar)

;; Scrolling
(setq scroll-margin 8
      scroll-conservatively 101
      scroll-preserve-screen-position t
      auto-window-vscroll nil)

;; Transparent background
(set-frame-parameter (selected-frame) 'alpha-background 100)
(add-to-list 'default-frame-alist '(alpha-background . 100))

;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
;; Backup / Autosave
;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
(setq make-backup-files nil
      auto-save-default nil)

;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
;; use-package (пакеты управляются Nix, MELPA не нужен)
;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
(require 'use-package)
(setq use-package-always-ensure nil
      native-comp-async-report-warnings-errors nil
      native-comp-deferred-compilation t
      read-process-output-max (* 1024 1024))

;; Fix marginalia compat for Emacs 30 (seconds-to-string no longer takes extra args)
(advice-add 'seconds-to-string :around
  (lambda (orig secs &rest _)
    (funcall orig secs)))

;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
;; Org-babel: code execution in .org files
;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
(with-eval-after-load 'org
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((emacs-lisp . t)
     (shell . t)
     (python . t)
     (rust . t)
     (go . t)
     (java . t)
     (C . t))))

;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
;; General (leader key framework)
;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
(use-package general
  :demand t
  :config
  (general-evil-setup t)

  ;; Global leader (SPC in normal mode)
  (general-create-definer my/leader-keys
    :states '(normal visual emacs)
    :keymaps 'override
    :prefix "SPC")

  ;; Local leader (, in normal mode)
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
    "ff" '(dired :which-key "dired")
    "fw" '(consult-ripgrep :which-key "grep")
    "fb" '(consult-buffer :which-key "buffer")
    "fo" '(consult-recent-file :which-key "recent")
    "fr" '(consult-recent-file :which-key "recent")
    "fs" '(save-buffer :which-key "save")
    "f/" '(find-file :which-key "remote (tramp)"))

  ;; Open prefix
  (my/leader-keys
    "o" '(:ignore t :which-key "open")
    "ot" '(treemacs :which-key "treemacs")
    "oe" '(eval-expression :which-key "eval")
    "oi" '(my/paste-clipboard-image :which-key "image from clipboard"))

  ;; Direnv whitelist
  (my/leader-keys
    "d" '(:ignore t :which-key "direnv")
    "da" '(my/direnv-whitelist-add    :which-key "add to whitelist")
    "dr" '(my/direnv-whitelist-remove :which-key "remove from whitelist")
    "dl" '(my/direnv-whitelist-list   :which-key "list whitelist"))

  ;; Clipboard history
  (my/leader-keys
    "y" '(:ignore t :which-key "clipboard")
    "yy" '(my/cliphist-pick   :which-key "history")
    "yd" '(my/cliphist-delete :which-key "delete entry")
    "yw" '(my/cliphist-clear  :which-key "wipe all"))

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
  :demand t
  :init
  (setq evil-want-integration t
        evil-want-keybinding nil
        evil-want-C-u-scroll t
        evil-want-C-i-jump nil
        evil-want-C-d-scroll t
        evil-want-C-w-delete t
        evil-want-C-w-kill t
        evil-respect-visual-line-mode t
        evil-undo-system 'undo-redo)
  :config
  (evil-mode 1)
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
  :demand t
  :after evil
  :config
  (setq evil-collection-mode-list
        '(dashboard dired ibuffer magit term vterm pdf))
  (evil-collection-init))

;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
;; Drag stuff
;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
(use-package drag-stuff
  :bind
  (:map evil-visual-state-map
        ("J" . drag-stuff-down)
        ("K" . drag-stuff-up)))

;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
;; Completion (Vertico + Orderless + Marginalia)
;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
(use-package vertico
  :demand t
  :init
  (vertico-mode 1)
  :config
  (setq vertico-cycle t))

(use-package orderless
  :demand t
  :config
  (setq completion-styles '(orderless basic))
  (setq completion-category-defaults nil)
  (setq completion-category-overrides
        '((file (styles partial-completion)))))

(use-package marginalia
  :demand t
  :init
  (marginalia-mode 1))

;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
;; Corfu (in-buffer completion UI)
;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
(use-package corfu
  :demand t
  :init
  (global-corfu-mode 1)
  :config
  (setq corfu-cycle t
        corfu-auto t
        corfu-auto-delay 0.2
        corfu-auto-prefix 2
        corfu-quit-no-match t)
  (corfu-popupinfo-mode 1)
  :bind
  (:map corfu-map
        ("C-n" . corfu-next)
        ("C-p" . corfu-previous)
        ("<tab>" . corfu-complete)
        ("RET" . corfu-insert)))

;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
;; Nerd Icons
;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
(use-package nerd-icons
  :demand t)

(use-package nerd-icons-completion
  :demand t
  :after marginalia
  :config
  (nerd-icons-completion-mode 1))

;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
;; Consult
;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
(use-package consult
  :demand t
  :bind
  (([remap switch-to-buffer] . consult-buffer)
   ([remap switch-to-buffer-other-window] . consult-buffer-other-window)
   ([remap yank-pop] . consult-yank-pop))
  :config
  (setq consult-narrow-key "<"
        consult-line-numbers-widen t)
  ;; Always start consult-find from the current file's directory
  (setq consult-project-root-function
        (lambda () (locate-dominating-file default-directory ".git"))))

;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
;; Which-key
;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
(use-package which-key
  :demand t
  :config
  (which-key-mode 1)
  (setq which-key-idle-delay 0.3
        which-key-sort-order 'which-key-key-order-alpha))

;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
;; Treemacs
;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
(use-package treemacs
  :commands (treemacs treemacs-select-window treemacs-find-file)
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
  :after (treemacs evil)
  :config
  (evil-define-key 'normal treemacs-mode-map
    (kbd "C-=") #'text-scale-increase
    (kbd "C--") #'text-scale-decrease))

(use-package treemacs-magit
  :after (treemacs magit)
  :config
  (setq treemacs-show-changed-files-as-modified t)
  (treemacs-git-mode 'extended))

;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
;; Diff-hl
;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
(use-package diff-hl
  :hook ((after-init . global-diff-hl-mode)
         (after-init . diff-hl-margin-mode))
  :config
  (setq diff-hl-draw-borders nil
        diff-hl-use-fringe t)
  (custom-set-faces
   '(diff-hl-insert ((t (:background "#3D5A3D" :foreground "#A8D8A0"))))
   '(diff-hl-change ((t (:background "#5A5A2E" :foreground "#F0C040"))))
   '(diff-hl-delete ((t (:background "#5A2E2E" :foreground "#E8A020"))))))

;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
;; PDF Tools
;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
(use-package pdf-tools
  :magic ("%PDF" . pdf-view-mode)
  :config
  (pdf-tools-install :no-query)
  (setq pdf-view-use-scaling t
        pdf-view-use-imagemagick nil
        pdf-view-resize-factor 1.1
        pdf-annot-activate-extra-actions nil
        pdf-cache-prefetch-delay 0.3
        pdf-cache-image-limit 32
        pdf-view-display-size 'fit-page)

  ;; Disable display-line-numbers-mode in PDF view
  (add-hook 'pdf-view-mode-hook (lambda () (display-line-numbers-mode -1)))

  ;; K380 Graphite colours for PDF view
  (set-face-attribute 'pdf-view-region nil :background "#3D3B30" :foreground "#C8C8C0")

  ;; Soft scroll
  (setq pdf-view-use-scrollbar t
        pdf-view-continuous nil)

  ;; Evil keybindings for PDF view
  (evil-define-key 'normal pdf-view-mode-map
    "j"   'pdf-view-next-line-or-next-page
    "k"   'pdf-view-previous-line-or-previous-page
    "C-d" 'pdf-view-scroll-up-or-next-page
    "C-u" 'pdf-view-scroll-down-or-previous-page
    "gg"  'pdf-view-first-page
    "G"   'pdf-view-last-page
    "J"   'pdf-view-next-page-command
    "K"   'pdf-view-previous-page-command
    "C-f" 'pdf-view-next-page-command
    "C-b" 'pdf-view-previous-page-command
    "/"   'pdf-view-isearch-forward
    "?"   'pdf-view-isearch-backward
    "n"   'pdf-view-isearch-repeat-forward
    "N"   'pdf-view-isearch-repeat-backward
    "+"   'pdf-view-enlarge
    "="   'pdf-view-enlarge
    "-"   'pdf-view-shrink
    "0"   'pdf-view-fit-width
    "W"   'pdf-view-fit-width
    "h"   'pdf-view-fit-height
    "M"   'pdf-view-goto-page
    "o"   'pdf-outline
    "t"   'pdf-outline
    "r"   'pdf-view-revert-buffer
    "q"   'quit-window))

;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
;; Image viewing
;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
(use-package image-mode
  :ensure nil
  :hook (image-mode . (lambda ()
                        (display-line-numbers-mode -1)
                        (auto-revert-mode 1)))
  :config
  (setq image-auto-resize 'fit-window
        image-auto-resize-on-window-resize 1
        image-transform-smoothing t
        image-use-external-converter t))

;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
;; Markdown
;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
(use-package markdown-mode
  :mode (("\\.md\\'" . markdown-mode)
         ("\\.markdown\\'" . markdown-mode))
  :config
  (setq markdown-fontify-code-blocks-natively t))

;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
;; Vterm (terminal emulator)
;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
(use-package vterm
  :hook (vterm-mode . my/vterm-hook)
  :config
  (setq vterm-max-scrollback 10000
        vterm-term-environment-variable "xterm-256color")
  (add-to-list 'vterm-environment "COLORTERM=truecolor"))

(defun my/vterm-hook ()
  (display-line-numbers-mode -1)
  (hl-line-mode -1)
  (visual-line-mode -1)
  (setq-local global-hl-line-mode nil))

;; Kill line-numbers globalized mode re-trigger after major-mode changes
(defun my/after-change-major-mode-hook ()
  (when (derived-mode-p 'vterm-mode)
    (display-line-numbers-mode -1)))

(add-hook 'after-change-major-mode-hook #'my/after-change-major-mode-hook)

;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
;; Multi-vterm (terminal)
;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
(use-package multi-vterm
  :after vterm
  :commands (multi-vterm multi-vterm-project)
  :config
  (setq multi-vterm-buffer-name "vterm"
        multi-vterm-default-window-width 80
        multi-vterm-default-window-height 20)
  :bind
  (:map vterm-mode-map
        ("C-<tab>" . multi-vterm-next)
        ("C-S-<tab>" . multi-vterm-prev)))

(my/leader-keys
  "o'" '(multi-vterm :which-key "terminal")
  "o\"" '(multi-vterm-project :which-key "terminal (project)"))

;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
;; Magit
;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
(use-package magit
  :bind ("C-x g" . magit-status))

;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
;; Custom Modeline (replaces doom-modeline)
;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

;; Flymake segment — doom-style с nerd-icons, обновляется через hook, кэшируется per-buffer
(defvar-local my/flymake-string "")
(defun my/flymake-icon (icon-name face)
  "Возвращает material-design nerd-иконку ICON-NAME с наложенным FACE (пусто при ошибке)."
  (condition-case nil
      (let ((s (nerd-icons-mdicon icon-name)))
        (add-face-text-property 0 (length s) face nil s)
        s)
    (error "")))
(defun my/flymake-update (&rest _)
  (setq my/flymake-string
        (if (bound-and-true-p flymake-mode)
            (let* ((diags    (flymake-diagnostics))
                   (errors   (cl-count-if (lambda (d) (eq :error   (flymake-diagnostic-type d))) diags))
                   (warnings (cl-count-if (lambda (d) (eq :warning (flymake-diagnostic-type d))) diags))
                   (notes    (cl-count-if (lambda (d) (eq :note    (flymake-diagnostic-type d))) diags)))
              (if (zerop (+ errors warnings notes))
                  ""
                (concat
                 " "
                 (when (> errors 0)
                   (concat (my/flymake-icon "nf-md-close_circle" '(:foreground "#fb4934" :weight bold))
                           (propertize (format "%d " errors) 'face '(:foreground "#fb4934" :weight bold))))
                 (when (> warnings 0)
                   (concat (my/flymake-icon "nf-md-alert" '(:foreground "#e8a020"))
                           (propertize (format "%d " warnings) 'face '(:foreground "#e8a020"))))
                 (when (> notes 0)
                   (concat (my/flymake-icon "nf-md-information" 'shadow)
                           (propertize (format "%d " notes) 'face 'shadow)))
                 " ")))
          ""))
  (force-mode-line-update))
(add-hook 'flymake-after-stabilize-hook #'my/flymake-update)
;; Включаем flymake во всех программных буферах — индикаторы оживают как в doom-modeline
(add-hook 'prog-mode-hook #'flymake-mode)

;; PDF page/total indicator
(defun my/pdf-page-string ()
  (when (and (eq major-mode 'pdf-view-mode)
             (fboundp 'pdf-view-current-page))
    (condition-case nil
        (propertize (format " %d/%d "
                            (pdf-view-current-page)
                            (pdf-cache-number-of-pages))
                    'face 'font-lock-constant-face)
      (error nil))))

;; Active window tracking
(defvar my/selected-window (frame-selected-window))
(defun my/set-selected-window (&rest _)
  (when (not (minibuffer-window-active-p (frame-selected-window)))
    (setq my/selected-window (frame-selected-window))
    (force-mode-line-update)))
(defun my/unset-selected-window ()
  (setq my/selected-window nil)
  (force-mode-line-update))
(add-hook 'window-configuration-change-hook #'my/set-selected-window)
(add-hook 'focus-in-hook #'my/set-selected-window)
(add-hook 'focus-out-hook #'my/unset-selected-window)
(advice-add 'handle-switch-frame :after #'my/set-selected-window)
(advice-add 'select-window :after #'my/set-selected-window)
(defun my/selected-window-active-p ()
  (eq my/selected-window (selected-window)))

;; Evil state indicator
(defvar my/evil-state-data
  '((normal   :icon "λ" :bg "#665520" :fg "#f0c040")
    (insert   :icon "λ" :bg "#335533" :fg "#a0d8a0")
    (visual   :icon "λ" :bg "#553355" :fg "#d0a0d0")
    (replace  :icon "λ" :bg "#663333" :fg "#e08080")
    (emacs    :icon "λ" :bg "#553333" :fg "#e08080")
    (motion   :icon "λ" :bg "#445566" :fg "#80a0c0")
    (operator :icon "λ" :bg "#664433" :fg "#d0a060")))

(defun my/evil-state-face ()
  (if-let ((data (and (boundp 'evil-state) (cdr (assq evil-state my/evil-state-data)))))
      (list :foreground (plist-get data :fg)
            :background (plist-get data :bg)
            :weight 'bold :box t)
    'mode-line-inactive))

(defun my/evil-state-string ()
  (if (not (and (boundp 'evil-state) evil-state))
      ""
    (let ((icon (or (plist-get (cdr (assq evil-state my/evil-state-data)) :icon) "λ"))
          (face (my/evil-state-face)))
      (propertize (concat " " icon " ") 'face face))))

(setq-default mode-line-format
              (list
               '(:eval (my/evil-state-string))
               " "
               '(:eval (when-let (s (and (boundp 'vc-mode) vc-mode))
                          (propertize (concat " " (substring s (min 5 (length s))) " ")
                                      'face 'font-lock-comment-face)))
               '(:eval (list
                        (propertize " %b"
                                    'face (if (my/selected-window-active-p)
                                              'font-lock-type-face
                                            'mode-line-inactive)
                                    'help-echo (buffer-file-name))
                        (when (buffer-modified-p)
                          (propertize " ●"
                                      'face (if (my/selected-window-active-p)
                                                'font-lock-warning-face
                                              'mode-line-inactive)))
                        (when buffer-read-only
                          (propertize " "
                                      'face (if (my/selected-window-active-p)
                                                'font-lock-type-face
                                              'mode-line-inactive)))
                        " "))
               '(:eval (or (my/pdf-page-string)
                           (propertize "%p" 'face 'font-lock-constant-face)))
               '(:eval (propertize
                        " " 'display
                        `((space :align-to (- (+ right right-fringe right-margin)
                                              ,(+ 3 (string-width
                                                     (format-mode-line
                                                      (list my/flymake-string global-mode-string " %m ")))))))))
               my/flymake-string
               global-mode-string
               (propertize " %m " 'face 'font-lock-string-face)))

;; Volume indicator in modeline — event-driven via wpctl subscribe
;; Icons use raw Nerd Font codepoints; nerd-icons-set-font sets up the fontset.
(defvar my/volume-string "")
(defvar my/volume-process nil)

(defun my/volume-icon-char (vol muted)
  (char-to-string
   (if muted #xf0581                        ; nf-md-volume_off
     (cond ((> vol 66) #xf057e)             ; nf-md-volume_high
           ((> vol 33) #xf0580)             ; nf-md-volume_medium
           (t          #xf057f)))))         ; nf-md-volume_low

(defun my/volume-refresh ()
  (let ((out (string-trim
              (shell-command-to-string
               "wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null"))))
    (setq my/volume-string
          (if (string-match "Volume: \\([0-9.]+\\)\\(.*\\)" out)
              (let* ((vol      (round (* 100 (string-to-number (match-string 1 out)))))
                     (muted    (string-match-p "MUTED" (match-string 2 out)))
                     (vol-face (if muted 'shadow 'font-lock-builtin-face)))
                (concat (propertize (my/volume-icon-char vol muted)
                                    'face `(:family "Symbols Nerd Font Mono"
                                            :inherit ,vol-face))
                        (propertize (format " %d%% " vol) 'face vol-face)))
            ""))
    (force-mode-line-update t)))

(defun my/volume-start-monitor ()
  (my/volume-refresh)
  (unless (process-live-p my/volume-process)
    (when-let ((prog (executable-find "wpctl")))
      (condition-case nil
          (progn
            (setq my/volume-process
                  (start-process "wpctl-subscribe" nil prog "subscribe"))
            (set-process-filter my/volume-process
              (lambda (_proc output)
                (when (string-match-p "sink\\|server" output)
                  (my/volume-refresh)))))
        (error (message "volume monitor: wpctl subscribe failed"))))))

(add-hook 'emacs-startup-hook #'my/volume-start-monitor)
(add-to-list 'global-mode-string 'my/volume-string t)

;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
;; Perspective (workspaces)
;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
(use-package perspective
  :demand t
  :config
  (setq persp-suppress-no-prefix-key-warning t)
  (persp-mode 1))

;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
;; Nix
;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
(use-package nix-mode
  :mode "\\.nix\\'")

;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
;; Go
;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
(use-package go-mode
  :mode "\\.go\\'"
  :hook (before-save . gofmt-before-save))

;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
;; PHP
;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
(use-package php-mode
  :mode "\\.php\\'")

;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
;; Rainbow delimiters (Lisp / Clojure)
;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
(use-package rainbow-delimiters
  :hook ((emacs-lisp-mode lisp-mode
          clojure-mode clojure-ts-mode
          scheme-mode) . rainbow-delimiters-mode))

;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
;; Paredit + evil-paredit (структурное редактирование Clojure)
;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
(use-package paredit
  :hook ((clojure-mode clojure-ts-mode emacs-lisp-mode lisp-mode) . paredit-mode))

(use-package evil-paredit
  :after (evil paredit)
  :hook ((clojure-mode clojure-ts-mode emacs-lisp-mode lisp-mode) . evil-paredit-mode))

;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
;; Clojure (mode + CIDER REPL)
;; Flake: { clojure-lsp, clojure, leiningen/clj }
;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
(use-package clojure-mode
  :mode (("\\.clj\\'"  . clojure-mode)
         ("\\.cljs\\'" . clojure-mode)
         ("\\.cljc\\'" . clojure-mode)
         ("\\.edn\\'"  . clojure-mode)))

(use-package clojure-ts-mode
  :after clojure-mode)

(use-package cider
  :commands (cider-jack-in cider-jack-in-cljs cider-connect)
  :config
  (setq cider-repl-display-help-banner nil
        cider-repl-pop-to-buffer-on-connect 'display-only
        cider-prompt-for-symbol nil
        cider-save-file-on-load t
        cider-auto-select-error-buffer t))

(with-eval-after-load 'cider
  (my/local-leader-keys
    :keymaps '(clojure-mode-map clojure-ts-mode-map)
    "'"  '(cider-jack-in           :which-key "jack-in")
    "e"  '(:ignore t               :which-key "eval")
    "eb" '(cider-eval-buffer       :which-key "buffer")
    "ef" '(cider-eval-defun-at-point :which-key "defun")
    "ee" '(cider-eval-last-sexp    :which-key "last sexp")
    "er" '(cider-eval-region       :which-key "region")
    "t"  '(:ignore t               :which-key "test")
    "tt" '(cider-test-run-test     :which-key "run test")
    "tn" '(cider-test-run-ns-tests :which-key "ns tests")
    "r"  '(:ignore t               :which-key "repl")
    "rb" '(cider-switch-to-repl-buffer :which-key "switch to repl")
    "rn" '(cider-repl-set-ns       :which-key "set ns")))

;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
;; Scala (tree-sitter mode)
;; Flake: { metals }  — metals требует Java в PATH
;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
(use-package scala-ts-mode
  :mode "\\.scala\\'")

;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
;; Vue SFC (web-mode + volar)
;; Flake: { nodePackages.vue-language-server }
;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
(use-package web-mode
  :mode "\\.vue\\'"
  :config
  (setq web-mode-markup-indent-offset 2
        web-mode-css-indent-offset    2
        web-mode-code-indent-offset   2
        web-mode-enable-auto-pairing       t
        web-mode-enable-css-colorization   t
        web-mode-enable-current-element-highlight t))

;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
;; Typst (typst-mode.el, polymode-based)
;; Flake: { tinymist }
;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
(use-package typst-mode
  :mode "\\.typ\\'")

;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
;; Haskell (haskell-mode + HLS через eglot)
;; Flake devShell: { haskellPackages.haskell-language-server ghc cabal-install }
;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
(use-package haskell-mode
  :mode (("\\.hs\\'"    . haskell-mode)
         ("\\.lhs\\'"   . haskell-literate-mode)
         ("\\.cabal\\'" . haskell-cabal-mode))
  :interpreter ("runghc" . haskell-mode)
  :hook ((haskell-mode . interactive-haskell-mode)
         (haskell-mode . haskell-decl-scan-mode)
         (haskell-mode . haskell-indentation-mode))
  :config
  (setq haskell-process-type              'cabal-repl
        haskell-process-sources           '("Setup.hs")
        haskell-process-log               t
        haskell-stylish-on-save           nil
        haskell-tags-on-save              nil
        haskell-interactive-popup-errors  nil))

(with-eval-after-load 'haskell-mode
  (my/local-leader-keys
    :keymaps '(haskell-mode-map)
    "'" '(haskell-interactive-switch  :which-key "repl")
    "l" '(haskell-process-load-file   :which-key "load file")
    "r" '(haskell-process-reload      :which-key "reload")
    "b" '(haskell-process-cabal-build :which-key "cabal build")
    "t" '(haskell-process-do-type     :which-key "type at")
    "i" '(haskell-process-do-info     :which-key "info at")))

;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
;; Envrc — per-buffer direnv integration (must be before eglot)
;; Emacs will use LSP servers from the project's flake devShell
;; when the project has .envrc with "use flake"
;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
(use-package envrc
  :demand t
  :config
  (envrc-global-mode 1)
  ;; eglot-ensure срабатывает из хука major-mode РАНЬШЕ, чем envrc--apply
  ;; обновит exec-path (direnv запускается асинхронно). Advice запускает
  ;; eglot-ensure повторно после того как flake-окружение реально применено.
  (advice-add 'envrc--apply :after
    (lambda (buf _result)
      (with-current-buffer buf
        (when (and buffer-file-name
                   (not (bound-and-true-p eglot--managed-mode)))
          (condition-case nil (eglot-ensure) (error nil)))))))

;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
;; Eglot (LSP)
;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
;; LSP-серверы разрешаются через envrc + direnv per-buffer.
;; Для каждого проекта достаточно:
;;   1. flake.nix с devShells.default, содержащим нужный LSP (gopls, metals, clojure-lsp, ...)
;;   2. .envrc с единственной строкой: use flake
;;   3. однократно выполнить: direnv allow
;; После этого eglot найдёт сервер из окружения flake автоматически.
(use-package eglot
  :hook ((python-ts-mode rust-ts-mode go-ts-mode go-mode java-ts-mode java-mode
          js-ts-mode typescript-ts-mode tsx-ts-mode csharp-ts-mode
          css-ts-mode html-ts-mode php-mode php-ts-mode
          scala-mode scala-ts-mode
          clojure-mode clojure-ts-mode
          web-mode
          typst-mode
          nix-mode markdown-mode
          haskell-mode haskell-literate-mode) . eglot-ensure))

(with-eval-after-load 'eglot
  ;; Tailwind CSS (JS/TS/HTML/CSS — без web-mode, там volar)
  (dolist (mode '(tsx-ts-mode typescript-ts-mode js-ts-mode html-ts-mode css-ts-mode))
    (add-to-list 'eglot-server-programs
      (cons mode '("tailwindcss-language-server" "--stdio"))))
  ;; Clojure LSP (из flake: pkgs.clojure-lsp)
  (add-to-list 'eglot-server-programs
    '((clojure-mode clojure-ts-mode) . ("clojure-lsp")))
  ;; Scala Metals (из flake: pkgs.metals)
  (add-to-list 'eglot-server-programs
    '((scala-mode scala-ts-mode) . ("metals")))
  ;; Vue — Volar / vue-language-server (из flake: pkgs.nodePackages.vue-language-server)
  (add-to-list 'eglot-server-programs
    '(web-mode . ("vue-language-server" "--stdio")))
  ;; Typst — tinymist (из flake: pkgs.tinymist)
  (add-to-list 'eglot-server-programs
    '(typst-mode . ("tinymist")))
  ;; Haskell — haskell-language-server (из flake: haskellPackages.haskell-language-server)
  (add-to-list 'eglot-server-programs
    '((haskell-mode haskell-literate-mode) . ("haskell-language-server-wrapper" "--lsp"))))

;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
;; Dape — Debug Adapter Protocol (eglot-compatible)
;; Адаптеры берутся из flake окружения (через envrc).
;; В devShells.default добавь:
;;   Go:   delve
;;   Rust: lldb  (codelldb из vscode-extensions)
;;   JS/TS: nodejs (встроенный инспектор)
;;   PHP:  php с расширением xdebug
;;   Java: jdt-language-server (содержит debug-адаптер)
;;   Scala: metals (содержит debug-адаптер)
;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
(use-package dape
  :commands (dape dape-breakpoint-toggle)
  :config
  ;; Показывать окна при старте отладки
  (setq dape-buffer-window-arrangement 'right
        dape-info-hide-mode-line        nil
        dape-repl-use-overlay-arrow     t)

  ;; Сохранять буферы перед запуском
  (add-hook 'dape-on-start-hooks
            (lambda () (save-some-buffers t nil)))

  ;; Убирать сессию по завершению
  (add-hook 'dape-on-stopped-hooks #'dape-info)

  ;; Pulse на текущую строку при остановке
  (add-hook 'dape-on-stopped-hooks
            (lambda ()
              (pulse-momentary-highlight-one-line (point))))

  ;; ── Go (delve из flake: pkgs.delve) ─────────────
  (add-to-list 'dape-configs
    `(go-debug
      modes (go-mode go-ts-mode)
      command "dlv"
      command-args ("dap" "--listen" "127.0.0.1::autoport")
      command-cwd dape-cwd-fn
      host "127.0.0.1"
      port :autoport
      :type "go"
      :request "launch"
      :mode "debug"
      :program "."))

  ;; ── Rust (lldb из flake: pkgs.lldb) ─────────────
  (add-to-list 'dape-configs
    `(rust-lldb
      modes (rust-mode rust-ts-mode)
      command "lldb-dap"
      command-cwd dape-cwd-fn
      :type "lldb"
      :request "launch"
      :cwd dape-cwd-fn
      :program (lambda ()
                 (read-file-name "Binary: "
                   (expand-file-name "target/debug/" (dape-cwd))))))

  ;; ── JS / TS (Node.js встроенный инспектор) ──────
  (add-to-list 'dape-configs
    `(node-debug
      modes (js-mode js-ts-mode typescript-ts-mode tsx-ts-mode)
      command "node"
      command-args ("--inspect-brk=0" :autoport)
      host "127.0.0.1"
      port :autoport
      :type "node"
      :request "launch"
      :program dape-buffer-default))

  ;; ── PHP (xdebug, слушает входящее соединение) ───
  (add-to-list 'dape-configs
    `(php-xdebug
      modes (php-mode php-ts-mode)
      host "127.0.0.1"
      port 9003
      :type "php"
      :request "launch"
      :program dape-buffer-default))

  ;; ── Java (jdtls debug adapter) ──────────────────
  (add-to-list 'dape-configs
    `(java-debug
      modes (java-mode java-ts-mode)
      :type "java"
      :request "launch"
      :mainClass (lambda ()
                   (read-string "Main class: ")))))

;; Debug leader биндинги под SPC D
(my/leader-keys
  "D"  '(:ignore t                        :which-key "debug")
  "Dd" '(dape                             :which-key "start / select")
  "Db" '(dape-breakpoint-toggle           :which-key "breakpoint")
  "DB" '(dape-breakpoint-expression       :which-key "conditional bp")
  "Dl" '(dape-breakpoint-log              :which-key "log bp")
  "Dn" '(dape-next                        :which-key "next")
  "Ds" '(dape-step-in                     :which-key "step in")
  "Do" '(dape-step-out                    :which-key "step out")
  "Dc" '(dape-continue                    :which-key "continue")
  "Dr" '(dape-restart                     :which-key "restart")
  "Dq" '(dape-quit                        :which-key "quit")
  "De" '(dape-evaluate-expression         :which-key "eval expr")
  "Di" '(dape-info                        :which-key "info panel")
  "Dw" '(dape-watch-dwim                  :which-key "watch"))

;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
;; Treesitter
;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
(setq major-mode-remap-alist
      '((python-mode     . python-ts-mode)
        (rust-mode       . rust-ts-mode)
        (java-mode       . java-ts-mode)
        (js-mode         . js-ts-mode)
        (typescript-mode . typescript-ts-mode)
        (tsx-mode        . tsx-ts-mode)
        (json-mode       . json-ts-mode)
        (csharp-mode     . csharp-ts-mode)
        (css-mode        . css-ts-mode)
        (html-mode       . html-ts-mode)
        (go-mode         . go-ts-mode)
        (clojure-mode    . clojure-ts-mode)
        (scala-mode      . scala-ts-mode)))

;; Явные ассоциации расширений (не перекрываем уже настроенные через remap-alist)
(dolist (pair '(("\\.jsx\\'"  . tsx-ts-mode)   ; JSX → tsx-ts-mode (поддерживает и JSX)
                ("\\.tsx\\'"  . tsx-ts-mode)
                ("\\.vue\\'"  . web-mode)        ; Vue SFC → web-mode + volar
                ("\\.typ\\'"  . typst-mode)))    ; Typst
  (add-to-list 'auto-mode-alist pair))

;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
;; TRAMP (remote files via SSH)
;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
(setq tramp-default-method "ssh"
      tramp-verbose 2
      tramp-auto-save-directory (expand-file-name "tramp-autosaves" user-emacs-directory)
      tramp-persistency-file-name (expand-file-name "tramp-connection-history" user-emacs-directory))

;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
;; Dired archive support (Z = extract, c = create)
;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
(with-eval-after-load 'dired-aux
  ;; Extract handlers for Z — ordered most-specific first (.tar.gz before .gz)
  (setq dired-compress-file-suffixes
        '(("\\.tar\\.gz\\'"  "" "tar -xzf")
          ("\\.tar\\.bz2\\'" "" "tar -xjf")
          ("\\.tar\\.xz\\'"  "" "tar -xJf")
          ("\\.tar\\.zst\\'" "" "tar --zstd -xf")
          ("\\.tgz\\'"       "" "tar -xzf")
          ("\\.tbz2\\'"      "" "tar -xjf")
          ("\\.txz\\'"       "" "tar -xJf")
          ;; ripunzip faster than unzip for large archives
          ("\\.zip\\'"       "" "ripunzip unzip-file")
          ("\\.7z\\'"        "" "7z x")
          ("\\.rar\\'"       "" "unar")
          ("\\.gz\\'"        "" "gunzip")
          ("\\.bz2\\'"       "" "bunzip2")
          ("\\.xz\\'"        "" "unxz")
          ("\\.zst\\'"       "" "zstd -d")
          ("\\.Z\\'"         "" "uncompress")))

  ;; Archive creation via c (dired-do-compress-to)
  (setq dired-compress-files-alist
        '(("\\.tar\\.gz\\'"  . "tar -czf %o %i")
          ("\\.tar\\.bz2\\'" . "tar -cjf %o %i")
          ("\\.tar\\.xz\\'"  . "tar -cJf %o %i")
          ("\\.tar\\.zst\\'" . "tar --zstd -cf %o %i")
          ("\\.zip\\'"       . "zip -r %o %i")
          ("\\.7z\\'"        . "7z a %o %i"))))

;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
;; Dired enhancements
;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

;; File icons via Nerd Font
(use-package nerd-icons-dired
  :hook (dired-mode . nerd-icons-dired-mode))

;; Async copy/move — C and R no longer block Emacs
(use-package async
  :config
  (dired-async-mode 1))


;; Open files with external programs based on extension
(use-package dired-open
  :after dired
  :config
  (setq dired-open-extensions
        '(;; Video → VLC
          ("mkv"  . "vlc") ("mp4"  . "vlc") ("avi"  . "vlc")
          ("mov"  . "vlc") ("webm" . "vlc") ("m4v"  . "vlc")
          ("wmv"  . "vlc") ("flv"  . "vlc")
          ;; Audio → Audacity
          ("mp3"  . "audacity") ("flac" . "audacity")
          ("wav"  . "audacity") ("ogg"  . "audacity")
          ("opus" . "audacity") ("m4a"  . "audacity")
          ("aac"  . "audacity")))
  ;; RET: open with external app if extension matches, else open in Emacs
  (evil-define-key 'normal dired-mode-map
    (kbd "RET") #'dired-open-file))

;; Incremental narrowing: / to filter files live
(use-package dired-narrow
  :after dired
  :config
  (evil-define-key 'normal dired-mode-map
    (kbd "/") #'dired-narrow))

;; Ranger-like: old dired buffer is killed when entering a subdir
(setq dired-kill-when-opening-new-dired-buffer t)

;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
;; Direnv whitelist management
;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
(defvar my/direnv-toml (expand-file-name "~/.config/direnv/direnv.toml"))

(defun my/direnv--read-prefixes ()
  "Return current whitelist prefix list from direnv.toml."
  (if (not (file-exists-p my/direnv-toml))
      '()
    (with-temp-buffer
      (insert-file-contents my/direnv-toml)
      (let ((content (buffer-string)))
        (if (string-match "prefix\\s-*=\\s-*\\[\\([^]]*\\)\\]" content)
            (let ((raw (match-string 1 content)))
              (seq-filter #'identity
                (mapcar (lambda (s)
                          (when (string-match "\"\\([^\"]+\\)\"" s)
                            (match-string 1 s)))
                        (split-string raw ","))))
          '())))))

(defun my/direnv--write-prefixes (prefixes)
  "Overwrite direnv.toml with updated PREFIXES list."
  (with-temp-file my/direnv-toml
    (insert (format "[whitelist]\nprefix = [%s]\n"
                    (mapconcat (lambda (d) (format "\"%s\"" d))
                               prefixes ", ")))))

(defun my/direnv-whitelist-add (&optional dir)
  "Add DIR (default: current dired directory) to direnv whitelist."
  (interactive
   (list (if (derived-mode-p 'dired-mode)
             (dired-current-directory)
           (read-directory-name "Whitelist directory: "))))
  (let* ((dir (concat (directory-file-name (expand-file-name dir)) "/"))
         (prefixes (my/direnv--read-prefixes)))
    (if (member dir prefixes)
        (message "direnv: already whitelisted: %s" dir)
      (my/direnv--write-prefixes (append prefixes (list dir)))
      (message "direnv: whitelisted ✓ %s" dir))))

(defun my/direnv-whitelist-remove ()
  "Remove an entry from direnv whitelist via completing-read."
  (interactive)
  (let ((prefixes (my/direnv--read-prefixes)))
    (if (null prefixes)
        (message "direnv: whitelist is empty")
      (let ((choice (completing-read "Remove from whitelist: " prefixes nil t)))
        (my/direnv--write-prefixes (delete choice prefixes))
        (message "direnv: removed %s" choice)))))

(defun my/direnv-whitelist-list ()
  "Show current direnv whitelist."
  (interactive)
  (let ((prefixes (my/direnv--read-prefixes)))
    (if prefixes
        (message "direnv whitelist:\n%s" (mapconcat (lambda (d) (concat "  " d)) prefixes "\n"))
      (message "direnv: whitelist is empty"))))

;; W в dired — добавить текущую директорию в whitelist
(with-eval-after-load 'dired
  (evil-define-key 'normal dired-mode-map
    (kbd "W") #'my/direnv-whitelist-add))

;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
;; Telega (Telegram client) — string-trim nil workaround
;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
(advice-add 'string-trim :before-until
  (lambda (s &rest _)
    (when (not (stringp s)) "")))

;; Load API credentials from ~/.config/telega/env (KEY=VAL, one per line)
;; Override the buffer-local telega-server--on-event-func with a custom
;; handler that injects our credentials, because the native-compiled
;; telega--setTdlibParameters ignores telega-app (and our fset).
(let ((env-id nil)
      (env-hash nil))
  (dolist (file '("~/.config/telega/env" "/etc/telega/env"))
    (when (file-exists-p file)
      (with-temp-buffer
        (insert-file-contents file)
        (dolist (line (split-string (buffer-string) "\n" t))
          (when (string-match "^TELEGA_API_ID=\\(.+\\)" line)
            (setq env-id (string-trim (match-string 1 line))))
          (when (string-match "^TELEGA_API_HASH=\\(.+\\)" line)
            (setq env-hash (string-trim (match-string 1 line))))))))
  (when (and env-id env-hash)
    (condition-case err
        (progn
          (require 'telega)
          (setq telega-app (cons (string-to-number env-id) env-hash))
          (advice-add 'telega-server--start :after
                      (lambda (&rest _)
                        (let ((buf (get-buffer " *telega-server*")))
                          (when buf
                            (with-current-buffer buf
                              (let ((orig-func telega-server--on-event-func))
                                (setq-local telega-server--on-event-func
                                      (lambda (event)
                                        (let* ((etype (plist-get event :@type))
                                               (astate (plist-get event :authorization_state))
                                               (atype (when astate (plist-get astate :@type)))
                                               (wait-params
                                                (or (equal etype "authorizationStateWaitTdlibParameters")
                                                    (and (equal etype "updateAuthorizationState")
                                                         (equal atype "authorizationStateWaitTdlibParameters")))))
                                          (if wait-params
                                              (progn
                                                (setq-local telega-server--on-event-func orig-func)
                                                (telega-server--send
                                                 (list :@type "setTdlibParameters"
                                                       :use_test_dc :false
                                                       :use_file_database t
                                                       :use_chat_info_database t
                                                       :use_message_database t
                                                       :use_secret_chats t
                                                       :api_id (string-to-number env-id)
                                                       :api_hash env-hash
                                                       :system_language_code "en"
                                                       :device_model "Emacs"
                                                       :system_version emacs-version
                                                       :application_version telega-version
                                                       :enable_storage_optimizer t
                                                       :database_directory telega-database-dir
                                                       :files_directory telega-cache-dir)))
                                            (funcall orig-func event))))))))))))
      (error (message "telega failed: %s" err)))))

(with-eval-after-load 'telega
  (setq telega-video-player-command "vlc --play-and-exit"))

;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
;; Zen Mode (distraction-free editing)
;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
(use-package zen-mode
  :commands zen-mode
  :init
  ;; linum-mode удалён в Emacs 30, zen-mode.el его вызывает — compat shim
  (unless (fboundp 'linum-mode)
    (defalias 'linum-mode 'display-line-numbers-mode))
  :config
  ;; zen-mode вызывает (linum-mode -1) → display-line-numbers-mode -1,
  ;; хук восстанавливает relative-нумерацию после этого
  (add-hook 'zen-mode-hook
            (lambda ()
              (display-line-numbers-mode 1)
              (setq display-line-numbers-type 'relative))))

(my/leader-keys
  "z" '(zen-mode :which-key "zen mode"))

;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
;; Server (only if not already running)
;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
(require 'server)
(unless (server-running-p)
  (server-start))

;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
;; Clipboard history (cliphist)
;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

(defun my/cliphist--entries ()
  "Return ((display id . imagep) ...) from cliphist list.
Binary entries labelled [image]; imagep=t for them."
  (with-temp-buffer
    (set-buffer-multibyte nil)
    (call-process "cliphist" nil t nil "list")
    (let (result)
      (goto-char (point-min))
      (while (re-search-forward "^\\([0-9]+\\)\t\\([^\n]*\\)" nil t)
        (let* ((id     (match-string-no-properties 1))
               (prev   (match-string-no-properties 2))
               (imagep (string-match-p "[^\x20-\x7e\t]" prev))
               (label  (if imagep
                           "[image]"
                         (truncate-string-to-width prev 100))))
          (push (cons (format "%s\t%s" id label) (cons id imagep)) result)))
      (nreverse result))))

(defun my/cliphist--copy-id (id)
  "Decode cliphist entry ID and copy to clipboard with correct MIME type."
  (let ((tmpf (make-temp-file "emacs-clip-")))
    (unwind-protect
        (progn
          (shell-command
           (format "printf '%%s\\t\\n' %s | cliphist decode > %s"
                   (shell-quote-argument id) (shell-quote-argument tmpf)))
          (let* ((mime (string-trim
                        (shell-command-to-string
                         (format "file -b --mime-type %s"
                                 (shell-quote-argument tmpf)))))
                 (cmd  (format "wl-copy -t %s < %s"
                               (shell-quote-argument mime)
                               (shell-quote-argument tmpf))))
            (start-process-shell-command "cliphist-copy" nil cmd)
            (message "Copied %s to clipboard" mime)))
      (run-with-timer 3 nil
                      (lambda () (when (file-exists-p tmpf) (delete-file tmpf)))))))

(defun my/cliphist-pick ()
  "Browse cliphist history; image entries show a live thumbnail preview."
  (interactive)
  (require 'consult)
  (let ((entries (my/cliphist--entries)))
    (if (null entries)
        (message "Clipboard history is empty")
      (let* ((prev-buf  (get-buffer-create "*cliphist-preview*"))
             (prev-tmpf nil)
             ;; Create side window BEFORE consult opens the minibuffer —
             ;; display-buffer is restricted while a minibuffer is active.
             (prev-win  (progn
                          (with-current-buffer prev-buf
                            (let ((inhibit-read-only t))
                              (erase-buffer)
                              (insert "[select an image entry to preview]")))
                          (display-buffer
                           prev-buf
                           '(display-buffer-in-side-window
                             (side . right)
                             (window-width . 70)
                             (dedicated . t))))))
        (unwind-protect
            (let* ((choice
                    (consult--read
                     (mapcar #'car entries)
                     :prompt "Clipboard: "
                     :sort nil
                     :preview-key 'any
                     :state
                     (lambda (action cand)
                       (pcase action
                         ('preview
                          (when prev-tmpf
                            (ignore-errors (delete-file prev-tmpf))
                            (setq prev-tmpf nil))
                          (let ((entry (and cand (assoc cand entries))))
                            (with-current-buffer prev-buf
                              (let ((inhibit-read-only t))
                                (erase-buffer)
                                (if (and entry (cddr entry))
                                    (let* ((id (cadr entry))
                                           (f  (make-temp-file "cliphist-img-")))
                                      (if (= 0 (shell-command
                                                (format "printf '%%s\\t\\n' %s | cliphist decode > %s 2>/dev/null"
                                                        (shell-quote-argument id)
                                                        (shell-quote-argument f))))
                                          (progn
                                            (setq prev-tmpf f)
                                            (condition-case err
                                                (insert-image
                                                 (create-image f nil nil
                                                               :max-width 640
                                                               :max-height 480))
                                              (error (insert (format "[render error: %s]" err)))))
                                        (progn
                                          (ignore-errors (delete-file f))
                                          (insert "[decode failed]"))))
                                  (insert (if cand "[not an image]" "")))
                                (goto-char (point-min))))))))))
                   (entry (assoc choice entries))
                   (id    (cadr entry)))
              (when id (my/cliphist--copy-id id)))
          (when prev-tmpf (ignore-errors (delete-file prev-tmpf)))
          (when (and prev-win (window-live-p prev-win))
            (delete-window prev-win)))))))

(defun my/cliphist-delete ()
  "Delete selected entry from cliphist history."
  (interactive)
  (let ((entries (my/cliphist--entries)))
    (if (null entries)
        (message "Clipboard history is empty")
      (let* ((choice (completing-read "Delete: " (mapcar #'car entries) nil t))
             (id     (cadr (assoc choice entries))))
        (when id
          (shell-command
           (format "printf '%%s\\t\\n' %s | cliphist delete"
                   (shell-quote-argument id)))
          (message "Deleted from clipboard history"))))))

(defun my/cliphist-clear ()
  "Wipe entire cliphist history and reset entry counter."
  (interactive)
  (when (yes-or-no-p "Clear ALL clipboard history? ")
    (when (process-live-p (get-process "cliphist-daemon"))
      (delete-process (get-process "cliphist-daemon")))
    (shell-command "cliphist wipe")
    (let ((db (expand-file-name "~/.cache/cliphist/db")))
      (when (file-exists-p db) (delete-file db)))
    (run-with-timer 0.5 nil #'my/start-cliphist-when-ready)
    (message "Clipboard history cleared")))

;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
;; Screenshot & clipboard daemon
;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
(defun my/start-cliphist-when-ready ()
  "Start cliphist daemon, retrying every 2s until WAYLAND_DISPLAY is set."
  (when (and (executable-find "wl-paste") (executable-find "cliphist"))
    (let ((wd (getenv "WAYLAND_DISPLAY")))
      (if (and wd (not (string-empty-p wd)))
          (unless (process-live-p (get-process "cliphist-daemon"))
            (start-process "cliphist-daemon" nil "wl-paste" "--watch" "cliphist" "store"))
        (run-with-timer 2 nil #'my/start-cliphist-when-ready)))))

(defun my/screenshot--env ()
  "Shell prefix that re-exports Wayland/display env vars for subprocesses.
Needed because the Emacs daemon may not have these in its environment."
  (mapconcat
   (lambda (var)
     (when-let ((val (getenv var)))
       (format "%s=%s " var (shell-quote-argument val))))
   '("WAYLAND_DISPLAY" "DISPLAY" "XDG_RUNTIME_DIR")
   ""))

(defun my/screenshot-area-to-clipboard ()
  "Screenshot selected area → clipboard."
  (interactive)
  (start-process-shell-command "screenshot" nil
    (format "%sregion=$(slurp) && grim -g \"$region\" - | wl-copy -t image/png"
            (my/screenshot--env))))

(defun my/screenshot-area-to-file ()
  "Screenshot selected area → ~/Pictures/."
  (interactive)
  (start-process-shell-command "screenshot" nil
    (format "%sregion=$(slurp) && grim -g \"$region\" ~/Pictures/screenshot-%s.png"
            (my/screenshot--env)
            (format-time-string "%Y%m%d-%H%M%S"))))

(defun my/screenshot-full-to-clipboard ()
  "Screenshot full screen → clipboard."
  (interactive)
  (start-process-shell-command "screenshot-full" nil
    (format "%sgrim - | wl-copy -t image/png" (my/screenshot--env))))

(defun my/screenshot-full-to-file ()
  "Screenshot full screen → ~/Pictures/."
  (interactive)
  (start-process-shell-command "screenshot-full" nil
    (format "%sgrim ~/Pictures/screenshot-%s.png"
            (my/screenshot--env)
            (format-time-string "%Y%m%d-%H%M%S"))))

;; Screenshot bindings — global-map + все evil states
;; (evil state maps имеют приоритет над global-map, поэтому нужны оба)
(let ((screenshot-keys
       `(([print]           . my/screenshot-area-to-clipboard)
         ([s-print]         . my/screenshot-area-to-file)
         ([S-print]         . my/screenshot-full-to-clipboard)
         ([s-S-print]       . my/screenshot-full-to-file))))
  (pcase-dolist (`(,key . ,fn) screenshot-keys)
    (define-key global-map key fn))
  (with-eval-after-load 'evil
    (dolist (map (list evil-normal-state-map
                       evil-insert-state-map
                       evil-visual-state-map
                       evil-motion-state-map
                       evil-emacs-state-map))
      (pcase-dolist (`(,key . ,fn) screenshot-keys)
        (define-key map key fn)))))

(with-eval-after-load 'ewm-input
  ;; ewm-input loads before the Wayland socket exists; delay so WAYLAND_DISPLAY is set
  (run-with-timer 1 nil #'my/start-cliphist-when-ready)

  ;; Clipboard: C-x y y/d/w — единый стиль для ewm-окон
  (define-key ewm-mode-map (kbd "C-x y y") #'my/cliphist-pick)
  (define-key ewm-mode-map (kbd "C-x y d") #'my/cliphist-delete)
  (define-key ewm-mode-map (kbd "C-x y w") #'my/cliphist-clear)

  ;; Screenshots — те же функции что и в global-set-key выше
  (define-key ewm-mode-map (kbd "<Print>")     #'my/screenshot-area-to-clipboard)
  (define-key ewm-mode-map (kbd "s-<Print>")   #'my/screenshot-area-to-file)
  (define-key ewm-mode-map (kbd "S-<Print>")   #'my/screenshot-full-to-clipboard)
  (define-key ewm-mode-map (kbd "s-S-<Print>") #'my/screenshot-full-to-file)

  ;; Window resize — зеркалим evil-normal-state биндинги для ewm-mode
  (define-key ewm-mode-map (kbd "<C-up>")
    (lambda () (interactive) (evil-window-increase-height 2)))
  (define-key ewm-mode-map (kbd "<C-down>")
    (lambda () (interactive) (evil-window-decrease-height 2)))
  (define-key ewm-mode-map (kbd "<C-left>")
    (lambda () (interactive) (evil-window-decrease-width 2)))
  (define-key ewm-mode-map (kbd "<C-right>")
    (lambda () (interactive) (evil-window-increase-width 2))))

;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
;; org-download (вставка изображений из буфера обмена)
;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
(use-package org-download
  :defer t
  :after org
  :config
  (setq org-download-method 'directory
        org-download-image-dir "~/Pictures/org"))

(defun my/paste-clipboard-image ()
  "Paste image from clipboard via org-download (works in any buffer)."
  (interactive)
  (require 'org-download)
  (org-download-clipboard))

;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
;; Display output control via ewm-configure-output (native EWM API).
;; wlr-randr reports outputs correctly but cannot change modes in EWM —
;; use ewm-configure-output from ewm.el instead.
;; Connector names auto-detected from ewm--output-info.
;; IMPORTANT: enable external first, then disable built-in.
;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
(defun my/ewm-connector (prefix)
  "Return the first connector name from ewm--output-info starting with PREFIX."
  (when (and (boundp 'ewm--output-info) ewm--output-info)
    (car (seq-find (lambda (entry)
                     (string-prefix-p prefix (car entry)))
                   ewm--output-info))))

(defun my/list-outputs ()
  "Show all outputs EWM currently knows about."
  (interactive)
  (if (and (boundp 'ewm--output-info) ewm--output-info)
      (message "EWM outputs: %s" (mapconcat #'car ewm--output-info ", "))
    (message "ewm--output-info is empty — compositor not running?")))

(defun my/enable-edp1 ()
  "Enable built-in eDP display: restore backlight + ewm-configure-output."
  (interactive)
  (if-let ((conn (my/ewm-connector "eDP")))
      (progn
        (shell-command-to-string
         "brightnessctl --restore --device=intel_backlight 2>/dev/null")
        (ewm-configure-output conn :enabled t)
        (message "eDP-1 enabled"))
    (message "No eDP connector — M-x my/list-outputs")))

(defun my/disable-edp1 ()
  "Disable built-in eDP display: ewm-configure-output + backlight to 0."
  (interactive)
  (if-let ((conn (my/ewm-connector "eDP")))
      (progn
        (ewm-configure-output conn :enabled nil)
        (shell-command-to-string
         "brightnessctl --save --device=intel_backlight set 0 2>/dev/null")
        (message "eDP-1 disabled"))
    (message "No eDP connector — M-x my/list-outputs")))

(defun my/enable-dp2 ()
  "Enable external DP-2 display at 2560x1080@100Hz."
  (interactive)
  (if-let ((conn (my/ewm-connector "DP-2")))
      (progn
        (ewm-configure-output conn :width 2560 :height 1080 :refresh 100 :enabled t)
        (message "%s enabled at 2560x1080@100Hz" conn))
    (message "No DP-2 connector — M-x my/list-outputs")))

(defun my/disable-dp2 ()
  "Disable external DP-2 display."
  (interactive)
  (if-let ((conn (my/ewm-connector "DP-2")))
      (progn
        (ewm-configure-output conn :enabled nil)
        (message "%s disabled" conn))
    (message "No DP-2 connector — M-x my/list-outputs")))

(defun my/enable-dp1 ()
  "Enable external DP-1 display with preferred mode."
  (interactive)
  (if-let ((conn (my/ewm-connector "DP-1")))
      (progn
        (ewm-configure-output conn :enabled t)
        (message "%s enabled" conn))
    (message "No DP-1 connector — M-x my/list-outputs")))

(defun my/disable-dp1 ()
  "Disable external DP-1 display."
  (interactive)
  (if-let ((conn (my/ewm-connector "DP-1")))
      (progn
        (ewm-configure-output conn :enabled nil)
        (message "%s disabled" conn))
    (message "No DP-1 connector — M-x my/list-outputs")))


(provide 'init)
;;; init.el ends here
