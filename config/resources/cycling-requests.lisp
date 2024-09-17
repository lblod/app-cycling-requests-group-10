;; match to werkingsgebied based on adres with same gemeentenaam label,
;; only gemeentenaam is used in this hackathon but this should be stronger
;; probably by lookups in the CRAB database
(define-resource adres ()
  :class (s-prefix "locn:Address")
  :properties `((:busnummer :string ,(s-prefix "adres:Adresvoorstelling.busnummer"))
                (:huisnummer :string ,(s-prefix "adres:AdresVoorstelling.huisnummer"))
                (:straatnaam :string ,(s-prefix "locn:thoroughfare"))
                (:postcode :string ,(s-prefix "locn:postCode"))
                (:gemeentenaam :string ,(s-prefix "adres:gemeentenaam"))
                (:land :language-string-set ,(s-prefix "adres:land"))
                (:locatieaanduiding :string ,(s-prefix "locn:locatorDesignator"))
                (:locatienaam :language-string-set ,(s-prefix "locn:locatorName"))
                (:postbus :string ,(s-prefix "locn:poBox"))
                (:postnaam :string ,(s-prefix "locn:postName"))
                (:volledig-adres :string ,(s-prefix "locn:fullAddress"))
                (:adres-register-id :number ,(s-prefix "lblodlg:adresRegisterId"))
                (:adres-register-uri :url ,(s-prefix "adres:verwijstNaar")))
  :features '(include-uri)
  :resource-base (s-url "http://data.lblod.info/id/adressen/")
  :on-path "adressen"
)

(define-resource concept ()
  :class (s-prefix "skos:Concept")
  :properties `((:label :string ,(s-prefix "skos:prefLabel")))
  :has-many `((concept-scheme :via ,(s-prefix "skos:inScheme")
                              :as "concept-schemes")
              (concept-scheme :via ,(s-prefix "skos:topConceptOf")
                              :as "top-concept-schemes"))
  :resource-base (s-url "http://lblod.data.gift/concepts/")
  :features `(include-uri)
  :on-path "concepts"
)

(define-resource concept-scheme ()
  :class (s-prefix "skos:ConceptScheme")
  :properties `((:label :string ,(s-prefix "skos:prefLabel")))
  :has-many `((concept :via ,(s-prefix "skos:inScheme")
                       :inverse t
                       :as "concepts")
              (concept :via ,(s-prefix "skos:topConceptOf")
                       :inverse t
                       :as "top-concepts"))
  :resource-base (s-url "http://lblod.data.gift/concept-schemes/")
  :features `(include-uri)
  :on-path "concept-schemes"
)

(define-resource request-state-classification (concept)
  :class (s-prefix "cycling:RequestStateClassification")
  :has-many `((cycling-request :via ,(s-prefix "cycling:state")
                               :inverse t
                               :as "requests"))
  :resource-base (s-url "http://data.lblod.info/id/request-state-classification/")
  :features '(include-uri)
  :on-path "request-state-classifications")

(define-resource bestuurseenheid ()
  :class (s-prefix "besluit:Bestuurseenheid")
  :properties `((:naam :string ,(s-prefix "skos:prefLabel"))
                (:alternatieve-naam :string-set ,(s-prefix "skos:altLabel"))
                (:wil-mail-ontvangen :boolean ,(s-prefix "ext:wilMailOntvangen")) ;;Voorkeur in berichtencentrum
                (:mail-adres :string ,(s-prefix "ext:mailAdresVoorNotificaties")))
  :has-one `((werkingsgebied :via ,(s-prefix "besluit:werkingsgebied")
                             :as "werkingsgebied")
             (bestuurseenheid-classificatie-code :via ,(s-prefix "besluit:classificatie")
                                                 :as "classificatie"))
  :resource-base (s-url "http://data.lblod.info/id/bestuurseenheden/")
  :features '(include-uri)
  :on-path "bestuurseenheden"
)

(define-resource bestuurseenheid-classificatie-code ()
  :class (s-prefix "ext:BestuurseenheidClassificatieCode")
  :properties `((:label :string ,(s-prefix "skos:prefLabel"))
                (:scope-note :string ,(s-prefix "skos:scopeNote")))
  :resource-base (s-url "http://data.vlaanderen.be/id/concept/BestuurseenheidClassificatieCode/")
  :features '(include-uri)
  :on-path "bestuurseenheid-classificatie-codes"
)

(define-resource werkingsgebied ()
  :class (s-prefix "prov:Location")
  :properties `((:naam :string ,(s-prefix "rdfs:label"))
                (:niveau :string, (s-prefix "ext:werkingsgebiedNiveau")))

  :has-many `((bestuurseenheid :via ,(s-prefix "besluit:werkingsgebied")
                               :inverse t
                               :as "bestuurseenheid"))
  :resource-base (s-url "http://data.lblod.info/id/werkingsgebieden/")
  :features '(include-uri)
  :on-path "werkingsgebieden"
)

(define-resource cycling-request ()
  :class (s-prefix "cycling:Aanvraag")
  ;; most properties will come from the form (if all goes well)
  :properties `((:created :datetime ,(s-prefix "dct:createdAt"))
                (:race-name :string ,(s-prefix "dct:title"))
                (:race-date :string ,(s-prefix "cycling:raceDate"))
                (:organizer-name :string ,(s-prefix "cycling:organizerName"))
                (:organizer-address :string ,(s-prefix "cycling:organizerAddress")))
  :has-one `((request-state-classification :via ,(s-prefix "cycling:state")
                           :as "state"))
  :has-many `((route-section :via ,(s-prefix "cycling:routeSectie")
                           :as "route-sections")
              (approval-by-commune :via ,(s-prefix "cycling:goedkeuringVoor")
                           :inverse t
                           :as "approvals"))
  :resource-base (s-url "http://data.lblod.info/id/cycling/aanvraag/")
  :features '(include-uri)
  :on-path "cycling-requests"  )

(define-resource route-section ()
  :class (s-prefix "cycling:RouteSectie")
  :properties `((:created :datetime ,(s-prefix "dct:createdAt"))
                (:time-of-passing-start :datetime ,(s-prefix "cycling:startPassage"))
                (:time-of-passing-end :datetime ,(s-prefix "cycling:endPassage"))
                (:distance :number ,(s-prefix "cycling:afstand")))
  :has-many `((adres :via ,(s-prefix "cycling:gebruiktWerkingsgebied")
                           :as "areas"))
  :resource-base (s-url "http://data.lblod.info/id/cycling/route-sectie/")
  :features '(include-uri)
  :on-path "route-sections"  )

