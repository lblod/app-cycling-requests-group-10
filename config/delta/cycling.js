export default [
    {
      match: {
        object: {
          type: "uri",
          value: "http://data.vlaanderen.be/ns/besluit#Besluit",
        },
      },
      callback: {
        url: "http://cycling-application-request-service/delta",
        method: "POST",
      },
      options: {
        resourceFormat: "v0.0.1",
        gracePeriod: 1000,
        retry: 0,
        ignoreFromSelf: true,
        retryTimeout: 250,
      },
    },
  ];