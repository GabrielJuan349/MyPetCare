import { RouterContext } from 'oak';
import { Adoption } from '../interfaces/adoption.interface.ts';
import { FirestoreBaseUrl } from './utils.ts';

const PROJECT_ID = Deno.env.get('FIREBASE_PROJECT_ID');
const BASE_URL = FirestoreBaseUrl + '/adoption';

function mapFirestore(doc: any) {
  const data = doc.fields;
  return {
    id: doc.name.split('/').pop(),
    ...Object.fromEntries(
      Object.entries(data).map(([k, v]) => [k, Object.values(v)[0]]),
    ),
  };
}

// Crear adopción
export async function createAdoption(ctx: RouterContext<'/api/createAdoption'>) {
  const { value } = await ctx.request.body({ type: 'json' });
  const adoption: Adoption = await value;

  const res = await fetch(BASE_URL, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      fields: {
        name: { stringValue: adoption.name },
        age: { integerValue: adoption.age },
        type: { stringValue: adoption.type },
        description: { stringValue: adoption.description },
        email: { stringValue: adoption.email },
        dateFound: { timestampValue: new Date(adoption.dateFound).toISOString() },
        clinic_id: { stringValue: adoption.clinic_id },
        createdAt: { timestampValue: adoption.createdAt || new Date().toISOString() },
      },
    }),
  });

  const result = await res.json();
  ctx.response.status = res.ok ? 200 : 500;
  ctx.response.body = result;
}

// Obtener todas
export async function getAllAdoptions(ctx: RouterContext<'/api/getAllAdoptions'>) {
  const res = await fetch(BASE_URL);
  const result = await res.json();

  const mapped = (result.documents || []).map(mapFirestore);
  ctx.response.status = 200;
  ctx.response.body = mapped;
}

// Obtener por ID
export async function getAdoptionById(ctx: RouterContext<'/api/getAdoptionById/:id'>) {
  const id = ctx.params.id;
  const res = await fetch(`${BASE_URL}/${id}`);
  const result = await res.json();

  ctx.response.status = res.ok ? 200 : 404;
  ctx.response.body = res.ok ? mapFirestore(result) : { error: 'No encontrado' };
}

// Actualizar por ID
export async function updateAdoption(ctx: RouterContext<'/api/updateAdoption/:id'>) {
  const id = ctx.params.id;
  const { value } = await ctx.request.body({ type: 'json' });
  const update = await value;

  const fields: any = {};
  const updateMask: string[] = [];

  for (const [key, val] of Object.entries(update)) {
    updateMask.push(key);
    if (typeof val === 'number') {
      fields[key] = { integerValue: val };
    } else if (key === 'dateFound') {
      fields[key] = { timestampValue: new Date(val).toISOString() };
    } else {
      fields[key] = { stringValue: val };
    }
  }

  const url = `${BASE_URL}/${id}?` + updateMask.map((f) => `updateMask.fieldPaths=${f}`).join('&');

  const res = await fetch(url, {
    method: 'PATCH',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ fields }),
  });

  const result = await res.json();
  ctx.response.status = res.ok ? 200 : 500;
  ctx.response.body = result;
}

// Eliminar por ID
export async function deleteAdoption(ctx: RouterContext<'/api/deleteAdoption/:id'>) {
  const id = ctx.params.id;
  const res = await fetch(`${BASE_URL}/${id}`, { method: 'DELETE' });

  ctx.response.status = res.ok ? 200 : 500;
  ctx.response.body = res.ok
    ? { success: true, message: 'Adopción eliminada' }
    : { error: 'Error al eliminar' };
}

// Obtener adopciones por clinic_id
export async function getAdoptionsByClinic(ctx: RouterContext<'/api/getAdoptionsByClinic/:id'>) {
  const clinicId = ctx.params.id;
  if (!clinicId) {
    ctx.response.status = 400;
    ctx.response.body = { error: 'Clinic ID no proporcionado' };
    return;
  }

  const url =
    `https://firestore.googleapis.com/v1/projects/${PROJECT_ID}/databases/(default)/documents:runQuery`;

  const queryBody = {
    structuredQuery: {
      from: [{ collectionId: 'adoption' }],
      where: {
        fieldFilter: {
          field: { fieldPath: 'clinic_id' },
          op: 'EQUAL',
          value: { stringValue: clinicId },
        },
      },
    },
  };

  const response = await fetch(url, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(queryBody),
  });

  const results = await response.json();

  if (!response.ok || !Array.isArray(results)) {
    ctx.response.status = 500;
    ctx.response.body = { error: 'Error al obtener adopciones por clínica' };
    return;
  }

  const adoptions = results
    .filter((entry) => entry.document)
    .map((entry) => mapFirestore(entry.document));

  ctx.response.status = 200;
  ctx.response.body = adoptions;
}
