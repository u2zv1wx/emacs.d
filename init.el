(defmacro use (package)
  `(unless (package-installed-p ',package)
     (package-install ',package)))
(defmacro with-hook (hook &rest body)
  (declare (indent defun))
  `(add-hook ',hook (lambda () (interactive) ,@body)))
(defmacro bind-action* (key &rest body)
  (declare (indent defun))
  `(bind-key* ,key (lambda () (interactive) ,@body)))

(setq-default buffer-file-coding-system 'utf-8-unix)
(setq-default default-buffer-file-coding-system 'utf-8-unix)
(set-default-coding-systems 'utf-8-unix)
(set-keyboard-coding-system 'utf-8-unix)
(set-terminal-coding-system 'utf-8-unix)
(prefer-coding-system 'utf-8-unix)
(add-to-list 'initial-frame-alist '(fullscreen . maximized))

(setq-default mode-line-format nil)
(setq-default frame-title-format '("%f - Emacs"))
(setq-default bidi-display-reordering nil)
(add-to-list 'load-path "~/.emacs.d/site-lisp")

(when (eq (window-system) 'ns)
  (add-to-list 'default-frame-alist '(ns-transparent-titlebar . nil))
  (set-face-attribute 'default nil :family "Menlo" :height 105)
  (set-fontset-font t 'japanese-jisx0208 (font-spec :family "Hiragino Kaku Gothic ProN"))
  (set-fontset-font t '(#x0080 . #x03ff) (font-spec :family "Menlo")))

(when (eq (window-system) 'x)
  (set-face-attribute 'default nil :family "Source Code Pro" :height 100)
  (set-fontset-font t 'japanese-jisx0208 (font-spec :family "Hiragino Kaku Gothic ProN"))
  (set-fontset-font t '(#x0080 . #x03ff) (font-spec :family "Source Code Pro"))
  )

(setq custom-file (locate-user-emacs-file "custom.el"))
(load custom-file)

(with-hook prog-mode-hook
  (display-line-numbers-mode 1)
  (setq show-trailing-whitespace t))

(with-hook text-mode-hook
  (display-line-numbers-mode 1)
  (setq show-trailing-whitespace t))

(when (or (eq (window-system) 'ns) (eq (window-system) 'x))
  (let* ((path (shell-command-to-string "$SHELL --login -i -c 'echo $PATH'"))
         (path-from-shell (replace-regexp-in-string "[ \t\n]*$" "" path)))
    (setenv "PATH" path-from-shell)
    (setq exec-path (split-string path-from-shell path-separator))))

(require 'package)
(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

(use bind-key)

;; (use paredit)
;; (add-hook 'lisp-mode-hook 'paredit-mode)
;; (add-hook 'emacs-lisp-mode-hook 'paredit-mode)
;; (add-hook 'scheme-mode-hook 'paredit-mode)
;; (with-hook lisp-mode-hook
;;   (defun reverse-transpose-sexps ()
;;     (interactive)
;;     (transpose-sexps -1))
;;   (bind-key "C-S-<right>" 'transpose-sexps lisp-mode-map)
;;   (bind-key "C-S-<left>" 'reverse-transpose-sexps lisp-mode-map)
;;   (bind-key "M-F" 'transpose-sexps lisp-mode-map)
;;   (bind-key "M-B" 'reverse-transpose-sexps lisp-mode-map))

(use flycheck)
(use flycheck-posframe)
(global-flycheck-mode 1)
(bind-key* "M-n" 'flycheck-next-error)
(bind-key* "M-p" 'flycheck-previous-error)
(with-eval-after-load 'flycheck
  (require 'flycheck-posframe)
  (add-hook 'flycheck-mode-hook #'flycheck-posframe-mode))

(use company)
(require 'company)
(add-hook 'after-init-hook 'global-company-mode)
(bind-key "C-n" 'company-select-next company-active-map)
(bind-key "C-p" 'company-select-previous company-active-map)
(with-hook text-mode-hook
  (company-mode -1))

(use company-box)
(add-hook 'company-mode-hook 'company-box-mode)

(use spacemacs-theme)
(load-theme 'spacemacs-light t)

;; (use modus-themes)
;; (load-theme 'modus-vivendi t)

(use spaceline)
(require 'spaceline-segments)

(spaceline-compile
  `(((buffer-modified buffer-size))
    ,(propertize "%f" 'face 'bold)
    ((flycheck-error flycheck-warning flycheck-info))
    remote-host
    buffer-encoding)
  nil)
(setq-default mode-line-format '("%e" (:eval (spaceline-ml-main))))

(use posframe)

(use haskell-mode)
(use dante)
(with-hook haskell-mode-hook
  (dante-mode)
  (flycheck-add-next-checker 'haskell-dante '(info . haskell-hlint)))

(use undo-fu)
(bind-key* "C-/" 'undo-fu-only-undo)
(bind-key* "C-?" 'undo-fu-only-redo)
(bind-key* "C-z" 'undo-fu-only-undo)
(bind-key* "C-S-z" 'undo-fu-only-redo)

(use multiple-cursors)
(bind-key* "C->" 'mc/mark-next-like-this)
(bind-key* "C-<" 'mc/mark-previous-like-this)

(use magit)
(bind-key* "M-g" 'magit-status)

(use git-gutter)

(use org)
(require 'org)

;; (with-eval-after-load 'org
;;   (eval-when-compile (require 'org))
;;   (eval-when-compile (require 'ox))
;;   ;; (defun org-insert-todo-heading-at-top (arg)
;;   ;;   (interactive "P")
;;   ;;   (goto-char (point-min))
;;   ;;   (org-insert-todo-heading arg))
;;   ;; (bind-key "M-l" 'org-goto org-mode-map)
;;   (bind-key "<S-return>" 'org-insert-todo-heading org-mode-map)
;;   (bind-key "<M-S-return>" 'org-insert-todo-heading-at-top org-mode-map)
;;   ;; (bind-action* "C-c C-d"
;;   ;;   (org-todo "DONE")
;;   ;;   (save-buffer))
;;   ;; (bind-key "C-c C-a" 'org-archive-subtree org-mode-map)
;;   (bind-key "C-c C-r" 'org-clock-report org-mode-map)
;;   ;; (bind-key "C-c C-k" 'org-archive-subtree org-mode-map)
;;   )

;; (use org-make-toc)

(use toc-org)
(add-hook 'org-mode-hook 'toc-org-mode)

(defun org-make-toc--tree-to-ordered-list (tree)
  "Return list string for TOC TREE."
  (cl-labels ((tree (tree depth)
                    (when (> (length tree) 0)
                      (when-let* ((entries (->> (append (when (car tree)
                                                          (list (concat (s-repeat depth "  ") "1. " (car tree))))
                                                        (--map (tree it (1+ depth)) (cdr tree)))
                                                -non-nil -flatten)))
                        (s-join "\n" entries)))))
    (->> tree
         (--map (tree it 0))
         -flatten (s-join "\n"))))

(advice-add 'org-make-toc--tree-to-list :override 'org-make-toc--tree-to-ordered-list)

(defvar org-archive-subtree-save-file-p)
(setq org-archive-subtree-save-file-p t)

(when (eq (window-system) 'x)
  (use ddskk)
  (load (locate-user-emacs-file "ddskk.el"))
  (setq skk-large-jisyo "~/.emacs.d/skk/dictionary.txt")
  (defun skk-convert-to-katakana (arg)
    (interactive "P")
    (skk-henkan-skk-region-by-func #'skk-katakana-region t))
  (defun enable-skk-mode ()
    (interactive)
    (skk-mode 1))
  (defun disable-skk-mode ()
    (interactive)
    (skk-mode -1))
  (bind-key* "<muhenkan>" 'disable-skk-mode)
  (bind-key* "<henkan>" 'enable-skk-mode))

(use helm)
(helm-mode 1)
(bind-key* "M-x" 'helm-M-x)
(bind-key* "C-x C-b" 'helm-mini)
(bind-key* "C-x C-f" 'helm-find-files)

(use treemacs)
(with-hook treemacs-mode-hook
  (treemacs-follow-mode -1))
(use treemacs-magit)

(use helm-ag)
(bind-key* "M-s" 'helm-ag)

(use ctrlf)
(ctrlf-mode 1)

(use yaml-mode)
(add-to-list 'auto-mode-alist '("\\.yaml$" . yaml-mode))

(use yasnippet)

(require 'org-note)
(bind-key* "C-c C-j" 'org-note-new-entry)
(bind-key* "C-x C-n" 'org-note-new-entry-in-current-buffer)
(bind-key* "M-)" 'org-note-open-next-entry org-mode-map)
(bind-key "M-(" 'org-note-open-previous-entry org-mode-map)
(bind-key "M-s" 'helm-ag org-mode-map)

(autoload 'neut-mode "neut-mode" nil t)
(require 'neut-mode)
(autoload 'flycheck-neut "flycheck-neut" nil t)
(require 'flycheck-neut)
(add-to-list 'auto-mode-alist '("\\.neut$" . neut-mode))
(with-hook neut-mode-hook
  (add-to-list 'flycheck-checkers 'neut)
  (make-local-variable 'company-backends)
  (push '(company-yasnippet company-dabbrev) company-backends))

(autoload 'llvm-mode "llvm-mode" nil t)
(add-to-list 'auto-mode-alist '("\\.ll$" . llvm-mode))

(bind-action* "C-'"
  (switch-to-buffer (other-buffer (current-buffer) 1)))

(bind-action* "C-S-i"
  (let ((l (number-to-string (line-number-at-pos)))
        (c (number-to-string (+ 1 (current-column)))))
    (message (concat "(" l " . " c ")"))))

(with-hook before-save-hook
  (delete-trailing-whitespace))

(bind-key* "<f10>" 'customize-face)
(bind-key* "<f11>" 'toggle-frame-fullscreen)
(bind-key* "<f12>" 'customize-variable)

(bind-action* "C-<tab>" (other-window +1))
(bind-action* "<C-S-iso-lefttab>" (other-window -1))
(bind-key* "C-. C-." 'delete-other-windows)
(bind-key* "C-," 'delete-window)
(bind-key* "C-x |" 'split-window-horizontally)
(bind-key* "C-x -" 'split-window-vertically)

(bind-key* "C-o C-a" 'align-regexp)
(bind-key* "C-o C-g" 'goto-line)
(bind-key* "C-o C-r" 'replace-string)
(bind-key* "M-SPC" 'rectangle-mark-mode)
(bind-action* "C-o C-j" (delete-indentation t))
(bind-key* "C-o C-s" 'sort-lines)

(unbind-key "C-x C--")
(unbind-key "C-x C-z")

(require 'server)
(unless (server-running-p)
  (server-start))

(define-fringe-bitmap 'right-curly-arrow [])
(define-fringe-bitmap 'left-curly-arrow [])

(treemacs)
(other-window 1)
