;;; test_detangle.el --- Test org-babel-detangle functionality

(require 'org)
(require 'ob-tangle)

;; Test detangling
(let ((tangled-file "experiments/detangle_test.py"))
  (if (file-exists-p tangled-file)
      (progn
        (message "Attempting to detangle %s..." tangled-file)
        (condition-case err
            (progn
              (org-babel-detangle tangled-file)
              (message "Detangle successful!"))
          (error (message "Detangle failed: %s" err))))
    (message "File not found: %s" tangled-file)))

;;; test_detangle.el ends here