;;; ob-typst.el --- org babel file for typst         -*- lexical-binding: t; -*-

;; Copyright (C) 2023 Cj-bc/陽鞠莉桜

;; Author: Cj-bc/陽鞠莉桜
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
")

(defvar ob-typst/default-page-rule  "#set page(width: auto, height: auto, margin: 0.3em)"
  "if target typst snippet doesn't have rule for page, this will be used.
Initial value produces minimum"
  )


(defun ob-typst/cli-available-p ()
  "Returns t if typst cli command is available"
  (condition-case nil
    (progn (call-process "typst" nil nil nil "--help") t)
    (file-missing nil)))

(defun org-babel-execute:typst (body params)
  "Execute a block of typst code with org-babel.
This function is called by `org-babel-execute-src-block'."
  (let* ((out-file (or (alist-get :outfile params)
		       (org-babel-temp-file "org-babel-typst" ".png"))))
    (ob-typst/create-formula-image body out-file)
    out-file))

(defun ob-typst/create-formula-image (string tofile)
  "Create an image from typst source using external process.

The Typst STRING is saved to a temporary Typst file, then
converted to an image file by 'typst compiler' command.

The generated image file is eventually moved to TOFILE.

Generated file format is determined by TOFILE file
extension. Supported file formats are: .png, .pdf, .svg
"
  (let ((tmpfile (make-temp-file "ob-typst"))
	(ext (file-name-extension tofile))
	(log-buf (get-buffer-create "*Org Preview typst Output*")))
    (with-temp-file tmpfile
      (insert string)
      (unless (search-backward "#set page(" nil t)
	(goto-char (point-min))
	(insert ob-typst/default-page-rule "\n"))
      )
    (copy-file (org-compile-file tmpfile
				 (list (format "typst compile --format %s --root %%o %%f" ext))
				 ext "" log-buf)
	       tofile 'replace)))


(provide 'ob-typst)
;;; ob-typst.el ends here
