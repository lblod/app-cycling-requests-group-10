import { Changeset } from "../types";
import { handleRegularTypes } from "./handle-regular-types";

// modified from the lmb config, keeping only regular types setup
export default async function dispatch(changesets: Changeset[]) {
  handleRegularTypes(changesets);
}
