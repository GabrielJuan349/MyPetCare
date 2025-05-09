import { RouterContext } from "https://deno.land/x/oak@v12.6.1/mod.ts";
import { Clinic } from '../interfaces/clinic.interface.ts';

const FIREBASE_PROJECT_ID = Deno.env.get("FIREBASE_PROJECT_ID");
const FirestorePrescriptionURL = `https://firestore.googleapis.com/v1/projects/${FIREBASE_PROJECT_ID}/databases/(default)/documents/clinic`;


export async function getClinics(ctx: RouterContext<"/api/getClinics/:id">) {
    console.log("🐶 getClinics endpoint called");
    const id = ctx.params.id;
    if (!id) {
        ctx.response.status = 400;
        ctx.response.body = { error: "ID de clíncia no proporcionado" };
        return;
    }
    const getUrl = `${FirestorePrescriptionURL}/${id}`;
    const response = await fetch(getUrl);
    const result = await response.json();
  
    if (!response.ok || result.error) {
      ctx.response.status = 404;
      ctx.response.body = { error: "Clinica no encontrada" };
      return;
    }
    const fields = result.fields || {};
    const clinica = {
      id,
      ...Object.fromEntries(Object.entries(fields).map(([key, value]) => [key, Object.values(value)[0]]))
    };
  
    ctx.response.status = 200;
    ctx.response.body = clinica;
}

export async function createClinic(ctx: RouterContext<"/api/createClinic">) {
  console.log("Creando clínica");
  const { value } = await ctx.request.body({ type: "json" }); //Guardamos el body de la petición en uan variable
  const clinic : Clinic = await value;
  const response = await fetch(FirestorePrescriptionURL, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      fields: {
        address: { stringValue: clinic.address },
        categories: { arrayValue: { values: clinic.categories.map((category) => ({ stringValue: category })) } },
        city: { stringValue: clinic.city },
        cp: { stringValue: clinic.cp },
        email: { stringValue: clinic.email },
        geolocation: { arrayValue: { values: clinic.geolocation.map((geo) => ({ stringValue: geo })) } },
        name: { stringValue: clinic.name },
        phone: { stringValue: clinic.phone },
        website: { stringValue: clinic.website }
      }
    }),
  }); //realizamos la petición a la API de Firestore para crear la clinica
  const result = await response.json();
  ctx.response.status = response.ok ? 200 : 500; //si la respuesta es correcta, devolvemos el estado 200, si no, devolvemos el estado 500
  ctx.response.body = result;
}

// Eliminar clínica
export async function deleteClinic(ctx: RouterContext<"/api/deleteClinic/:id">) {
  console.log("deleteClinic endpoint called");

  const id = ctx.params.id;
  if (!id) {
    ctx.response.status = 400;
    ctx.response.body = { error: "ID de clínica no proporcionado" };
    return;
  }

  const deleteUrl = `${FirestorePrescriptionURL}/${id}`;
  console.log("URL de eliminación:", deleteUrl);

  const response = await fetch(deleteUrl, { method: "DELETE" });

  ctx.response.status = response.ok ? 200 : 500;
  ctx.response.body = response.ok
    ? { message: "Clínica eliminada correctamente", success: true }
    : { error: "Error eliminando la clínica" };
}

export async function getAllClinics(ctx: RouterContext<"/api/getClinics">) {
  console.log("📋 getAllClinics endpoint called");

  const getUrl = `https://firestore.googleapis.com/v1/projects/${FIREBASE_PROJECT_ID}/databases/(default)/documents/clinic`;

  const response = await fetch(getUrl, {
    method: "GET",
    headers: { "Content-Type": "application/json" }
  });

  const result = await response.json();

  if (!response.ok || result.error) {
    ctx.response.status = 500;
    ctx.response.body = { error: "Error al obtener clínicas", details: result.error };
    return;
  }

  const clinics = (result.documents || []).map((doc: any) => {
    const id = doc.name.split("/").pop();
    const fields = doc.fields || {};
    return {
      id,
      ...Object.fromEntries(Object.entries(fields).map(([k, v]) => [k, Object.values(v)[0]]))
    };
  });

  ctx.response.status = 200;
  ctx.response.body = clinics;
}



