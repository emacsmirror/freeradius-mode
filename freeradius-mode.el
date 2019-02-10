;;; freeradius-mode.el --- major mode for FreeRadius server config files

;; URL: https://github.com/VersBinarii/freeradius-mode
;; Version: 1.0.0
;; Package-Requires: ((emacs "24.4"))

;;; License:
;;  The MIT License (MIT)
;; Copyright © 2019 Krzysztof Grobelak
;; Permission is hereby granted, free of charge, to any person obtaining a copy of this software
;; and associated documentation files (the “Software”), to deal in the Software without
;; restriction, including without limitation the rights to use, copy, modify, merge, publish,
;; distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom
;; the Software is furnished to do so, subject to the following conditions:

;; The above copyright notice and this permission notice shall be included in all copies
;; or substantial portions of the Software.
;; THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING
;; BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
;; NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
;; DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
;; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


;;; Commentary:

;; This major-mode provides syntax highlighting and indentation handling
;; for editing FreeRadius configuration files and unlang policies.

;;; Code:

(defvar freeradius-mode-hook nil)

(defcustom freeradius-indent-offset 4
  "Indent freeradius unlang code by this number of spaces."
  :type 'integer
  :group 'freeradius-mode)

(defconst freeradius-keywords-regexp
  (regexp-opt (list "if"
					"else"
					"elsif"
					"case"
					"switch"
					"update"
					"actions"
					"foreach"
					"load-balance"
					"parallel"
					"redundant"
					"redundant-load-balance"
					"subrequest") 'symbols))

(defconst freeradius-constants-regexp
  (regexp-opt (list "reply"
					"reply"
					"control"
					"request"
					"ok"
					"noop"
					"return"
					"fail"
					"reject"
					"notfound"
					"updated"
					"userlock"
					"invalid"
					"handled") 'symbols))

(defconst freeradius-font-lock-definitions
  (list
   ;; Define all keywords
   (cons freeradius-keywords-regexp font-lock-keyword-face)
   
   ;; Constants
   (cons freeradius-constants-regexp font-lock-constant-face)
   
   ;; Match all variables i.e. &Attr-Foo
   (cons "&\\([-_[:alnum:]]+\\)" '(1 font-lock-variable-name-face))
   
   ;; Match all Tmp-* variables
   (cons ".*\\(Tmp-[[:alpha:]]+-[[:digit:]]\\)" '(1 font-lock-variable-name-face))
   
   ;; Match all module/policy definitiions
   (cons "^\\([-_[:alnum:]\\. ]+\\)[[:space:]]{" '(1 font-lock-function-name-face))
   
   ;; Match all usages of modules in config files
   (cons "^\\s-+\\([-_[:alnum:][:space:]\\.]+\\)[[:space:]]?{?$" '(1 font-lock-function-name-face))
   
   ;; Match various assignment types :=, ==, +=
   (cons "^\\s-+\\([-_[:alnum:]]+\\)[[:space:]]*\\(:\\+\\|:\\|=\\|-\\|!|\\|>\\|<\\)?=[[:space:]]*.+" '(1 font-lock-variable-name-face))
   
   ;; Match the xlat modules in %{} expansions
   (cons "%{\\([[:alnum:]]+\\):.*}" '(1 font-lock-builtin-face))
   
   ;; Highlight regexes
   (cons "=~[[:space]]?/\\(.*\\)/[ig]?" '(1 font-lock-string-face)))
  "A map of regular expressions to font-lock faces.")


(defun freeradius-get-indent-level()
  "Get the current indentation level."
  (car (syntax-ppss)))

(defun freeradius-indent-function ()
  "Basic indentation handling."
  (save-excursion
    (beginning-of-line)
	(search-forward "}" (line-end-position) t)
	(indent-line-to
	 (* freeradius-indent-offset (freeradius-get-indent-level)))))

;;;###autoload
(define-derived-mode freeradius-mode fundamental-mode "freeradius mode"
  "Major mode for editing FreeRadius config files and unlang."
  
  ;; Comments handling
  (modify-syntax-entry ?# "< b" freeradius-mode-syntax-table)
  (modify-syntax-entry ?\n "> b" freeradius-mode-syntax-table)
  (modify-syntax-entry ?\" "." freeradius-mode-syntax-table)
  (setq-local comment-start "#")
  (setq-local comment-start-skip "#+\\s-*")
  (setq-local comment-end "\n")
  
  ;; code for syntax highlighting
  (setq-local font-lock-defaults
			  '(freeradius-font-lock-definitions))
  ;; Basic indentation handler
  (setq-local indent-line-function 'freeradius-indent-function))

(provide 'freeradius-mode)
;;; freeradius-mode.el ends here
