// validateToken.ts
import { RouterContext } from "oak";
import {firebaseAdmin} from "../firebaseconfig/firebase.ts";

// Asegúrate de que sea la API Key de Firebase


export async function validateToken(ctx: RouterContext<"/api/validateToken">) {
  const { value } = await ctx.request.body({ type: "json" });
  const { idToken } = await value;

  try {
    // Verify the token using Firebase Admin
    const decodedToken = await firebaseAdmin.auth().verifyIdToken(idToken);
    // getAuth().verifyIdToken(idToken);
    
    // Get user details
    const userRecord = await firebaseAdmin.auth().getUser(decodedToken.uid);

    ctx.response.status = 200;
    ctx.response.body = {
      message: "El token es correcto",
      userData: userRecord,
    };
  } catch (error) {
    console.error("Error al validar el token:", error);
    ctx.response.status = 401;
    ctx.response.body = { message: "El token es incorrecto" };
  }
}