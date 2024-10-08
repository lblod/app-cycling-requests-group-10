;; considered complete when all three are done
(define-resource approval-by-commune ()
  :class (s-prefix "cycling:GoedkeuringDoorGemeente")
  :properties `((:created :datetime ,(s-prefix "dct:createdAt")))
  :has-one `((administrative-unit :via ,(s-prefix "cycling:bevoegdeBestuurseenheid")
                              :as "municipality")

             (cycling-request :via ,(s-prefix "cycling:goedkeuringVoor")
                         :as "request")
             (agendapunt :via ,(s-prefix "cycling:afweging")
                         :as "consideration")
             (agendapunt :via ,(s-prefix "cycling:innameOpenbaarDomein")
                         :as "taking-domain")
             (agendapunt :via ,(s-prefix "cycling:approvalByMayor")
                         :as "approval-mayor"))
  :resource-base (s-url "http://data.lblod.info/id/cycling/commune-approval/")
  :features '(include-uri)
  :on-path "commune-approvals"  )

(define-resource agendapunt ()
  :class (s-prefix "besluit:Agendapunt")
  :properties `((:beschrijving :string ,(s-prefix "dct:description"))
                (:titel :string ,(s-prefix "dct:title"))
                (:type :uri-set ,(s-prefix "besluit:Agendapunt.type")))
  :has-many `((published-resource :via ,(s-prefix "prov:wasDerivedFrom")
                                  :as "publications"))
  :has-one `((agendapunt :via ,(s-prefix "besluit:aangebrachtNa")
                         :as "vorige-agendapunt")
             (behandeling-van-agendapunt :via ,(s-prefix "dct:subject")
                                         :inverse t
                                         :as "behandeling"))
  :resource-base (s-url "http://data.lblod.info/id/agendapunten/")
  :features '(include-uri)
  :on-path "agendapunten"
)

(define-resource besluit ()
  :class (s-prefix "besluit:Besluit")
  :properties `((:beschrijving :string ,(s-prefix "eli:description"))
                (:citeeropschrift :string ,(s-prefix "eli:title_short"))
                (:motivering :string ,(s-prefix "besluit:motivering"))
                (:publicatiedatum :date ,(s-prefix "eli:date_publication"))
                (:inhoud :string ,(s-prefix "prov:value"))
                (:taal :url ,(s-prefix "eli:language"))
                (:titel :string ,(s-prefix "eli:title"))
                (:score :float ,(s-prefix "nao:score")))
  :has-one `((behandeling-van-agendapunt :via ,(s-prefix "prov:generated")
                                         :inverse t
                                         :as "volgend-uit-behandeling-van-agendapunt"))
  :resource-base (s-url "http://data.lblod.info/id/besluiten/")
  :features '(include-uri)
  :on-path "besluiten"
)

(define-resource refusal (besluit)
  :class (s-prefix "cycling:Weigering")
  :resource-base (s-url "http://data.lblod.info/id/weigeringen/")
  :features '(include-uri)
  :on-path "refusals"
)

(define-resource grant (besluit)
  :class (s-prefix "besluit:Innamevergunning")
  :resource-base (s-url "http://data.lblod.info/id/vergunning/")
  :features '(include-uri)
  :on-path "vergunningen"
)

;; very minimal, we only need the link between agendapunt and besluit
(define-resource behandeling-van-agendapunt ()
  :class (s-prefix "besluit:BehandelingVanAgendapunt")
  :has-many `((besluit :via ,(s-prefix "prov:generated")
                       :as "besluiten"))
  :has-one `((behandeling-van-agendapunt :via ,(s-prefix "besluit:gebeurtNa")
                                         :as "vorige-behandeling-van-agendapunt")
             (agendapunt :via ,(s-prefix "dct:subject")
                              :as "onderwerp"))
  :resource-base (s-url "http://data.lblod.info/id/behandelingen-van-agendapunten/")
  :features '(include-uri)
  :on-path "behandelingen-van-agendapunten"
)

(define-resource published-resource ()
  :class (s-prefix "sign:PublishedResource")
  ;; hack: put the content in here as a string for now. should be linked properly
  :properties `((:content :string ,(s-prefix "sign:text")))
  :resource-base (s-url "http://data.lblod.info/published-resources/")
  :features '(include-uri)
  :on-path "published-resources"
)