import {db} from "../firebaseconfig/firebase.ts";
import { RouterContext } from "https://deno.land/x/oak@v12.6.1/mod.ts";

export async function getRecipeOnce(ctx: RouterContext<"/api/getprescription/:id">) {
    try {
      const id = ctx.params.id!;
      const docRef = db.collection("prescriptions").doc(id);
      console.log("docRef:", docRef.id);
      if (!docRef) {
        throw new Error("docRef no está definido correctamente");
      }
      const doc = await docRef.get();
        console.log("Receta:", doc.data());
      if (!doc.exists) {
        ctx.response.status = 404;
        ctx.response.body = { error: "Receta no encontrada" };
        return;
      }
  
      const data = doc.data();
  
      // Borrar tras mostrar
      await docRef.delete();
  
      ctx.response.status = 200;
      ctx.response.body = data;
    } catch (error) {
      console.error("❌ Error al obtener receta:", error);
      ctx.response.status = 500;
      ctx.response.body = { error: "Error al obtener receta" };
    }
  }
  