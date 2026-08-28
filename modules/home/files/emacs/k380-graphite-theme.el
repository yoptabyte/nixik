;;; k380-graphite-theme.el --- Warm dark theme with gold accents  -*- lexical-binding: t; -*-

;; Copyright (C) 2024

;; Author: yoptabyte
;; Keywords: themes

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; K380 Graphite — warm dark theme matching the nixvim configuration.
;; Background: #28261F (transparent for Ghostty)
;; Foreground: #C8C8C0
;; Accent:     #F0C040 (gold)
;; Secondary:  #E8A020 (amber)
;; Green:      #A8D8A0 (sage)
;; Muted:      #888882 / #5A5848 / #48463A

;;; Code:

(deftheme k380-graphite
  "Warm dark theme with gold accents.  Designed for Ghostty terminal transparency.")

(let ((bg          "#28261F")
      (bg-alt      "#302E26")
      (bg-dark     "#201E18")
      (fg          "#C8C8C0")
      (fg-muted    "#888882")
      (accent      "#F0C040")
      (secondary   "#E8A020")
      (green       "#A8D8A0")
      (comment     "#5A5848")
      (linum       "#48463A")
      (border      "#3D3B30"))

  (custom-theme-set-faces
   'k380-graphite

   ;; ── Base ──────────────────────────────────────────
   `(default                          ((t (:foreground ,fg :background ,bg))))
   `(cursor                           ((t (:foreground ,bg :background ,accent))))
   `(region                           ((t (:background ,border))))
   `(highlight                        ((t (:background ,bg-alt))))
   `(hl-line                          ((t (:background ,bg-alt))))
   `(fringe                           ((t (:background ,bg))))
   `(line-number                      ((t (:foreground ,linum))))
   `(line-number-current-line         ((t (:foreground ,accent :bold t))))
   `(linum                            ((t (:foreground ,linum))))
   `(show-paren-match                 ((t (:foreground ,bg :background ,accent :bold t))))
   `(show-paren-mismatch             ((t (:foreground ,bg :background ,secondary :bold t))))
   `(minibuffer-prompt                ((t (:foreground ,accent :bold t))))
   `(link                             ((t (:foreground ,accent :underline t))))
   `(link-visited                     ((t (:foreground ,secondary :underline t))))
   `(match                            ((t (:foreground ,bg :background ,accent))))
   `(tooltip                          ((t (:foreground ,fg :background ,bg-alt))))
   `(success                          ((t (:foreground ,green))))
   `(error                            ((t (:foreground ,secondary))))
   `(warning                          ((t (:foreground ,accent))))
   `(info                             ((t (:foreground ,green))))
   `(separator-line                   ((t (:background ,border))))

   ;; ── Font-lock ─────────────────────────────────────
   `(font-lock-comment-face           ((t (:foreground ,comment :italic t))))
   `(font-lock-comment-delimiter-face ((t (:foreground ,comment))))
   `(font-lock-keyword-face           ((t (:foreground ,accent))))
   `(font-lock-string-face            ((t (:foreground ,secondary))))
   `(font-lock-constant-face          ((t (:foreground ,secondary))))
   `(font-lock-function-name-face     ((t (:foreground ,green))))
   `(font-lock-type-face              ((t (:foreground ,green))))
   `(font-lock-variable-name-face     ((t (:foreground ,fg))))
   `(font-lock-builtin-face          ((t (:foreground ,accent))))
   `(font-lock-preprocessor-face      ((t (:foreground ,accent))))
   `(font-lock-number-face            ((t (:foreground ,secondary))))
   `(font-lock-warning-face          ((t (:foreground ,secondary))))
   `(font-lock-doc-face               ((t (:foreground ,fg-muted :italic t))))
   `(font-lock-doc-markup-face        ((t (:foreground ,fg-muted :italic t))))
   `(font-lock-escape-face            ((t (:foreground ,accent))))
   `(font-lock-negation-char-face     ((t (:foreground ,accent :bold t))))
   `(font-lock-operator-face          ((t (:foreground ,fg))))

   ;; ── Mode line ─────────────────────────────────────
   `(mode-line                         ((t (:foreground ,fg :background ,bg-dark :box nil :height 110))))
   `(mode-line-inactive               ((t (:foreground ,fg-muted :background ,bg-alt :box nil :height 110))))
   `(mode-line-highlight              ((t (:foreground ,accent :bold t))))
   `(mode-line-buffer-id              ((t (:foreground ,accent :bold t))))
   `(mode-line-emacs                  ((t (:foreground ,fg-muted))))
   `(doom-modeline-bar                ((t (:background ,accent))))
   `(doom-modeline-bar-inactive       ((t (:background ,border))))
   `(doom-modeline-buffer-path        ((t (:foreground ,fg-muted))))
   `(doom-modeline-buffer-modified    ((t (:foreground ,secondary :bold t))))
   `(doom-modeline-project-dir        ((t (:foreground ,green))))
   `(doom-modeline-urgent             ((t (:foreground ,secondary))))
   `(doom-modeline-info               ((t (:foreground ,green))))
   `(doom-modeline-warning            ((t (:foreground ,accent))))
   `(doom-modeline-error              ((t (:foreground ,secondary))))
   `(doom-modeline-buffer-file-name   ((t (:foreground ,fg :bold t))))
   `(doom-modeline-major-mode         ((t (:foreground ,green))))
   `(doom-modeline-minor-mode         ((t (:foreground ,fg-muted))))
   `(doom-modeline-position           ((t (:foreground ,accent :bold t))))
   `(doom-modeline-line-column        ((t (:foreground ,fg-muted))))
   `(doom-modeline-lsp                ((t (:foreground ,fg-muted))))
   `(doom-modeline-buffer-encoding    ((t (:foreground ,fg-muted))))
   `(doom-modeline-buffer-status      ((t (:foreground ,green))))

   ;; ── Search ────────────────────────────────────────
   `(isearch                          ((t (:foreground ,bg :background ,accent :bold t))))
   `(isearch-fail                     ((t (:foreground ,secondary :background ,bg :italic t))))
   `(lazy-highlight                   ((t (:foreground ,bg :background ,secondary))))
   `(query-replace                    ((t (:foreground ,bg :background ,secondary))))

   ;; ── Completions ───────────────────────────────────
   `(completions-common-part          ((t (:foreground ,accent))))
   `(completions-first-difference     ((t (:foreground ,fg :bold t))))

   ;; ── Vertico ───────────────────────────────────────
   `(vertico-current                  ((t (:foreground ,bg :background ,accent :bold t))))
   `(vertico-group-title              ((t (:foreground ,fg-muted :italic t))))
   `(vertico-group-separator          ((t (:foreground ,border))))

   ;; ── Orderless ─────────────────────────────────────
   `(orderless-match-face-0           ((t (:foreground ,accent :bold t))))
   `(orderless-match-face-1           ((t (:foreground ,green :bold t))))
   `(orderless-match-face-2           ((t (:foreground ,secondary :bold t))))
   `(orderless-match-face-3           ((t (:foreground ,fg :bold t))))

   ;; ── Marginalia ────────────────────────────────────
   `(marginalia-documentation         ((t (:foreground ,fg-muted :italic t))))
   `(marginalia-value                 ((t (:foreground ,secondary))))
   `(marginalia-key                   ((t (:foreground ,accent))))
   `(marginalia-type                  ((t (:foreground ,green))))
   `(marginalia-modified              ((t (:foreground ,secondary))))

   ;; ── Consult ───────────────────────────────────────
   `(consult-line-number              ((t (:foreground ,linum))))
   `(consult-line-number-prefix       ((t (:foreground ,linum))))
   `(consult-line-number-wrs          ((t (:foreground ,accent :bold t))))
   `(consult-async-split              ((t (:foreground ,accent :bold t))))
   `(consult-async-finished           ((t (:foreground ,green))))
   `(consult-async-failed             ((t (:foreground ,secondary))))
   `(consult-grep-context             ((t (:foreground ,fg-muted))))

   ;; ── Which-key ─────────────────────────────────────
   `(which-key-key-face               ((t (:foreground ,accent :bold t))))
   `(which-key-group-description-face ((t (:foreground ,green))))
   `(which-key-command-description-face ((t (:foreground ,fg))))
   `(which-key-separator-face         ((t (:foreground ,fg-muted))))
   `(which-key-special-key-face       ((t (:foreground ,secondary :bold t))))
   `(which-key-highlight-face        ((t (:foreground ,accent))))

   ;; ── Evil ──────────────────────────────────────────
   `(evil-ex-lazy-highlight           ((t (:background ,border))))
   `(evil-ex-search                   ((t (:foreground ,bg :background ,accent :bold t))))
   `(evil-ex-substitute-matches       ((t (:foreground ,secondary :underline t :italic t))))
   `(evil-ex-substitute-replacement    ((t (:foreground ,green :bold t))))

   ;; ── Magit ─────────────────────────────────────────
   `(magit-section-heading            ((t (:foreground ,accent :bold t))))
   `(magit-section-heading-selection   ((t (:foreground ,accent :underline t))))
   `(magit-section-highlight          ((t (:background ,bg-alt))))
   `(magit-diff-file-heading          ((t (:foreground ,fg :bold t))))
   `(magit-diff-file-heading-highlight ((t (:background ,bg-alt))))
   `(magit-diff-hunk-heading          ((t (:foreground ,fg :background ,bg-alt))))
   `(magit-diff-hunk-heading-highlight ((t (:foreground ,accent :background ,bg-alt))))
   `(magit-diff-added                 ((t (:foreground ,green :background ,bg))))
   `(magit-diff-removed               ((t (:foreground ,secondary :background ,bg))))
   `(magit-diff-added-highlight       ((t (:foreground ,green :background ,bg-alt))))
   `(magit-diff-removed-highlight     ((t (:foreground ,secondary :background ,bg-alt))))
   `(magit-diff-context               ((t (:foreground ,fg-muted))))
   `(magit-diff-context-highlight     ((t (:foreground ,fg-muted :background ,bg-alt))))
   `(magit-diffstat-added             ((t (:foreground ,green))))
   `(magit-diffstat-removed           ((t (:foreground ,secondary))))
   `(magit-hash                       ((t (:foreground ,secondary))))
   `(magit-branch-current             ((t (:foreground ,green :bold t :box nil))))
   `(magit-branch-remote              ((t (:foreground ,green))))
   `(magit-branch-local               ((t (:foreground ,accent))))
   `(magit-branch-default             ((t (:foreground ,fg))))
   `(magit-tag                        ((t (:foreground ,secondary))))
   `(magit-refname                    ((t (:foreground ,fg-muted))))
   `(magit-log-author                 ((t (:foreground ,accent))))
   `(magit-log-date                   ((t (:foreground ,fg-muted))))
   `(magit-sequence-head              ((t (:foreground ,green))))
   `(magit-sequence-drop             ((t (:foreground ,secondary))))
   `(magit-sequence-done             ((t (:foreground ,fg-muted))))
   `(magit-sequence-stop             ((t (:foreground ,accent))))

   ;; ── LSP ──────────────────────────────────────────
   `(lsp-face-highlight-textual       ((t (:background ,border))))
   `(lsp-face-highlight-read          ((t (:background ,border :underline t))))
   `(lsp-face-highlight-write         ((t (:background ,bg-alt :bold t))))
   `(lsp-ui-sideline-current          ((t (:foreground ,fg-muted))))
   `(lsp-ui-sideline-code-action      ((t (:foreground ,accent))))
   `(lsp-ui-peek-filename             ((t (:foreground ,fg))))
   `(lsp-ui-peek-line-number          ((t (:foreground ,linum))))
   `(lsp-ui-peek-header               ((t (:foreground ,accent :bold t))))
   `(lsp-ui-peek-peek                  ((t (:background ,bg))))
   `(lsp-ui-peek-highlight             ((t (:foreground ,bg :background ,accent))))
   `(lsp-ui-peek-footer               ((t (:foreground ,fg-muted :background ,bg-dark))))

   ;; ── Dired ─────────────────────────────────────────
   `(dired-directory                  ((t (:foreground ,accent :bold t))))
   `(dired-symlink                    ((t (:foreground ,green))))
   `(dired-mark                       ((t (:foreground ,accent :bold t))))
   `(dired-marked                     ((t (:foreground ,secondary :bold t))))
   `(dired-flagged                    ((t (:foreground ,secondary :italic t))))
   `(dired-header                     ((t (:foreground ,accent :bold t))))
   `(dired-ignored                    ((t (:foreground ,fg-muted))))

   ;; ── Org ───────────────────────────────────────────
   `(org-level-1                      ((t (:foreground ,accent :bold t :height 1.2))))
   `(org-level-2                      ((t (:foreground ,green :bold t))))
   `(org-level-3                      ((t (:foreground ,secondary))))
   `(org-level-4                      ((t (:foreground ,fg))))
   `(org-level-5                      ((t (:foreground ,fg-muted))))
   `(org-todo                         ((t (:foreground ,bg :background ,accent :bold t))))
   `(org-done                         ((t (:foreground ,green :bold t))))
   `(org-headline-done                ((t (:foreground ,fg-muted))))
   `(org-date                         ((t (:foreground ,secondary))))
   `(org-tag                          ((t (:foreground ,fg-muted))))
   `(org-link                         ((t (:foreground ,accent :underline t))))
   `(org-block                        ((t (:background ,bg-alt :foreground ,fg))))
   `(org-block-begin-line             ((t (:background ,bg-alt :foreground ,fg-muted :italic t))))
   `(org-block-end-line               ((t (:background ,bg-alt :foreground ,fg-muted :italic t))))
   `(org-code                         ((t (:foreground ,secondary))))
   `(org-verbatim                     ((t (:foreground ,secondary))))
   `(org-quote                        ((t (:foreground ,fg-muted :italic t))))
   `(org-special-keyword             ((t (:foreground ,accent))))
   `(org-property-value               ((t (:foreground ,fg-muted))))

   ;; ── Diff ──────────────────────────────────────────
   `(diff-added                       ((t (:foreground ,green))))
   `(diff-removed                     ((t (:foreground ,secondary))))
   `(diff-context                     ((t (:foreground ,fg-muted))))
   `(diff-file-header                 ((t (:foreground ,fg :bold t))))
   `(diff-hunk-header                 ((t (:foreground ,accent :background ,bg-alt))))
   `(diff-header                      ((t (:foreground ,fg-muted))))
   `(diff-indicator-added             ((t (:foreground ,green :bold t))))
   `(diff-indicator-removed           ((t (:foreground ,secondary :bold t))))

   ;; ── Term / vterm ──────────────────────────────────
   `(term-color-black                 ((t (:foreground ,bg))))
   `(term-color-red                   ((t (:foreground ,secondary))))
   `(term-color-green                 ((t (:foreground ,green))))
   `(term-color-yellow                ((t (:foreground ,accent))))
   `(term-color-blue                  ((t (:foreground ,fg-muted))))
   `(term-color-magenta              ((t (:foreground ,accent))))
   `(term-color-cyan                  ((t (:foreground ,green))))
   `(term-color-white                 ((t (:foreground ,fg))))
   `(vterm-color-black                ((t (:foreground ,bg))))
   `(vterm-color-red                  ((t (:foreground ,secondary))))
   `(vterm-color-green               ((t (:foreground ,green))))
   `(vterm-color-yellow              ((t (:foreground ,accent))))
   `(vterm-color-blue                 ((t (:foreground ,fg-muted))))
   `(vterm-color-magenta             ((t (:foreground ,accent))))
   `(vterm-color-cyan                 ((t (:foreground ,green))))
   `(vterm-color-white               ((t (:foreground ,fg))))

   ;; ── Tab bar ───────────────────────────────────────
   `(tab-bar                          ((t (:background ,bg :foreground ,fg))))
   `(tab-bar-tab                      ((t (:foreground ,accent :background ,bg-alt :bold t :box (:line-width 1 :color ,border)))))
   `(tab-bar-tab-inactive            ((t (:foreground ,fg-muted :background ,bg))))
   `(tab-bar-background               ((t (:background ,bg))))

   ;; ── Window dividers ──────────────────────────────
   `(window-divider                   ((t (:foreground ,border))))
   `(window-divider-first-pixel       ((t (:foreground ,border))))
   `(window-divider-last-pixel        ((t (:foreground ,border))))

   ;; ── Bookmarks ─────────────────────────────────────
   `(bookmark-face                    ((t (:foreground ,accent))))

   ;; ── Compilation ──────────────────────────────────
   `(compilation-mode-line-run        ((t (:foreground ,accent))))
   `(compilation-mode-line-fail       ((t (:foreground ,secondary))))
   `(compilation-info                 ((t (:foreground ,green))))
   `(compilation-warning             ((t (:foreground ,accent))))
   `(compilation-error               ((t (:foreground ,secondary))))
   `(compilation-line-number         ((t (:foreground ,linum))))
   `(compilation-column-number       ((t (:foreground ,linum))))

   ;; ── Flymake / Flycheck ───────────────────────────
   `(flymake-error                    ((t (:foreground ,secondary :underline t))))
   `(flymake-warning                  ((t (:foreground ,accent :underline t))))
   `(flymake-note                     ((t (:foreground ,green :underline t))))
   `(flycheck-error                   ((t (:foreground ,secondary :underline t))))
   `(flycheck-warning                 ((t (:foreground ,accent :underline t))))
   `(flycheck-info                    ((t (:foreground ,green :underline t))))

   ;; ── Ediff ────────────────────────────────────────
   `(ediff-current-diff-A             ((t (:background ,bg-alt))))
   `(ediff-current-diff-B             ((t (:background ,bg-alt))))
   `(ediff-fine-diff-A                ((t (:background ,border))))
   `(ediff-fine-diff-B               ((t (:background ,border))))
   `(ediff-even-diff-A               ((t (:background ,bg))))
   `(ediff-even-diff-B               ((t (:background ,bg))))
   `(ediff-odd-diff-A                ((t (:background ,bg-alt))))
   `(ediff-odd-diff-B                ((t (:background ,bg-alt))))

   ;; ── Eldoc / Help ─────────────────────────────────
   `(eldoc-highlight-function-argument ((t (:foreground ,accent :underline t))))
   `(help-argument-name               ((t (:foreground ,secondary :italic t))))
   `(help-key-binding                 ((t (:foreground ,accent :bold t))))

   ;; ── Ibuffer ──────────────────────────────────────
   `(ibuffer-marked                   ((t (:foreground ,accent :bold t))))
   `(ibuffer-special-buffer           ((t (:foreground ,fg-muted :italic t))))
   `(ibuffer-locked-buffer            ((t (:foreground ,secondary))))

   ;; ── Misc ─────────────────────────────────────────
   `(trailing-whitespace             ((t (:background ,border))))
   `(escape-glyph                     ((t (:foreground ,accent))))
   `(nobreak-space                    ((t (:foreground ,accent :underline t))))
   `(homoglyph                        ((t (:foreground ,accent))))))

;;;###autoload
(when (and (boundp 'custom-theme-load-path) load-file-name)
  (add-to-list 'custom-theme-load-path
               (file-name-as-directory (file-name-directory load-file-name))))

(provide-theme 'k380-graphite)
(provide 'k380-graphite-theme)
;;; k380-graphite-theme.el ends here