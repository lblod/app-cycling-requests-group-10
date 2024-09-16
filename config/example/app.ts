import { app, query } from "mu";

app.get("/types-count", async (_req, res) => {
  try {
    const result = await query(`
      SELECT ?type (COUNT(?s) AS ?count)
      WHERE {
        ?s a ?type
      } ORDER BY DESC(?count)
    `);
    res.send(result.results.bindings);
  } catch (e) {
    res.status(500).send(e.message);
  }
});
