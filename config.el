;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
;; (setq user-full-name "John Doe"
;;       user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-one)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")
(setq org-roam-directory "~/org-roam")
(after! org-roam
  (setq org-roam-capture-templates
	'(("d" "default" plain ;; defines d shortcut for a default
	   "%?"
	   :target (file+head "${slug}.org" "#+title: ${title}\n#+filetags: :study:\n\n") ;; default header content
	   :unnarrowed t)
	  ("c" "concept" plain
	   "* Definition\n\n%?\n\n* Use Cases\n\n* Examples\n\n* Related Concepts\n\n* Sources\n"
	   :target (file+head "${slug}.org" "#+title: ${title}\n#+filetags: :study:concept:\n\n")
	   :unnarrowed t))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;              PYTHON                 ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; python interpreter
(use-package! python
  :config
  ;; python interpreter
  (setq python-shell-interpreter "python3")

  ;; black auto format on save
  (add-hook 'python-mode-hook'
            (lambda ()
              (add-hook 'before-save-hook 'lsp-format-buffer nil t)))

  (setq python-shell-virtualenv-root "~/venvs/")

  ;; pytest integration
  (map! :map python-mode-map
        :localleader
        "t" #'python-pytest))

;; LSP Configuration for Python
(after! lsp-pyright
  (setq lsp-pyright-langserver-command "pyright")
  (setq lsp-pyright-multi-root nil)
  (setq lsp-pyright-auto-import-completions t)
  (setq lsp-pyright-auto-search-paths t))

;; Configure Black Formatter
(use-package! python-black
  :after python
  :hook (python-mode . python-black-on-save-mode))

;; Redundant stopping of company issues
(when (fboundp 'company-mode)
  (global-company-mode -1))
(remove-hook 'after-init-hook #'global-company-mode)

;; === Corfu Configuration ===
(after! corfu
  (setq corfu-auto t                 ;; Auto popup
        corfu-cycle t               ;; Cycle through suggestions
        corfu-popupinfo-mode nil   ;; Turn off doc popups to avoid black box
        corfu-preselect 'prompt
        corfu-quit-no-match 'separator)  ;; No flicker on no match

  ;; Optional: turn off doc popups explicitly
  (corfu-popupinfo-mode -1))

;; Use orderless for more flexible matching
(after! orderless
  (setq completion-styles '(orderless)
        completion-category-defaults nil
        completion-category-overrides '((file (styles partial-completion)))))

;; Configure isort to sort imports alphabetically
(use-package! py-isort
  :after python
  :hook (python-mode . (lambda ()
                         (add-hook 'before-save-hook 'py-isort-before-save nil t))
                     )
  )


;; JavaScript/React-Config
(use-package! js2-mode
  :mode "\\.js\\'"
  :config
  (setq js2-basic-offset 2
        js2-bounce-indent-p nil
        js2-mode-show-parse-errors nil
        js2-mode-show-strict-warnings nil))

;; React/JSX Configuration
(use-package! rjsx-mode
  :mode "\\.jsx\\'"
  :config
  (setq sgml-basic-offset 2))

;; TypeScript Config
(use-package! typescript-mode
  :mode "\\.ts\\'"
  :config
  (setq typescript-indent-level 2))

;; TSX (TypeScript React) Configuration
(use-package! tsx-mode
  :mode "\\.tsx\\'"
  :config
  (add-hook 'js2-mode-hook 'prettier-js-mode)
  (add-hook 'rjsx-mode-hook 'prettier-js-mode)
  (add-hook 'typescript-mode-hook 'prettier-js-mode)
  (add-hook 'web-mode-hook 'prettier-js-mode))

;; LSP for JavaScript/TypeScript
(after! lsp-mode
  (remove-hook 'lsp-configure-hook #'lsp--auto-configure)
  (defun lsp--auto-configure () "Override: disable unwanted company-mode setup." nil)
  (setq lsp-javascript-suggest-auto-imports t
        lsp-typescript-suggest-auto-imports t
        lsp-completion-provider :capf ;; Keeps it minimal and reliable
        lsp-completion-use-company nil))


;; Emmet for HTML/JSX expansion
(use-package! emmet-mode
  :hook ((web-mode . emmet-mode)
         (rjsx-mode . emmet-mode)
         (html-mode . emmet-mode)))
;; Projects
(after! projectile
  (setq projectile-project-search-path '("~/projects")))

;; Short Cuts
(map! :leader
      :desc "Format buffer" "c f" #'lsp-format-buffer
      :desc "Format region" "c F" #'lsp-format-region
      :desc "Organize imports" "c o" #'lsp-organize-imports)

;; Python-specific bindings
(map! :map python-mode-map
      :localleader
      "f" #'python-black-buffer
      "i" #'py-isort-buffer
      "r" #'python-shell-send-region
      "b" #'python-shell-send-buffer)

;; JavaScript-specific bindings
(map! :map js2-mode-map
      :localleader
      "f" #'prettier-js
      "r" #'nodejs-repl-send-region)
;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.
