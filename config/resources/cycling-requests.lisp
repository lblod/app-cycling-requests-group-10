;; match to werkingsgebied based on adres with same gemeentenaam label,
;; only gemeentenaam is used in this hackathon but this should be stronger
;; probably by lookups in the CRAB database
(define-resource address ()
  :class (s-prefix "locn:Address")
  :properties `((:box-number :string ,(s-prefix "adres:Adresvoorstelling.busnummer"))
                (:number :string ,(s-prefix "adres:AdresVoorstelling.huisnummer"))
                (:street :string ,(s-prefix "locn:thoroughfare"))
                (:postcode :string ,(s-prefix "locn:postCode"))
                (:municipality :string ,(s-prefix "adres:gemeentenaam"))
                (:country :string ,(s-prefix "adres:land"))
                (:locator-designator :string ,(s-prefix "locn:locatorDesignator"))
                (:locator-name :string ,(s-prefix "locn:locatorName"))
                (:po-box :string ,(s-prefix "locn:poBox"))
                (:post-name :string ,(s-prefix "locn:postName"))
                (:full-address :string ,(s-prefix "locn:fullAddress"))
                (:address-register-id :number ,(s-prefix "lblodlg:adresRegisterId"))
                (:address-register-uri :url ,(s-prefix "adres:verwijstNaar")))
  :features '(include-uri)
  :resource-base (s-url "http://data.lblod.info/id/adressen/")
  :on-path "addresses"
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
  :has-many `((cycling-request :via ,(s-prefix "cylcing:state")
                               :inverse t
                               :as "requests"))
  :resource-base (s-url "http://data.lblod.info/id/request-state-classification/")
  :features '(include-uri)
  :on-path "request-state-classifications")

(define-resource administrative-unit ()
  :class (s-prefix "besluit:Bestuurseenheid")
  :properties `((:name :string ,(s-prefix "skos:prefLabel"))
                (:alternative-name :string ,(s-prefix "skos:altLabel"))
                (:want-mail-received :boolean ,(s-prefix "ext:wilMailOntvangen")) ;;Voorkeur in berichtencentrum
                (:mail-address-for-notifications :string ,(s-prefix "ext:mailAdresVoorNotificaties")))
  :has-one `((location :via ,(s-prefix "besluit:werkingsgebied")
                             :as "location")
             (administrative-unit-classification-code :via ,(s-prefix "besluit:classificatie")
                                                 :as "classification"))
  :resource-base (s-url "http://data.lblod.info/id/bestuurseenheden/")
  :features '(include-uri)
  :on-path "administrative-units"
)

(define-resource administrative-unit-classification-code ()
  :class (s-prefix "ext:BestuurseenheidClassificatieCode")
  :properties `((:label :string ,(s-prefix "skos:prefLabel"))
                (:scope-note :string ,(s-prefix "skos:scopeNote")))
  :resource-base (s-url "http://data.vlaanderen.be/id/concept/BestuurseenheidClassificatieCode/")
  :features '(include-uri)
  :on-path "administrative-unit-classification-codes"
)

(define-resource location ()
  :class (s-prefix "prov:Location")
  :properties `((:label :string ,(s-prefix "rdfs:label"))
                (:niveau :string, (s-prefix "ext:werkingsgebiedNiveau")))

  :has-many `((administrative-unit :via ,(s-prefix "besluit:werkingsgebied")
                               :inverse t
                               :as "administrative-units"))
  :resource-base (s-url "http://data.lblod.info/id/werkingsgebieden/")
  :features '(include-uri)
  :on-path "locations"
)

(define-resource cycling-request ()
  :class (s-prefix "cycling:Aanvraag")
  ;; most properties will come from the form (if all goes well)
  :properties `((:created :datetime ,(s-prefix "dct:createdAt")))
  :has-one `((request-state-classification :via ,(s-prefix "cycling:state")
                           :as "state"))
  :has-many `((route-section :via ,(s-prefix "cycling:routeSectie")
                           :as "route-sections"))
  :resource-base (s-url "http://data.lblod.info/id/cylcing/aanvraag/")
  :features '(include-uri)
  :on-path "cycling-requests"  )

(define-resource route-section ()
  :class (s-prefix "cycling:RouteSectie")
  :properties `((:created :datetime ,(s-prefix "dct:createdAt"))
                (:time-of-passing-start :datetime ,(s-prefix "cycling:startPassage"))
                (:time-of-passing-end :datetime ,(s-prefix "cycling:endPassage"))
                (:distance :number ,(s-prefix "cycling:afstand")))
  :has-many `((address :via ,(s-prefix "cycling:gebruiktWerkingsgebied")
                           :as "areas"))
  :resource-base (s-url "http://data.lblod.info/id/cylcing/route-sectie/")
  :features '(include-uri)
  :on-path "route-sections"  )

