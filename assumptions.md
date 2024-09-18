# Assumptions and Hacks made during the hackathon

## Assumptions

## Hacks/Shortcuts

### Data Model OSLO Openbaar domein

While we took some basic classes and predicates from the official application profile at [OSLO Openbaar domein](https://data.vlaanderen.be/doc/applicatieprofiel/inname-openbaar-domein/). In an ideal world, we would take ALL predicates and types from here but we limited ourselves to some predicates only and still used some of our own predicates to have a quick prototype ready.

For example, we didn't use the Periode class with a start Instant and an end Instant, but rather used custom predicates with dateTime type

### Data Model Besluit
