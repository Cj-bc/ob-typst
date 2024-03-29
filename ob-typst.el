;;; ob-typst.el --- org babel file for typst         -*- lexical-binding: t; -*-

;; Copyright (C) 2023 Cj-bc/陽鞠莉桜

;; Author: Cj-bc/陽鞠莉桜 <cj.bc-sd@outlook.jp>
;; Version: 1.0.0
;; Keywords: 

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

;; Org babel for https://typst.app.
;; Requires typst cli tool: https://github.com/typst/typst
;;
;; This only provides babel execution function, not "typst-mode" or "typst-ts-mode"

;;; Code:

(require 'files)
(require 'org-macs)
(require 'ob-core)

(defvar org-babel-default-header-args:typst
  '((:results . "file graphics raw"))
  "Default arguments to use when evaluating a typst source block.

Having \"raw\" in it enables inline src block outputs only file
path, which works nicely with `org-toggle-inline-images'

Without it,
  > src_typst{a/b = abc_d}
expands to:
  > {{{results([[file:/tmp/babel-R4uOI0/org-babel-typsttIVzgp.png]])}}}
which can't be previewed by `org-toggle-inline-images'.
")

(defgroup ob-typst nil
  "Org babel functions for typst"
  :group 'org-babel
  :package-version '(ob-typst . "0.1.0")
  :prefix "ob-typst/")

(defconst ob-typst/settable-elements '(bibliography list cite document emph figure footnote heading link
						     enum numbering outline par parbreak quote ref strong table terms
						     page)
  "List of settable elements")

(defcustom ob-typst/default-rules-alist '((page . "width: auto, height: auto, margin: 0.3em"))
  "Plist of default typst set rules that will be appened to every typst code.
Each rules will be set only if target typst snippet doesn't have rule for each element.
"
  :group 'ob-typst
  :type
  `(alist :key-type (choice ,@(mapcar #'(lambda (e) `(const ,e)) ob-typst/settable-elements))
	  :value-type string))

(defcustom ob-typst/default-format "svg"
  "Default format for output image."
  :group 'ob-typst
  :type '(choice (const "png")
		 (const "svg")
		 (const "pdf")))

(defun ob-typst/cli-available-p ()
  "Returns t if typst cli command is available"
  (condition-case nil
    (progn (call-process "typst" nil nil nil "--help") t)
    (file-missing nil)))

(defun org-babel-execute:typst (body params)
  "Execute a block of typst code with org-babel.
This function is called by `org-babel-execute-src-block'."
  (let* ((out-file (or (alist-get :outfile params)
		       (org-babel-temp-file "org-babel-typst" (format ".%s" ob-typst/default-format)))))
    (ob-typst/create-image body out-file)
    out-file))

;; I've got idea and name for this function from
;; `org-create-formula-image'.
(defun ob-typst/create-image (string tofile)
  "Create an image from typst source using external process.

The Typst STRING is saved to a temporary Typst file, then
converted to an image file by 'typst compiler' command.

The generated image file is eventually moved to TOFILE.

Generated file format is determined by TOFILE file
extension. Supported file formats are: .png, .pdf, .svg
"
  (if (ob-typst/cli-available-p)
      (let* ((tmpfile (make-temp-file "ob-typst"))
	     (ext (file-name-extension tofile))
	     (log-buf (get-buffer-create "*Org Preview typst Output*"))
	     (rules-in-string
	      (seq-reduce
	       (lambda (acc s)
	  	 (let ((rule (save-match-data
	  		       (string-match (rx (: line-start "#set " (group (+ (not "("))) "(")) s)
	  		       (match-string 1 s))))
	  	   (if rule (cons rule acc) acc)))
	       (string-lines string) '()))
	     (default-rules-str
	      (string-join (mapcar
			    (lambda (c)
	  		      (unless (seq-contains-p rules-in-string (symbol-name (car c)))
	  			(format "#set %s(%s)" (car c) (cdr c))))
	  		    ob-typst/default-rules-alist) "\n")))
	(with-temp-file tmpfile
	  (insert default-rules-str "\n" string))
	(copy-file (org-compile-file tmpfile
				     (list (format "typst compile --format %s --root %%o %%f" ext))
				     ext "" log-buf)
		   tofile 'replace))
    (display-warning 'ob-typst "typst command not found")))


(provide 'ob-typst)
;;; ob-typst.el ends here
