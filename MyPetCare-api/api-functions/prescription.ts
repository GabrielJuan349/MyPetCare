import { RouterContext } from "https://deno.land/x/oak@v12.6.1/mod.ts";
import {Prescription} from "../interfaces/prescription.interface.ts";

const FIREBASE_PROJECT_ID = Deno.env.get("FIREBASE_PROJECT_ID");
const FirestorePrescriptionURL = `https://firestore.googleapis.com/v1/projects/${FIREBASE_PROJECT_ID}/databases/(default)/documents/prescription`;


function mapFirestore(doc: any) {
  const fields = doc.fields || {};
  return {
    id: doc.name.split("/").pop(),
    ...Object.fromEntries(
      Object.entries(fields).map(([k, v]) => [k, Object.values(v)[0]])
    ),
  };
}

// Crear receta (funciona bien)
export async function createPrescription(ctx: RouterContext<"/api/prescription">) {
  console.log("Creando receta");
  const { value } = await ctx.request.body({ type: "json" }); //Guardamos el body de la petición en uan variable
  const prescription : Prescription = await value;

  const response = await fetch(FirestorePrescriptionURL, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      fields: {
        name: { stringValue: prescription.name },
        archivo: { stringValue: prescription.archivo },
        id_pet: { stringValue: prescription.id_pet },
        id_vet: { stringValue: prescription.id_vet },
        createdAt: { timestampValue: prescription.createdAt || new Date().toISOString() },
      }
    }),
  }); //realizamos la petición a la API de Firestore para crear una receta
  const result = await response.json();
  ctx.response.status = response.ok ? 200 : 500; //si la respuesta es correcta, devolvemos el estado 200, si no, devolvemos el estado 500
  ctx.response.body = result;
}

// Obtener receta por ID (funciona bien)
export async function getPrescription(ctx: RouterContext<"/api/getPrescription/:id">) {
    const id = ctx.params.id;
    if (!id) {
      ctx.response.status = 400;
      ctx.response.body = { error: "ID de receta no proporcionado" };
      return;
    }
  
    const getUrl = `${FirestorePrescriptionURL}/${id}`;
    const response = await fetch(getUrl);
    const result = await response.json();
  
    if (!response.ok || result.error) {
      ctx.response.status = 404;
      ctx.response.body = { error: "Receta no encontrada" };
      return;
    }
  
    const fields = result.fields || {};
    const receta = {
      id,
      ...Object.fromEntries(Object.entries(fields).map(([key, value]) => [key, Object.values(value)[0]]))
    };
  
    ctx.response.status = 200;
    ctx.response.body = receta;
  }


// Editar receta
export async function updatePrescription(ctx: RouterContext<"/api/putPrescription/:id">) {
    console.log("✏️ Actualizando receta...");
  
    const id = ctx.params.id;
    if (!id) {
      ctx.response.status = 400;
      ctx.response.body = { error: "ID de receta no proporcionado" };
      return;
    }
  
    const { value } = await ctx.request.body({ type: "json" });
    const receta = await value;
  
    const allowedFields = ["name", "archivo", "id_pet", "id_vet"];
    const fields: Record<string, any> = {};
    const updateMask: string[] = [];
  
    for (const field of allowedFields) {
      if (receta[field] !== undefined && receta[field] !== null) {
        fields[field] = { stringValue: receta[field] };
        updateMask.push(field);
      }
    }
  
    if (updateMask.length === 0) {
      ctx.response.status = 400;
      ctx.response.body = { error: "No se proporcionaron campos válidos para actualizar" };
      return;
    }
  
    const updateUrl = `https://firestore.googleapis.com/v1/projects/${FIREBASE_PROJECT_ID}/databases/(default)/documents/prescription/${id}?` +
      updateMask.map((f) => `updateMask.fieldPaths=${f}`).join("&");
  
    console.log("URL:", updateUrl);
    console.log("Payload:", JSON.stringify({ fields }));
  
    const response = await fetch(updateUrl, {
      method: "PATCH",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ fields }),
    });
  
    const rawText = await response.text();
    let result;
    try {
      result = JSON.parse(rawText);
    } catch {
      result = { raw: rawText };
    }
  
    if (!response.ok) {
      ctx.response.status = 500;
      ctx.response.body = {
        error: "Error actualizando la receta",
        details: result,
      };
      return;
    }
  
    ctx.response.status = 200;
    ctx.response.body = {
      message: "Receta actualizada correctamente",
      updated: result,
    };
  }

  export async function getPrescriptionByPet(ctx: RouterContext<"/api/getPrescriptionByPet/pet/:id">) {
    const id = ctx.params.id;
    const res = await fetch(FirestorePrescriptionURL);
    const data = await res.json();
  
    const filtered = (data.documents || [])
      .map(mapFirestore)
      .filter((r) => r.id_pet === id);
  
    ctx.response.body = filtered;
  }
  
  


// Eliminar receta
export async function deletePrescription(ctx: RouterContext<"/api/deletePrescription/:id">) {
  const id = ctx.params.id;
  const deleteUrl = `${FirestorePrescriptionURL}/${id}`;

  const response = await fetch(deleteUrl, { method: "DELETE" });

  ctx.response.status = response.ok ? 200 : 500;
  ctx.response.body = response.ok
    ? { success: true }
    : { error: "Error eliminando receta" };
}


