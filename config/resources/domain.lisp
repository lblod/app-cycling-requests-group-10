(in-package :mu-cl-resources)

(defparameter *cache-count-queries* nil)
(defparameter *supply-cache-headers-p* t
  "when non-nil, cache headers are supplied.  this works together with mu-cache.")
(setf *cache-model-properties-p* t)
(defparameter *include-count-in-paginated-responses* t
  "when non-nil, all paginated listings will contain the number
   of responses in the result object's meta.")
(defparameter *max-group-sorted-properties* nil)
(defparameter sparql:*experimental-no-application-graph-for-sudo-select-queries* t)
(setf *fetch-all-types-in-construct-queries* t)

;; reading in the domain.json
(read-domain-file "user.lisp")
(read-domain-file "cycling-requests.lisp")
(read-domain-file "decisions.lisp")

;; warning: run `mu project doc` after changes to the resource config to avoid unexpected errors