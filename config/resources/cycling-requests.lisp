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
  :properties `((:label :string ,(s-prefix "skos:prefLabel")))
  :has-many `((cycling-request :via ,(s-prefix "cycling:state")
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

(define-resource project ()
  :class (s-prefix "mobi:Project")
  :resource-base (s-url "http://data.lblod.info/id/projects/")
  :features '(include-uri)
  :has-one `((gebruiker :via ,(s-prefix "mobi:beheerder")
                   :as "responsible"))
  :on-path "projects" )

(define-resource cycling-request (project)
  :class (s-prefix "cycling:Aanvraag")
  ;; most properties will come from the form (if all goes well)
  :properties `((:created :datetime ,(s-prefix "dct:createdAt"))
                (:race-name :string ,(s-prefix "dct:title"))
                ;; this could be computed from the times of the route-sections, but is left here because it's easy during the hackathon
                (:race-date :string ,(s-prefix "cycling:raceDate"))
                ;; can we get this from the user? Maybe that's not a good idea because they may want to use pseudonyms/brand names?
                (:organizer-name :string ,(s-prefix "cycling:organizerName"))
                ;; shortcut instead of using an address type
                (:organizer-address :string ,(s-prefix "cycling:organizerAddress"))
                (:description :string ,(s-prefix "dct:description")))
  :has-one `((request-state-classification :via ,(s-prefix "cycling:state")
                           :as "state"))
  :has-many `((route-section :via ,(s-prefix "mobi:Project.omvat")
                           :as "route-sections")
              (approval-by-commune :via ,(s-prefix "cycling:goedkeuringVoor")
                           :inverse t
                           :as "approvals"))
  :resource-base (s-url "http://data.lblod.info/id/cycling/aanvraag/")
  :features '(include-uri)
  :on-path "cycling-requests"  )

(define-resource route-section ()
  :class (s-prefix "mobi:Inname")
  :properties `((:created :datetime ,(s-prefix "dct:createdAt"))
                ;; choosing not to create Period + Instants entities for now, this should be improved in the true product
                (:time-of-passing-start :datetime ,(s-prefix "cycling:startPassage"))
                (:time-of-passing-end :datetime ,(s-prefix "cycling:endPassage"))
                (:description :string ,(s-prefix "dct:description"))
                (:distance :number ,(s-prefix "cycling:afstand")))

  :has-many `((address :via ,(s-prefix "cycling:gebruiktWerkingsgebied")
                           :as "areas")
              ;; warning: this is missing in the applicationprofile, guessing the prefix
              (grant :via ,(s-prefix "mobi:vergunt")
                           :as "grants")
              ;; warning: need refusal as type of besluit as well to easily find the refusals, creating our own for now, would normally reach out to Yoda
              (refusal :via ,(s-prefix "cycling:weigering")
                           :as "refusals"))
  :resource-base (s-url "http://data.lblod.info/id/cylcing/route-sectie/")
  :features '(include-uri)
  :on-path "route-sections"  )

