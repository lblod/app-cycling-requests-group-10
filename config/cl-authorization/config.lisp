;;;;;;;;;;;;;;;;;;;
;;; delta messenger
(in-package :delta-messenger)

(setf *delta-handlers* nil)
(add-delta-logger)
(add-delta-messenger "http://deltanotifier/")

;;;;;;;;;;;;;;;;;
;;; configuration
(in-package :client)
(setf *log-sparql-query-roundtrip* t)
(setf *backend* "http://virtuoso:8890/sparql"
      ;; (list "http://triplestore:8890/sparql"
      ;;       "http://triplestore1:8890/sparql"
      ;;       "http://triplestore2:8890/sparql"
      ;;       "http://triplestore3:8890/sparql"
      ;;       )
      )

(in-package :server)
(setf *log-incoming-requests-p* t)

;;;;;;;;;;;;;;;;;
;;; access rights

(in-package :acl)

(defparameter *access-specifications* nil
  "All known ACCESS specifications.")

(defparameter *graphs* nil
  "All known GRAPH-SPECIFICATION instances.")

(defparameter *rights* nil
  "All known GRANT instances connecting ACCESS-SPECIFICATION to GRAPH.")

(define-prefixes
  :astreams "http://www.w3.org/ns/activitystreams#"
  :adms "http://www.w3.org/ns/adms#"
  :besluit "http://data.vlaanderen.be/ns/besluit#"
  :contacthub "http://data.lblod.info/vocabularies/contacthub/"
  :dct "http://purl.org/dc/terms/"
  :euvoc "http://publications.europa.eu/ontology/euvoc#"
  :ext "http://mu.semte.ch/vocabularies/ext/"
  :eli "http://data.europa.eu/eli/ontology#"
  :foaf "http://xmlns.com/foaf/0.1/"
  :lblodlg "http://data.lblod.info/vocabularies/leidinggevenden/"
  :locn "http://www.w3.org/ns/locn#"
  :m8g "http://data.europa.eu/m8g/"
  :mandaat "http://data.vlaanderen.be/ns/mandaat#"
  :musession "http://mu.semte.ch/vocabularies/session/"
  :nfo "http://www.semanticdesktop.org/ontologies/2007/03/22/nfo#"
  :org "http://www.w3.org/ns/org#"
  :person "http://www.w3.org/ns/person#"
  :persoon "http://data.vlaanderen.be/ns/persoon#"
  :prov "http://www.w3.org/ns/prov#"
  :schema "http://schema.org/"
  :skos "http://www.w3.org/2004/02/skos/core#"
  :extlmb "http://mu.semte.ch/vocabularies/ext/lmb/"
  :lmb "http://lblod.data.gift/vocabularies/lmb/"
)

(define-graph public ("http://mu.semte.ch/graphs/public")
  ("ext:FileAddress" -> _)
  ("nfo:FileDataObject" -> _))

(define-graph sessions ("http://mu.semte.ch/graphs/sessions")
  ("musession:Session" -> _))

; minimal set of types. Not counting on this app being used to write types here,
; only receive them from the ldes client through sudo queries
(define-graph lmb ("http://mu.semte.ch/graphs/lmb")
  ("foaf:Person" -> _)
  ("foaf:OnlineAccount" -> _)
  ("adms:Identifier" -> _))


(supply-allowed-group "public")

(grant (read)
       :to-graph public
       :for-allowed-group "public")

(supply-allowed-group "authenticated"
  :parameters ()
  :query "PREFIX ext: <http://mu.semte.ch/vocabularies/ext/>
          PREFIX mu: <http://mu.semte.ch/vocabularies/core/>
          SELECT DISTINCT ?session_group ?session_role WHERE {
            <SESSION_ID> ext:sessionGroup/mu:uuid ?session_group;
                         ext:sessionRole ?session_role.
          }")

(grant (read)
       :to-graph sessions
       :for-allowed-group "authenticated")

; granting read to lmb graph, I envisage that there will be multiple such graphs
; one for every source LDES being consumed. But this is just an example approach.
; This gives you the benefit of keeping track of where you received data from so that
; IF you have two sources providing you with the same concept but different versions,
; you know which came from where. You can also give different access rights this way
(grant (read)
       :to-graph lmb
       :for-allowed-group "authenticated")
