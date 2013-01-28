;; .emacs

(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(current-language-environment "Chinese-GBK")
 '(uniquify-buffer-name-style (quote forward) nil (uniquify)))
(custom-set-faces
  ;; custom-set-faces was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 )

;;; ============================================================
;;; suppose "~/LispBox-0.92/" is your current working directory
;;; ============================================================

(set-language-environment "utf-8")

(add-to-list 'load-path "~/LispBox-0.92/ccl-1.8-darwinx86/")
(add-to-list 'load-path "~/LispBox-0.92/sbcl-1.0.55/")

(add-to-list 'load-path "~/LispBox-0.92/slime-2012-11-13/")
(setq load-path (cons "~/LispBox-0.92/slime-2012-11-13/" load-path))

;(add-to-list 'load-path "~/.emacs.d/slime-2012-11-13/")
;(setq load-path (cons "~/.emacs.d/slime-2012-11-13/" load-path))


(global-font-lock-mode t)

(font-lock-add-keywords 'lisp-mode '("[(]" "[)]"))
(font-lock-add-keywords 'emacs-lisp-mode '("[(]" "[)]"))
(font-lock-add-keywords 'lisp-interaction-mode '("[(]" "[)]"))


(set-cursor-color "white")
(set-mouse-color "blue")
(set-foreground-color "green")
(set-background-color "gray30")
(set-border-color "lightgreen")
(set-face-foreground 'highlight "red")
(set-face-background 'highlight "lightblue")
(set-face-foreground 'region "darkcyan")
(set-face-background 'region "lightblue")
(set-face-foreground 'secondary-selection "skyblue")
(set-face-background 'secondary-selection "darkblue")


(require 'linum)
(setq linum-format "%3d ")
(add-hook 'find-file-hooks (lambda () (linum-mode 1))) 


(add-to-list 'load-path "~/LispBox-0.92/auto-complete-1.3.1/")
(require 'auto-complete-config)
(add-to-list 'ac-dictionary-directories "~/LispBox-0.92/auto-complete-1.3.1/ac-dict")
(ac-config-default)
(add-hook 'lisp-mode-hook
  '(lambda ()
      (define-key lisp-mode-map "\C-ca" 'auto-complete-mode)))


(add-to-list 'default-frame-alist '(width . 120))
(add-to-list 'default-frame-alist '(height . 50))


(set-buffer-file-coding-system 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-selection-coding-system 'utf-8)
(set-default-coding-systems 'utf-8)
(set-clipboard-coding-system 'utf-8)  
(setq ansi-color-for-comint-mode t)
(modify-coding-system-alist 'process "*" 'utf-8)  
(setq-default pathname-coding-system 'utf-8)  
(prefer-coding-system 'utf-8)
(setq default-process-coding-system '(utf-8 . utf-8))  
(setq locale-coding-system 'utf-8)
(setq file-name-coding-system 'utf-8) 
(setq default-buffer-file-coding-system 'utf-8)  
(setq slime-net-coding-system 'utf-8-unix)


;;; Note that if you save a heap image, the character
;;; encoding specified on the command line will be preserved,
;;; and you won't have to specify the -K utf-8 any more.
;;; (setq inferior-lisp-program "/usr/local/bin/ccl64 -K utf-8")

(setq inferior-lisp-program "dx86cl64 -K utf-8")
(setq inferior-lisp-program "sbcl -K utf-8")

(setq slime-lisp-implementations
      '((ccl ("/Users/admin/LispBox-0.92/ccl-1.8-darwinx86/dx86cl64") :coding-system utf-8-unix)
        (sbcl ("/Users/admin/LispBox-0.92/sbcl-1.0.55/sbcl") :coding-system utf-8-unix)))

(require 'slime-autoloads)

(global-set-key "\C-cs" 'slime-selector)

(slime-setup '(slime-fancy slime-asdf slime-banner))
