(defpackage #:pgloader.docs
  (:use #:cl #:cl-markdown #:pgloader.utils #:pgloader.params)
  (:export #:build-docs))

(in-package #:pgloader.docs)

(defparameter *docs-sources-directory*
  (asdf:system-relative-pathname :pgloader "web/src/"))

(defparameter *docs-output-directory*
  (asdf:system-relative-pathname :pgloader "web/howto/"))

(defparameter *reference*
  (asdf:system-relative-pathname :pgloader "pgloader.1.md"))

(defparameter *header*
  (asdf:system-relative-pathname :pgloader "web/howto/header.html"))

(defparameter *footer*
  (asdf:system-relative-pathname :pgloader "web/howto/footer.html"))

(defun build-page (file &optional target)
  "Build the HTML page from the markdown source FILE into the HTML TARGET."
  (let ((target
         (or target
             (merge-pathnames (make-pathname :name (pathname-name file)
                                             :type "html")
                              *docs-output-directory*))))
    (format t "Building: ~s~%" target)
    (with-open-file (s target
                       :direction :output
                       :external-format :utf-8
                       :if-exists :supersede
                       :if-does-not-exist :create)
      (write-string (slurp-file-into-string *header*) s)
      (markdown (slurp-file-into-string file) :stream s)
      (write-string (slurp-file-into-string *footer*) s))))

(defun build-docs ()
  "Build the HTML files from the Markdown ones."
  (build-page *reference*)
  (loop
     :for file :in (fad:list-directory *docs-sources-directory*)
     :when (string= "md" (pathname-type file))
     :do (build-page file) ))

