Namespace: cycling-poc
@prefix cycl: <https://vlaanderen.be/abb/hackaton/group10/ns/cycling-poc> .

# Application form result

## Application model

Nl. 'Aanvraag voor wielerwedstrijd

* Model: 'CyclingApplication'
* Name (string)
* Days (List[CyclingApplicationDay])
* Organiser (simplified: name of person)
* SafetyCoordinator (simplified: name of person)
* PublicityCaravan (simplified boolean yes/no)
* Policesupport (simplified boolean yes/no)
* RouteDefinition (RouteDefinition)

## CyclingApplicationDay

* Model 'CyclingApplicationDay'
* Date (day of year)
* StartTime (time of day)
* EndTime (time of day)

## Route definition model

* Model 'RouteDefintion'
* Day (CyclingApplicationDay)
* CompetitionSegments (List[CompetitionSegment])

## Competition segment model

* Model 'CompetitionSegment'
* LocationFrom, LocationTo (Unknown for poc, geo stuff left out for now)
* Municipality
* RegionalRoad (For hackaton boolean yes/no)
* ProvincialRoad (For hackaton boolean yes/no)
* Railwaycrossings (List string)

---


