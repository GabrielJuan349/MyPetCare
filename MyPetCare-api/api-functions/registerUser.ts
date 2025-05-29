import { RouterContext } from "https://deno.land/x/oak@v12.6.1/mod.ts";
import "https://deno.land/std@0.213.0/dotenv/load.ts";
import {User} from "../interfaces/user.interface.ts";

 // Asegúrate de que sea la API Key de Firebase
const FIREBASE_PROJECT_ID = Deno.env.get("FIREBASE_PROJECT_ID"); // Asegúrate de que sea el ID del proyecto de Firebase

const FireStoreUrl = `https://firestore.googleapis.com/v1/projects/${FIREBASE_PROJECT_ID}/databases/(default)/documents/users`;

async function saveUserToFirestore(user: any) {
  const firestoreData = {
    fields: {
      email: { stringValue: user.email },
      firstName: { stringValue: user.firstName },
      lastName: { stringValue: user.lastName },
      phone: { stringValue: user.phone },
      accountType: { stringValue: user.accountType },
      locality: {stringValue: user.locality},
      clinicInfo: user.clinicInfo 
        ? { stringValue: user.clinicInfo } 
        : { nullValue: null },
    },
  };

  // Use firebase auth uid as Document ID in firestore
  const response = await fetch(`${FireStoreUrl}?documentId=${user.userId}`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(firestoreData),
  });

  const result = await response.json();
  if (!response.ok) {
    throw new Error(result.error?.message || "Error al guardar datos en Firestore");
  }

  return result;
}


// 👉 Handler principal
export async function registerUser(ctx: RouterContext<"/api/registerUser">) {
  try {
    const { value } = await ctx.request.body({ type: "json" });

    const userData: User = await value;

    console.log("💾 Guardando usuario en Firestore...");
    await saveUserToFirestore(userData);

    ctx.response.status = 200;
    ctx.response.body = {
      message: "Usuario registrado con éxito en Firebase y Firestore",
      userId: userData.userId,
      email: userData.email,
      phone: userData.phone,
      firstName: userData.firstName,
      lastName: userData.lastName,
      accountType: userData.accountType,
      locality: userData.locality,
      clinicInfo: userData.clinicInfo,
    };
  } catch (error) {
    console.error("❌ Error al registrar el usuario:", error);
    ctx.response.status = 500;
  }
}