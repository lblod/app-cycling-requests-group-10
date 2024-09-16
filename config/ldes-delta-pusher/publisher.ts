import { query, sparqlEscapeUri, sparqlEscape } from "mu";
import { LDES_ENDPOINT } from "../config";
import fetch from "node-fetch";
import { log } from "./logger";

export type LDES_TYPE = "public" | "abb" | "internal";
export type TypesWithFilter = {
  [key in LDES_TYPE]: {
    filter?: string;
  };
};
export type InterestingSubject = {
  uri: string;
  type: string;
  filter?: string;
};

const fetchSubjectData = async (subject: InterestingSubject) => {
  // simply publish everything on the ldes for now
  const data = await query(`
    PREFIX ext: <http://mu.semte.ch/vocabularies/ext/>
    CONSTRUCT {
      <${subject.uri}> ?p ?o .
      <${subject.uri}> ext:relatedTo ?bestuurseenheid .
    } WHERE {
      <${subject.uri}> ?p ?o .
    }
  `);
  return data.results.bindings.map(bindingToTriple).join("\n");
};

async function sendLDESRequest(body: string, retriesLeft = 3) {
  log(`Sending data to LDES endpoint ${LDES_ENDPOINT}`, "debug");
  await fetch(`${LDES_ENDPOINT}`, {
    method: "POST",
    headers: {
      "Content-Type": "text/turtle",
    },
    // xsd prefix is used in the types of the result data, so it needs to be declared.
    body: `@prefix xsd: <http://www.w3.org/2001/XMLSchema#> .\n${body}`,
  }).catch(async (e) => {
    if (retriesLeft > 0) {
      log(`Error sending data to LDES endpoint (retrying): ${e}`, "error");
      sendLDESRequest(body, retriesLeft - 1);
    } else {
      log(`Error sending data to LDES endpoint: ${e}`, "error");
    }
  });
}

const datatypeNames = {
  "http://www.w3.org/2001/XMLSchema#dateTime": "dateTime",
  "http://www.w3.org/2001/XMLSchema#date": "date",
  "http://www.w3.org/2001/XMLSchema#decimal": "decimal",
  "http://www.w3.org/2001/XMLSchema#integer": "int",
  "http://www.w3.org/2001/XMLSchema#float": "float",
  "http://www.w3.org/2001/XMLSchema#boolean": "bool",
};
const sparqlEscapeObject = (bindingObject): string => {
  const escapeType = datatypeNames[bindingObject.datatype] || "string";
  return bindingObject.type === "uri"
    ? sparqlEscapeUri(bindingObject.value)
    : sparqlEscape(bindingObject.value, escapeType);
};

const bindingToTriple = (binding) =>
  `${sparqlEscapeUri(binding.s.value)} ${sparqlEscapeUri(
    binding.p.value
  )} ${sparqlEscapeObject(binding.o)} .`;

const streamTargets: Record<LDES_TYPE, string[]> = {
  public: ["public", "abb", "internal"],
  abb: ["abb", "internal"],
  internal: ["internal"],
};

/**
 * Publish the currently known info for the given subject URI to the LDES endpoint of the given type
 * @param ldesType the type of the LDES endpoint to publish to (e.g. "public" or "abb")
 * @param subject the uri of the subject to fetch data for and publish
 */
export const publish = async (subject: InterestingSubject) => {
  const data = await fetchSubjectData(subject);
  log(`Publishing data for subject ${subject.uri}:\n${data}`, "debug");
  return sendLDESRequest(data).catch((e) => {
    log(
      `Error publishing data for subject ${subject.uri} to LDES endpoint: ${e}`,
      "error"
    );
  });
};
