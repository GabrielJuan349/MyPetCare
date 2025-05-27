import { RouterContext } from "https://deno.land/x/oak@v12.6.1/mod.ts";
import { Report } from "../interfaces/report.interface.ts";

const PROJECT_ID = Deno.env.get("FIREBASE_PROJECT_ID");
const FirestoreReportURL = `https://firestore.googleapis.com/v1/projects/${PROJECT_ID}/databases/(default)/documents/report`;

function mapFirestore(doc: any) {
  const fields = doc.fields || {};
  return {
    id: doc.name.split("/").pop(),
    ...Object.fromEntries(
      Object.entries(fields).map(([k, v]) => [k, Object.values(v)[0]])
    ),
  };
}

// Create
export async function createReport(ctx: RouterContext<"/api/createReport">) {
  const { value } = await ctx.request.body({ type: "json" });
  const report: Report = await value;
  const now = new Date();

  const res = await fetch(FirestoreReportURL, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      fields: {
        id_pet: { stringValue: report.id_pet },
        id_vet: { stringValue: report.id_vet },
        name: { stringValue: report.name },
        text: { stringValue: report.text },
        createdAt: {timestampValue:  now.toISOString()},
      },
    }),
  });

  const result = await res.json();
  ctx.response.status = res.ok ? 200 : 500;
  ctx.response.body = result;
}

// Get by ID
export async function getReportById(ctx: RouterContext<"/api/getReportById/:id">) {
  const id = ctx.params.id;
  const res = await fetch(`${FirestoreReportURL}/${id}`);
  const result = await res.json();

  ctx.response.status = res.ok ? 200 : 404;
  ctx.response.body = res.ok ? mapFirestore(result) : { error: "Not found" };
}

// Get by id_pet
export async function getReportsByPet(ctx: RouterContext<"/api/getReportsByPet/pet/:id">) {
  console.log("getReportsByPet called");
  const id = ctx.params.id;
  const res = await fetch(FirestoreReportURL);
  const data = await res.json();

  const filtered = (data.documents || [])
    .map(mapFirestore)
    .filter((r) => r.petId === id);

  ctx.response.body = filtered;
}


// Get by id_vet
export async function getReportsByVet(ctx: RouterContext<"/api/getReportsByVet/vet/:id">) {
  const id = ctx.params.id;
  const res = await fetch(FirestoreReportURL);
  const data = await res.json();

  const filtered = (data.documents || [])
    .map(mapFirestore)
    .filter((r) => r.id_vet === id);

  ctx.response.body = filtered;
}

// Delete
export async function deleteReport(ctx: RouterContext<"/api/deleteReport/:id">) {
  const id = ctx.params.id;
  const res = await fetch(`${FirestoreReportURL}/${id}`, { method: "DELETE" });

  ctx.response.status = res.ok ? 200 : 500;
  ctx.response.body = res.ok ? { success: true } : { error: "Delete failed" };
}
