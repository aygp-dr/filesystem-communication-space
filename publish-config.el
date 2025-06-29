;;; publish-config.el --- Org-mode publishing configuration for filesystem-communication-space

;;; Commentary:
;; This file configures org-mode export settings for generating PDF documentation
;; from the filesystem-communication-space project.

;;; Code:

(require 'ox-latex)
(require 'ox-publish)

;; Configure LaTeX export settings
(setq org-latex-pdf-process
      '("pdflatex -interaction nonstopmode -output-directory %o %f"
        "pdflatex -interaction nonstopmode -output-directory %o %f"
        "pdflatex -interaction nonstopmode -output-directory %o %f"))

;; Add report class if not already defined
(unless (assoc "report" org-latex-classes)
  (add-to-list 'org-latex-classes
               '("report"
                 "\\documentclass[11pt]{report}"
                 ("\\chapter{%s}" . "\\chapter*{%s}")
                 ("\\section{%s}" . "\\section*{%s}")
                 ("\\subsection{%s}" . "\\subsection*{%s}")
                 ("\\subsubsection{%s}" . "\\subsubsection*{%s}"))))

;; Configure code block export
(setq org-latex-listings 'listings)
(setq org-latex-listings-options
      '(("frame" "single")
        ("basicstyle" "\\small\\ttfamily")
        ("numbers" "left")
        ("numberstyle" "\\tiny")
        ("breaklines" "true")
        ("showstringspaces" "false")
        ("keywordstyle" "\\color{blue}")
        ("commentstyle" "\\color{gray}")
        ("stringstyle" "\\color{green}")))

;; Custom LaTeX packages
(setq org-latex-packages-alist
      '(("" "listings")
        ("" "xcolor")
        ("" "hyperref")
        ("" "graphicx")
        ("" "longtable")
        ("" "float")))

;; Export settings
(setq org-export-with-toc t
      org-export-with-section-numbers t
      org-export-with-sub-superscripts nil
      org-export-with-smart-quotes t
      org-export-with-todo-keywords nil)

;; Publishing project definition
(setq org-publish-project-alist
      '(("filesystem-communication-space-pdf"
         :base-directory "."
         :base-extension "org"
         :publishing-directory "."
         :publishing-function org-latex-publish-to-pdf
         :include ("filesystem-communication-space.org")
         :exclude ".*"
         :latex-class "report"
         :with-toc t
         :section-numbers t)))

;; Function to publish the PDF
(defun publish-filesystem-communication-space-pdf ()
  "Publish the filesystem-communication-space document to PDF."
  (interactive)
  (org-publish-project "filesystem-communication-space-pdf" t))

;; Export the main function
(provide 'publish-config)

;;; publish-config.el ends here