import { Changeset } from "../types";
import { query } from "mu";
import { publishInterestingSubjects } from "./handle-types-util";
import { InterestingSubject, LDES_TYPE, TypesWithFilter } from "./publisher";

const regularTypesToLDESMapping: {
  [key: string]: true;
} = {
  "cycling:GoedkeuringDoorGemeente": true,
  "besluit:Agendapunt": true,
  "sign:PublishedResource": true,
};

export const publishTypeOnLDES = (type: string) => {
  return regularTypesToLDESMapping[type];
};

const keepRegularTypesQuery = async (
  subjects: string[]
): Promise<InterestingSubject[]> => {
  const types = Object.keys(regularTypesToLDESMapping);
  const matches = await query(`
      SELECT DISTINCT ?s ?type WHERE {
        ?s a ?type .
        VALUES ?type { ${types.map((type) => `<${type}>`).join(" ")} }
        VALUES ?s { ${[...subjects]
          .map((subject) => `<${subject}>`)
          .join(" ")} }
      }
    `);
  return matches.results.bindings
    .map((binding) => {
      const shouldPublish = publishTypeOnLDES(binding.type.value);
      if (!shouldPublish) {
        return null;
      }
      return { uri: binding.s.value, type: binding.type.value };
    })
    .filter((b) => !!b);
};

export const handleRegularTypes = async (changesets: Changeset[]) => {
  await publishInterestingSubjects(changesets, keepRegularTypesQuery);
};
