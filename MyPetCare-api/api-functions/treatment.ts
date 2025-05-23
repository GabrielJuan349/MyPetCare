import { RouterContext } from 'oak';
import { Treatment } from '../interfaces/treatment.interface.ts';
import { FirestoreBaseUrl } from './utils.ts';

// const PROJECT_ID = Deno.env.get("FIREBASE_PROJECT_ID");
const FirestoreTreatmentURL = `${FirestoreBaseUrl}/treatment`;

function mapFirestore(doc: any) {
  const fields = doc.fields || {};
  return {
    id: doc.name.split('/').pop(),
    ...Object.fromEntries(
      Object.entries(fields).map(([k, v]) => [k, Object.values(v)[0]]),
    ),
  };
}

// Create
export async function createTreatment(ctx: RouterContext<'/api/createTreatment'>) {
  const { value } = await ctx.request.body({ type: 'json' });
  const treatment: Treatment = await value;

  const now = new Date();
  const endDate = new Date(now);
  endDate.setDate(now.getDate() + 13); // sumamos 13 días a la fecha actual

  const res = await fetch(FirestoreTreatmentURL, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      fields: {
        id_pet: { stringValue: treatment.id_pet },
        id_vet: { stringValue: treatment.id_vet },
        name: { stringValue: treatment.name },
        date_start: { timestampValue: now.toISOString() },
        date_end: { timestampValue: endDate.toISOString() },
        createdAt: { timestampValue: now.toISOString() },
      },
    }),
  });

  const result = await res.json();
  ctx.response.status = res.ok ? 200 : 500;
  ctx.response.body = result;
}

// Get by ID
//not will be used
export async function getTreatmentById(ctx: RouterContext<'/api/getTreatmentById/:id'>) {
  await cleanExpiredTreatments();
  const id = ctx.params.id;
  const res = await fetch(`${FirestoreTreatmentURL}/${id}`);
  const result = await res.json();

  ctx.response.status = res.ok ? 200 : 404;
  ctx.response.body = res.ok ? mapFirestore(result) : { error: 'Not found' };
}

// Get by id_pet
export async function getTreatmentsByPet(ctx: RouterContext<'/api/getTreatmentsByPet/pet/:id'>) {
  await cleanExpiredTreatments();
  const id = ctx.params.id;
  const res = await fetch(FirestoreTreatmentURL);
  const data = await res.json();

  const filtered = (data.documents || [])
    .map(mapFirestore)
    .filter((r) => r.id_pet === id);

  ctx.response.body = filtered;
}

// Get by id_vet
export async function getTreatmentsByVet(ctx: RouterContext<'/api/getTreatmentsByVet/vet/:id'>) {
  await cleanExpiredTreatments();
  const id = ctx.params.id;
  const res = await fetch(FirestoreTreatmentURL);
  const data = await res.json();

  const filtered = (data.documents || [])
    .map(mapFirestore)
    .filter((r) => r.id_vet === id);

  ctx.response.body = filtered;
}

// Delete
export async function deleteTreatment(ctx: RouterContext<'/api/deleteTreatment/:id'>) {
  const id = ctx.params.id;
  const res = await fetch(`${FirestoreTreatmentURL}/${id}`, { method: 'DELETE' });

  ctx.response.status = res.ok ? 200 : 500;
  ctx.response.body = res.ok ? { success: true } : { error: 'Delete failed' };
}

export async function cleanExpiredTreatments(): Promise<number> {
  const now = new Date();
  const res = await fetch(FirestoreTreatmentURL);
  const data = await res.json();

  const toDelete = (data.documents || []).filter((doc: any) => {
    const endDate = new Date(doc.fields?.date_end?.timestampValue);
    return endDate < now;
  });

  for (const doc of toDelete) {
    const id = doc.name.split('/').pop();
    await fetch(`${FirestoreTreatmentURL}/${id}`, { method: 'DELETE' });
  }

  return toDelete.length;
}
