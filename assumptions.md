# Assumptions and Hacks made during the hackathon

## Assumptions

### GN reading our AgendaPunt items from LDES

We expect GN to read our LDES feed and fetch the Agendapunt items from it and then assign them to the correct Agenda or modify them as they see fit.

## Hacks/Shortcuts

### Data Model OSLO Openbaar domein

While we took some basic classes and predicates from the official application profile at [OSLO Openbaar domein](https://data.vlaanderen.be/doc/applicatieprofiel/inname-openbaar-domein/). In an ideal world, we would take ALL predicates and types from here but we limited ourselves to some predicates only and still used some of our own predicates to have a quick prototype ready.

For example, we didn't use the Periode class with a start Instant and an end Instant, but rather used custom predicates with dateTime type

### Data Model Besluit

We reuse the besluit data model as described [in its application profile](https://data.vlaanderen.be/doc/applicatieprofiel/besluitvorming/). We use it to create AgendaPunt instances for all of the route sections that we can then publish on our LDES feed so they can be picked up by GN and modified/assigned to the correct Agenda instance, as desired.

We used as many predicates as possible from this domain, basing ourselves on the example decisions provided in the template, but not all properties may be present. Especially the mayor's approval gave us a hard time and we cut corners there.

### Besluit harvesting

Normally we would harvest the Besluit instances once the local governments publish them and then add them to our database. Since we don't expect actual Besluit instances to be published during this Hackathon, we added a mock endpoint to simulate this process. The mock endpoint simply adds the Besluit instance to our database as if it was harvested.

### Mu-Auth configuration

We currently put everything in the public graph. This is really bad, we should give every Association their own graph so they don't see/can't touch each-other's data. We still wanted mu-auth because:

- it gave us login functionality
- the form-content service requires you to be logged in to post forms
