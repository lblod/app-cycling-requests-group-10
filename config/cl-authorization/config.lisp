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
  :cycling "http://mu.semte.ch/vocabularies/ext/cycling/"
  :sign "http://mu.semte.ch/vocabularies/ext/signing/"
  :mobi "https://data.vlaanderen.be/ns/mobiliteit#"
  :m8g "http://data.europa.eu/m8g/"
)

(define-graph public ("http://mu.semte.ch/graphs/public")
  ("ext:FileAddress" -> _)
  ("nfo:FileDataObject" -> _)
  ("locn:Address" -> _)
  ("skos:Concept" -> _)
  ("skos:ConceptScheme" -> _)
  ("cycling:RequestStateClassification" -> _)
  ("besluit:Bestuurseenheid" -> _)
  ("ext:BestuurseenheidClassificatieCode" -> _)
  ("prov:Location" -> _)
  ("cycling:Aanvraag" -> _)
  ("cycling:RouteSectie" -> _)
  ("cycling:GoedkeuringDoorGemeente" -> _)
  ("besluit:Agendapunt" -> _)
  ("besluit:Besluit" -> _)
  ("besluit:BehandelingVanAgendapunt" -> _)
  ("mobi:Project" -> _ )
  ("mobi:Inname" -> _ )
  ("cycling:Weigering" -> _ )
  ("besluit:Innamevergunning" -> _)
  ("cycling:Aanvraag" -> _))

(define-graph sessions ("http://mu.semte.ch/graphs/sessions")
  ("musession:Session" -> _))


(supply-allowed-group "public")

;; hack: this should never be done in a real app! mostly done to have login but not have to care about graphs
(grant (read write)
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
