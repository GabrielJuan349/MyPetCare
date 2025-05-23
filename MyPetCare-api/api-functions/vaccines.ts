import { RouterContext } from 'oak';
import { FirestoreBaseUrl } from './utils.ts';

// const PROJECT_ID = Deno.env.get("FIREBASE_PROJECT_ID");
const FireStoreVaccineUrl = `${FirestoreBaseUrl}/vaccines`;

export async function createVaccine(ctx: RouterContext<'/api/vaccine'>) {
  console.log('💉 createVaccine endpoint called');

  const { value } = await ctx.request.body({ type: 'json' });
  const vaccine = await value;

  const response = await fetch(FireStoreVaccineUrl, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      fields: {
        Date: { stringValue: vaccine.Date }, // guarda la fecha como string, e.g. "2025-05-03"
        PetId: { stringValue: vaccine.PetId }, // id de la mascota
        name: { stringValue: vaccine.name }, // nombre de la vacuna
      },
    }),
  });

  const result = await response.json();

  if (!response.ok) {
    console.error('Error creating vaccine:', result);
    ctx.response.status = 500;
    ctx.response.body = { error: result.error?.message || 'Error al registrar vacuna' };
    return;
  }

  ctx.response.status = 200;
  ctx.response.body = { message: 'Vaccine created successfully!', id: result.name };
}

export async function getVaccineByPetID(ctx: RouterContext<'/api/getVaccineByPetID/pet/:id'>) {
  const id = ctx.params.id;
  const res = await fetch(FireStoreVaccineUrl);
  const data = await res.json();

  const mapFirestore = (doc: any) => {
    // Ajusta esta función según el formato Firestore que uses
    const fields = doc.fields || {};
    return {
      id: doc.name.split('/').pop(),
      Date: fields.Date?.stringValue || '',
      PetId: fields.PetId?.stringValue || '',
      name: fields.name?.stringValue || '',
    };
  };

  const filtered = (data.documents || [])
    .map(mapFirestore)
    .filter((v) => v.PetId === id);

  ctx.response.body = filtered;
}
