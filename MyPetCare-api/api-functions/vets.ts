import { RouterContext } from 'oak';
import { Vet } from '../interfaces/vets.interface.ts';
import { FirestoreBaseUrl, FirestoreQueryUrl } from './utils.ts';

// const PROJECT_ID = Deno.env.get("FIREBASE_PROJECT_ID");
const FirestoreVetURL = `${FirestoreBaseUrl}/vets`;

export async function createVet(ctx: RouterContext<'/api/createVet'>) {
  console.log('Creando veterinario');
  const { value } = await ctx.request.body({ type: 'json' });
  const vet: Vet = await value;

  const response = await fetch(FirestoreVetURL, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      fields: {
        Specialities: {
          arrayValue: {
            values: vet.specialities.map((s) => ({ stringValue: s })),
          },
        },
        clinicId: { stringValue: vet.clinicId },
        firstName: { stringValue: vet.firstName },
        lastName: { stringValue: vet.lastName },
        workingHours: {
          mapValue: {
            fields: Object.fromEntries(
              Object.entries(vet.workingHours).map(([day, hours]) => [
                day,
                {
                  mapValue: {
                    fields: {
                      start: { stringValue: hours.start },
                      end: { stringValue: hours.end },
                    },
                  },
                },
              ]),
            ),
          },
        },
      },
    }),
  });

  const result = await response.json();
  ctx.response.status = response.ok ? 200 : 500;
  ctx.response.body = result;
}

export async function getVetById(ctx: RouterContext<'/api/getVet/:id'>) {
  const id = ctx.params.id;
  if (!id) {
    ctx.response.status = 400;
    ctx.response.body = { error: 'ID de veterinario no proporcionado' };
    return;
  }

  const getUrl = `${FirestoreVetURL}/${id}`;
  const response = await fetch(getUrl);
  const result = await response.json();

  if (!response.ok || result.error) {
    ctx.response.status = 404;
    ctx.response.body = { error: 'Veterinario no encontrado' };
    return;
  }

  const fields = result.fields || {};
  const vet = {
    id,
    ...Object.fromEntries(
      Object.entries(fields).map(([key, value]) => [key, Object.values(value)[0]]),
    ),
  };

  ctx.response.status = 200;
  ctx.response.body = vet;
}

export async function getVetsByClinic(ctx: RouterContext<'/api/getVetsByClinic/:clinicId'>) {
  const clinicId = ctx.params.clinicId;
  if (!clinicId) {
    ctx.response.status = 400;
    ctx.response.body = { error: 'ID de clinica no proporcionado' };
    return;
  }

  const query = {
    structuredQuery: {
      from: [{ collectionId: 'vets' }],
      where: {
        fieldFilter: {
          field: { fieldPath: 'clinicId' },
          op: 'EQUAL',
          value: { stringValue: clinicId },
        },
      },
    },
  };

  // const queryUrl = `https://firestore.googleapis.com/v1/projects/${FIREBASE_PROJECT_ID}/databases/(default)/documents:runQuery`;
  const response = await fetch(FirestoreQueryUrl, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(query),
  });

  const result = await response.json();

  const vets = result
    .filter((entry: any) => entry.document)
    .map((entry: any) => ({
      id: entry.document.name.split('/').pop(),
      ...Object.fromEntries(
        Object.entries(entry.document.fields).map(([key, value]) => [key, Object.values(value)[0]]),
      ),
    }));

  ctx.response.status = 200;
  ctx.response.body = vets;
}

export async function deleteVet(ctx: RouterContext<'/api/deleteVet/:id'>) {
  const id = ctx.params.id;
  const deleteUrl = `${FirestoreVetURL}/${id}`;
  const response = await fetch(deleteUrl, { method: 'DELETE' });

  ctx.response.status = response.ok ? 200 : 500;
  ctx.response.body = await response.json();
}
