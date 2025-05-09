import { RouterContext } from "https://deno.land/x/oak@v12.6.1/mod.ts";
//import { ClinicInfo } from '../interfaces/clinic.interface.ts';

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

