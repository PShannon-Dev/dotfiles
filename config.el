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
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-cont' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-one)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; truncate the bottom portion of the home directory with ~
(setq doom-modeline-buffer-file-name-style 'truncate-with-project)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(after! org-roam
  (setq org-roam-directory "~/org/roam/")
  (setq org-roam-db-location (concat org-roam-directory "org-roam.db"))

  (setq org-roam-capture-templates
        '(("d" "default" plain  ;; defines d shortcut key named default with plain formatting
           "%?"
           :target (file+head "${slug}.org" "#+title: ${title}\n#+filetages: :study:\n\n") ;; manages the default header content starting with the date
           :unnarrowed t)
          ("c" "concept" plain ;; defines c shortcut key named concept with plain formating
           "* Definition\n\n%?\n\n* Examples\n\n* Related Concepts\n\n* Sources\n"
           :target (file+head "${slug}.org" "#+title: ${title}\n#+filetags: :study:concept:\n\n") ;; managing header for C, same as default but additionally having concept in file tag
           :unnarrowed t))))


;; Python Configuration
(after! python
  ;; Use IPython when available
  (when (executable-find "ipython")
    (setq python-shell-interpreter "ipython"
          python-shell-interpreter-args "-i --simple-prompt"))

  ;; Set up formatting tools
  (setq-default flycheck-disabled-checkers '(python-pylint))
  (setq-default python-indent-offset 4)

  ;; Path to Python binary (use virtual environment if active)
  (setq python-shell-interpreter (or (executable-find "python")
                                    "/usr/bin/python3"))

  ;; Configure pytest
  (setq python-pytest-arguments
        '("--color" "--verbose"))

  ;; Set virtualenv directory if you use it
  (when (executable-find "virtualenv")
    (setq pyvenv-workon (expand-file-name "~/.virtualenvs/"))))

;; LSP configuration for Python
(after! lsp-mode
  (setq lsp-python-ms-auto-install-server t)
  (add-to-list 'lsp-file-watch-ignored-directories "[/\\\\]\\.venv\\'")
  (add-to-list 'lsp-file-watch-ignored-directories "[/\\\\]__pycache__\\'"))

;; Add keybindings for common Python tasks
(map! :map python-mode-map
      :localleader
      :desc "Start REPL" "'" #'+python/open-repl
      :desc "Test function" "tf" #'python-pytest-function
      :desc "Test file" "tm" #'python-pytest-file
      :desc "Format buffer" "=" #'+python/autoformat-buffer)

;; Add key bindings to make org-roam more accessible
(map! :leader
      (:prefix ("n" . "notes")
        (:prefix("r" . "roam")
         :desc "Find node" "f" #'org-roam-node-find
         :desc "Insert node" "i" #'org-roam-node-insert
         :desc "Capture to node" "c" #'org-roam-capture
         :desc "Toggle roam buffer" "r" #'org-roam-buffer-toggle)))
;; Set project directory to be able to jump into any project that is being worked on,
;; easily and quickly from the home buffer.
(setq projectile-project-search-path '("~/projects/"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Python Development Configuration
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Function to get correct Python executable
(defun my/get-python-executable ()
  "Get the appropriate Python executable, preferring virtualenv if active."
  (if (and (bound-and-true-p pyvenv-virtual-env)
           (file-exists-p (concat pyvenv-virtual-env
                                 (if (eq system-type 'windows-nt)
                                     "/Scripts/python.exe"
                                   "/bin/python"))))
      (concat pyvenv-virtual-env
              (if (eq system-type 'windows-nt)
                  "/Scripts/python.exe"
                "/bin/python"))
    (or (executable-find "python")
        "/usr/bin/python3")))

(defun my/update-python-shell-interpreter ()
  "Update the Python interpreter to use the virtual environment if active."
  (setq python-shell-interpreter (my/get-python-executable))
  (setq python-shell-interpreter-args
        (if (string-match-p "ipython" python-shell-interpreter)
            "-i --simple-prompt"
          "-i")))

;; Basic Python settings
(after! python
  ;; Use IPython when available (if not in a virtualenv)
  (when (and (not (bound-and-true-p pyvenv-virtual-env))
             (executable-find "ipython"))
    (setq python-shell-interpreter "ipython"
          python-shell-interpreter-args "-i --simple-prompt"))

  ;; Set up formatting tools
  (setq-default python-indent-offset 4)

  ;; Configure pytest
  (setq python-pytest-arguments
        '("--color" "--verbose")))

;; Flycheck configuration
(after! flycheck
  (setq-default flycheck-disabled-checkers '(python-pylint)))

;; LSP configuration for Python
(after! lsp-mode
  (setq lsp-python-ms-auto-install-server t)
  (add-to-list 'lsp-file-watch-ignored-directories "[/\\\\]\\.venv\\'")
  (add-to-list 'lsp-file-watch-ignored-directories "[/\\\\]__pycache__\\'"))

;; DAP mode for debugging
(after! dap-mode
  (setq dap-python-debugger 'debugpy)
  (require 'dap-python)

  ;; Set up a shortcut template for common debugging
  (dap-register-debug-template "Python :: Run Current File"
                              (list :type "python"
                                    :args ""
                                    :cwd nil
                                    :module nil
                                    :program nil
                                    :request "launch"
                                    :name "Python :: Run Current File"))

  ;; Use the same Python executable detection for debugging
  (setq dap-python-executable (my/get-python-executable)))

;; Virtual environment support
(after! pyvenv
  (setq pyvenv-mode-line-indicator
        '(pyvenv-virtual-env-name ("[venv:" pyvenv-virtual-env-name "] ")))
  (pyvenv-mode +1)

  ;; Set up hooks to update Python executable when virtualenv changes
  (add-hook 'pyvenv-post-activate-hooks #'my/update-python-shell-interpreter)
  (add-hook 'pyvenv-post-deactivate-hooks #'my/update-python-shell-interpreter))

;; Additional Python packages (if not included in Doom)
(use-package! sphinx-doc
  :hook (python-mode . sphinx-doc-mode))

;; Auto-detect and activate virtualenv function
(defun my/auto-detect-and-activate-virtualenv ()
  "Auto-detect and activate virtualenv for the current project."
  (interactive)
  (let ((project-dir (doom-project-root))
        (venv-dir nil))
    (cond
     ;; Check for .venv directory
     ((file-directory-p (expand-file-name ".venv" project-dir))
      (setq venv-dir (expand-file-name ".venv" project-dir)))
     ;; Check for venv directory
     ((file-directory-p (expand-file-name "venv" project-dir))
      (setq venv-dir (expand-file-name "venv" project-dir)))
     ;; Check for env directory
     ((file-directory-p (expand-file-name "env" project-dir))
      (setq venv-dir (expand-file-name "env" project-dir))))

    (when venv-dir
      (message "Activating virtualenv: %s" venv-dir)
      (pyvenv-activate venv-dir)
      ;; Update the Python interpreter after activation
      (my/update-python-shell-interpreter))))

;; Hook for virtualenv activation
(add-hook! 'python-mode-hook #'my/auto-detect-and-activate-virtualenv)

;; Python project creation function
(defun my/create-python-project (project-name)
  "Create a new Python project with the basic structure."
  (interactive "sProject name: ")
  (let ((project-dir (read-directory-name "Project directory: ")))
    (make-directory (expand-file-name project-name project-dir) t)
    (let ((default-directory (expand-file-name project-name project-dir)))
      ;; Create project structure
      (make-directory "src" t)
      (make-directory "tests" t)
      (make-directory "docs" t)

      ;; Create main module
      (make-directory (expand-file-name (concat "src/" project-name)) t)
      (with-temp-file (expand-file-name (concat "src/" project-name "/__init__.py"))
        (insert "# -*- coding: utf-8 -*-\n\n"))
      (with-temp-file (expand-file-name (concat "src/" project-name "/main.py"))
        (insert "# -*- coding: utf-8 -*-\n\n"))

      ;; Create test files
      (with-temp-file (expand-file-name "tests/__init__.py")
        (insert "# -*- coding: utf-8 -*-\n\n"))
      (with-temp-file (expand-file-name "tests/test_main.py")
        (insert "# -*- coding: utf-8 -*-\n\n"))

      ;; Create project files
      (with-temp-file (expand-file-name "README.md")
        (insert (format "# %s\n\nDescription of the project.\n" project-name)))
      (with-temp-file (expand-file-name "setup.py")
        (insert (format "from setuptools import setup, find_packages\n\nsetup(\n    name='%s',\n    version='0.1.0',\n    packages=find_packages(where='src'),\n    package_dir={'': 'src'},\n)\n" project-name)))

      ;; Create virtualenv
      (when (executable-find "python")
        (shell-command "python -m venv .venv")
        (message "Created virtualenv in .venv directory"))

      (message "Created Python project: %s" project-name))))

;; Keybindings for Python development
(map! :leader
      :desc "Create Python project" "p P" #'my/create-python-project)

(map! :map python-mode-map
      :localleader
      :desc "Start REPL" "'" #'+python/open-repl
      :desc "Test function" "tf" #'python-pytest-function
      :desc "Test file" "tm" #'python-pytest-file
      :desc "Format buffer" "=" #'+python/autoformat-buffer
      :desc "Activate venv" "va" #'my/auto-detect-and-activate-virtualenv)

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
