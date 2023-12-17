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

;; 

(defvar org-babel-default-header-args:typst
  '((:results . "file graphics")))

(defun org-babel-execute:typst (body params)
  "Execute a block of typst code with org-babel.
This function is called by `org-babel-execute-src-block'."
  (let* ((out-file (or (alist-get :file params)
		       (org-babel-temp-file "org-babel-typst" ".png"))))
    (org-embed-typst/create-formula-image body out-file)
    out-file))

;;; Code:



(provide 'ob-typst)
;;; ob-typst.el ends here
