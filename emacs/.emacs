;;; package --- Summary - Bob Wheeler's dot emacs file bob.wheeler@acm.org
;;; Commentary:
;;; basic startup file

;; Code:

;; -*- mode: emacs-lisp -*-

(message "---------------- loading .emacs ---------------------")
;; Who are we?

(setq user-full-name "Bob Wheeler"
      user-mail-address "bob.wheeler@acm.com")

(if (equal (getenv "USER") "root")
    (setq home-directory (concat "/home/" (getenv "SUDO_USER")))
  (setq home-directory (concat "/home/" (getenv "USER"))))

(message "The value of home-directory is %s\n" home-directory)

(message "---------------- loading package ---------------------")

;; Set up packages
(require 'package)
(setq package-enable-at-startup nil)
(setq package-user-dir (concat home-directory "/.emacs.d/elpa/"))
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/") t)
(package-initialize)

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

;;(eval-when-compile
;;  (require 'use-package))

(add-to-list 'load-path (concat home-directory "/.emacs.d/lisp"))

(message "---------------- loading keymaps ---------------------")

;; Set up the keyboard so the delete key on both the regular keyboard
;; and the keypad delete the character under the cursor and to the right
;; under X, instead of the default, backspace behavior.
(global-set-key [delete] 'delete-char)
(global-set-key [kp-delete] 'delete-char)

(global-set-key [f1]  'goto-line)
(global-set-key [f2]  'query-replace)
(global-set-key [f3]  'compile)
(global-set-key [f4]  'gdb)
(global-set-key [f5]  'shell)
(global-set-key [f6]  'indent-region)
(global-set-key [f7]  'comment-region)
(global-set-key [f8]  'uncomment-region)
(global-set-key [f9]  'lsp-find-definition)
(global-set-key [f10] 'lsp-find-references)
(global-set-key [f12] 'undo)
(global-set-key [?\C-c ?\C- ] 'gud-break)

(message "---------------- loading look and feel ---------------------")


(defalias 'yes-or-no-p 'y-or-n-p)		  ; query y/n instead of yes/no
(setq compile-command "fastbuild")	  ; set compile command to make in current repo
(setq gdb-command-name "sudo gdb --pid=")
(column-number-mode t)				  ; show column in mode line
(show-paren-mode t)
(setq show-paren-delay 0)
(setq blink-matching-paren t)			  ; blink matching parantheses
(setq doc-view-continuous t)			  ; enable C-p,C-n,C-b and C-f past current page
(setq-default transient-mark-mode t)		  ; enable visual feedback on selections
(setq require-final-newline t)			  ; always end a file with a newline
(setq next-line-add-newlines nil)		  ; stop at the end of the file, not just add lines
(setq auto-save-timeout 30)			  ; save file after 30 seconds in #filename#
(setq make-backup-files t)			  ; make backup file after first save in filename~
(autoload 'display-time "time" "Display Time" t)  ; autoload display-time to update each minute
(condition-case err				  ; catch errors is display-time is not loaded
    (display-time)
  (error (message "Unable to load Time package.")))
(setq display-time-24hr-format nil)		  ; display 12 hour format with AM/PM
(setq display-time-day-and-date t)		  ; display date & time
(add-hook 'before-save-hook 'whitespace-cleanup)  ; cleanup trailing white space before saving
;; (require 'clang-format)				  ; Setup clang formatting

; Colorize compilation buffer
(ignore-errors
  (require 'ansi-color)
  (defun my-colorize-compilation-buffer ()
    (when (eq major-mode 'compilation-mode)
      (ansi-color-apply-on-region compilation-filter-start (point-max))))
  (add-hook 'compilation-filter-hook 'my-colorize-compilation-buffer))


(message "---------------- Loading smartparens ---------------- ")

(use-package smartparens
  :ensure t
  :diminish smartparens-mode
  :config
  (progn
    (require 'smartparens-config)
    (smartparens-global-mode 1)
    (show-paren-mode t)))

(message "---------------- Loading which-keys ---------------- ")

(use-package which-key
  :ensure t
  :diminish which-key-mode
  :config
  (which-key-mode +1))

(message "---------------- Loading bookmarks ---------------- ")
;; (load "bookmark-add")
;; (if (getenv "REPOROOT")
;;     (setq bookmark-file (concat (getenv "REPOROOT") "/bookmarks")))

(message "---------------- Loading autocomplete and syntax checking ---------------- ")
(use-package company
  :ensure t
  :diminish company-mode
  :config
  (add-hook 'after-init-hook #'global-company-mode))

;; (use-package flycheck
;;   :ensure t
;;   :diminish flycheck-mode
;;   :config
;;   (add-hook 'after-init-hook #'global-flycheck-mode))

(message "---------------- loading magit ---------------------")
(use-package magit
  :bind (("C-M-g" . magit-status)))		  ; trigger a git status buffer for current file

(message "---------------- loading projectile ---------------------")
(use-package projectile
  :ensure t
  :diminish projectile-mode
  :bind
  (("C-c p f" . helm-projectile-find-file)
   ("C-c p p" . helm-projectile-switch-project)
   ("C-c p s" . projectile-save-project-buffers))
  :config
  (projectile-mode +1)
  )

(message "---------------- loading Helm ---------------------")
(use-package helm
  :ensure t
  :defer 2
  :bind
  ("M-x" . helm-M-x)
  ("C-x C-f" . helm-find-files)
  ("M-y" . helm-show-kill-ring)
  ("C-x b" . helm-mini)
  :config
  (require 'helm-config)
  (helm-mode 1)
  (setq helm-split-window-inside-p t
    helm-move-to-line-cycle-in-source t)
  (setq helm-autoresize-max-height 0)
  (setq helm-autoresize-min-height 20)
  (helm-autoresize-mode 1)
  (define-key helm-map (kbd "<tab>") 'helm-execute-persistent-action) ; rebind tab to run persistent action
  (define-key helm-map (kbd "C-i") 'helm-execute-persistent-action) ; make TAB work in terminal
  (define-key helm-map (kbd "C-z")  'helm-select-action) ; list actions using C-z
  )

(use-package helm-projectile
  :ensure t
  :config
  (helm-projectile-on))

;; (message "---------------- loading Daemon mode ---------------------")
;; (require 'server)
;; (if (not (server-running-p)) (server-start))

(use-package lsp-mode
  :init
  ;; set prefix for lsp-command-keymap (few alternatives - "C-l", "C-c l")
  (setq lsp-keymap-prefix "C-c l")
  :hook (;; replace XXX-mode with concrete major-mode(e. g. python-mode)
	 (c++-mode . lsp)
	 (c-mode . lsp)
	 (js-mode . lsp)
	 ;; if you want which-key integration
	 (lsp-mode . lsp-enable-which-key-integration))
  :commands lsp :ensure t)

(use-package lsp-ui :commands lsp-ui-mode :ensure t)

(message "---------------- loading language bindings ---------------------")
;; Setup language modes
(autoload 'c++-mode           "cc-mode" "C++ Editing Mode" t)
(autoload 'c-mode             "cc-mode" "C Editing Mode" t)
(autoload 'c-mode-common-hook "cc-mode" "C Mode Hooks" t)
(autoload 'c-add-style        "cc-mode" "Add coding style" t)
(autoload 'q-mode             "q-mode"  "Add q/kdb+ coding style" t)
;; (autoload 'protobuf-mode      "protobuf-mode"  "Add protobuf coding style" t)


;; Associate extensions with modes
(add-to-list 'auto-mode-alist '("\\.h$" . c-mode))
(add-to-list 'auto-mode-alist '("\\.gdb$" . gdb-script-mode))
(add-to-list 'auto-mode-alist '("\\.[kq]\\'" . q-mode))
;; (add-to-list 'auto-mode-alist '("\\.proto\\'" . protobuf-mode))

(add-hook 'emacs-lisp-mode-hook (lambda () (setq comment-column 50)))
(add-hook 'c-mode-hook (lambda ()
	     (local-set-key (kbd "<f6>") 'clang-format-region)
	     (local-set-key (kbd "<tab>") 'clang-format-region)
	     (setq c-basic-offset 2)
	     (setq comment-column 50)
	     (setq compile-command "fastbuild")
	     (setq gud-gdb-command-name "gdb -i=mi")))
(add-hook 'c++-mode-hook (lambda ()
	       (local-set-key (kbd "<f6>") 'clang-format-region)
	       (local-set-key (kbd "<tab>") 'clang-format-region)
	       (setq c-basic-offset 2)
	       (setq comment-column 50)
	       (setq compile-command "fastbuild")
	       (setq gud-gdb-command-name "gdb -i=mi")
	       (indent-tabs-mode . nil)))
(add-hook 'asm-mode-hook (lambda () (setq comment-column 115)))

(add-hook 'js-mode-hook (lambda ()
	      (setq compile-command ". ~/.bashrc; runatf")
	      (setq gud-gdb-command-name "sudo gdb -i=mi --pid=")))

;; (require 'protobuf-mode)


(defconst my-protobuf-style
    '((c-basic-offset . 8)
      (indent-tabs-mode . nil)))
  (add-hook 'protobuf-mode-hook
    (lambda () (c-add-style "my-style" my-protobuf-style t)))

(setq load-home-init-file t) ; don't load init file from ~/.xemacs/init.el


(message "---------------- Loading ps2pdf ---------------- ")

(require 'ps-print)
(when (executable-find "ps2pdf")
  (defun modi/pdf-print-buffer-with-faces (&optional filename)
    "Print file in the current buffer as pdf, including font, color, and
underline information.  This command works only if you are using a window system,
so it has a way to determine color values.

C-u COMMAND prompts user where to save the Postscript file (which is then
converted to PDF at the same location."
    (interactive (list (if current-prefix-arg
	   (ps-print-preprint 4)
	 (concat (file-name-sans-extension (buffer-file-name))
	 ".ps"))))
    (ps-print-with-faces (point-min) (point-max) filename)
    (shell-command (concat "ps2pdf " filename))
    (delete-file filename)
    (message "Deleted %s" filename)
    (message "Wrote %s" (concat (file-name-sans-extension filename) ".pdf"))))

(message "---------------- Loading custom-set-variables ---------------- ")

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-for-comint-mode t)
 '(auto-compression-mode t nil (jka-compr))
 '(c-doc-comment-style
   '((c++-mode . javadoc)
     (java-mode . javadoc)
     (pike-mode . autodoc)))
 '(case-fold-search t)
 '(column-number-mode t)
 '(current-language-environment "UTF-8")
 '(dabbrev-case-distinction nil)
 '(dabbrev-case-fold-search t)
 '(dabbrev-case-replace 'case-replace)
 '(default-frame-alist
    '((foreground-color . "gray60")
      (background-color . "#000000")
      (background-mode . dark)
      (cursor-color . "red3")
      (tool-bar-lines . 1)
      (menu-bar-lines . 1)))
 '(default-input-method "rfc1345")
 '(display-time-mode t)
 '(doxymacs-doxygen-style "JavaDoc")
 '(fill-column 139)
 '(global-font-lock-mode t nil (font-lock))
 '(inhibit-startup-screen t)
 '(js-indent-level 2)
 '(lsp-server-install-dir "/snap/bin/clangd")
 '(package-selected-packages
   '(cmake-mode company-lsp magit company-box projectile clang-format+ dap-mode bind-key clang-format flycheck-clang-analyzer flycheck-clangcheck lsp-ivy lsp-treemacs flycheck lsp-ui markdown-mode lsp-mode smartparens cmake-ide dash js2-mode))
 '(pr-auto-mode nil)
 '(pr-file-duplex t)
 '(q-indent-step 4)
 '(safe-local-variable-values
   '((cmake-ide-build-dir . "../build")
     (cmake-ide-cmake-args "-DCMAKE_EXPORT_COMPILE_COMMANDS=1")))
 '(scroll-bar-mode nil)
 '(undo-outer-limit 15000000)
 '(user-mail-address "bob.wheeler@acm.com")
 '(warning-suppress-log-types '((use-package) (use-package)))
 '(warning-suppress-types '((comp) (use-package))))


(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:inherit nil :stipple nil :background "#000000" :foreground "gray60" :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight normal :height 180 :width normal :foundry "nil" :family "Courier New"))))
 '(c-annotation-face ((t (:inherit font-lock-constant-face :foreground "yellow"))))
 '(cpp-font-lock-literal-face ((((class color)) (:foreground "gray60"))))
 '(cpp-font-lock-preprocessor-face ((((class color)) (:foreground "light sky blue"))))
 '(cpp-font-lock-type-name-face ((((class color)) (:foreground "Sienna3"))))
 '(font-lock-builtin-face ((t (:foreground "light slate blue"))))
 '(font-lock-comment-delimiter-face ((t (:inherit font-lock-comment-face :foreground "yellow"))))
 '(font-lock-comment-face ((t (:foreground "yellow"))))
 '(font-lock-constant-face ((t (:foreground "deep pink"))))
 '(font-lock-doc-face ((((class color)) (:foreground "red"))))
 '(font-lock-function-name-face ((t (:foreground "dark orange"))))
 '(font-lock-keyword-face ((t (:foreground "cyan"))))
 '(font-lock-negation-char-face ((t nil)))
 '(font-lock-preprocessor-face ((t (:foreground "light slate blue"))))
 '(font-lock-reference-face ((((class color)) (:foreground "gray60"))))
 '(font-lock-string-face ((((class color)) (:foreground "green"))))
 '(font-lock-type-face ((t (:foreground "dark violet"))))
 '(font-lock-variable-name-face ((t (:foreground "deep sky blue"))))
 '(font-lock-warning-face ((t (:foreground "red"))))
 '(q-font-lock-builtin-face ((t (:foreground "#FF6321"))))
 '(q-font-lock-constant-face ((t (:foreground "#FFCB25"))))
 '(q-font-lock-function-name-face ((t (:foreground "magenta"))))
 '(q-font-lock-keyword-face ((t (:foreground "#84E571"))))
 '(q-font-lock-math-face ((t (:foreground "blue"))))
 '(q-font-lock-preprocessor-face ((t (:foreground "#46FD59"))))
 '(q-font-lock-stupid-face ((t (:background "orange" :foreground "yellow"))))
 '(q-font-lock-type-face ((t (:foreground "#C2FD9D"))))
 '(q-font-lock-variable-name-face ((t (:foreground "#3E97F7"))))
 '(q-font-lock-warning-face ((t (:foreground "red"))))
 '(smerge-mine ((t (:background "#110000"))))
 '(smerge-refined-added ((t (:inherit smerge-refined-change :background "#001100")))))

(message "---------------- .emacs loaded ---------------- ")
