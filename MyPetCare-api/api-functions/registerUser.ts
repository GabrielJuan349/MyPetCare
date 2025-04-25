import { RouterContext } from "https://deno.land/x/oak@v12.6.1/mod.ts";
import "https://deno.land/std@0.213.0/dotenv/load.ts";
import {User} from "../interfaces/user.interface.ts";


// Obtén la clave de la API desde las variables de entorno
const FIREBASE_API_KEY = Deno.env.get("FIREBASE_API_KEY"); // Asegúrate de que sea la API Key de Firebase
const FIREBASE_PRIVATE_KEY = Deno.env.get("FIREBASE_PROJECT_ID"); // Asegúrate de que sea el ID del proyecto de Firebase

// URL de registro de Firebase
const signUpUrl = `https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=${FIREBASE_API_KEY}`;
const FireStoreUrl = `https://firestore.googleapis.com/v1/projects/${FIREBASE_PRIVATE_KEY}/databases/(default)/documents/users`;


// 👉 Función que registra en Firebase Auth
async function registerWithFirebase(userData: any) {
  const response = await fetch(signUpUrl, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      email: userData.email,
      password: userData.password,
      returnSecureToken: true,
    }),
  });

  const result = await response.json();
  if (!response.ok) {
    throw new Error(result.error?.message || "Error al registrar en Firebase Auth");
  }

  return result;
}

// 👉 Función que guarda datos en Firestore
async function saveUserToFirestore(user: any) {
  const firestoreData = {
    fields: {
      userId: { stringValue: user.userId },
      email: { stringValue: user.email },
      firstName: { stringValue: user.firstName },
      lastName: { stringValue: user.lastName },
      phone: { stringValue: user.phone },
      accountType: { stringValue: user.accountType },
      clinicInfo: { stringValue: user.clinicInfo },
    },
  };

  const response = await fetch(FireStoreUrl, {
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

    console.log("📤 Registrando usuario en Firebase Auth...");
    const firebaseResult = await registerWithFirebase(userData);

    console.log("💾 Guardando usuario en Firestore...");
    await saveUserToFirestore(userData);

    ctx.response.status = 200;
    ctx.response.body = {
      message: "Usuario registrado con éxito en Firebase y Firestore",
      userId: userData.userId,
      email: firebaseResult.email,
      idToken: firebaseResult.idToken,
      phone: userData.phone,
      firstName: userData.firstName,
      lastName: userData.lastName,
      accountType: userData.accountType,
      clinicInfo: userData.clinicInfo,
    };
  } catch (error) {
    console.error("❌ Error al registrar el usuario:", error);
    ctx.response.status = 500;
  }
}
