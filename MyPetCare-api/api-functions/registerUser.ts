import { RouterContext } from "https://deno.land/x/oak@v12.6.1/mod.ts";
import "https://deno.land/std@0.213.0/dotenv/load.ts";
import { User } from "../interfaces/user.interface.ts";
import { db } from "../firebaseconfig/firebase.ts";

// 👉 Función que guarda datos en Firestore
async function saveUserToFirestore(user: User) {
  try {
    const usersRef = db.collection("users");
    console.log("💾 Guardando usuario en Firestore...");

    // Crear un nuevo documento con ID automático
    const newUserRef = await usersRef.add({
      email: user.email,
      firstName: user.firstName,
      lastName: user.lastName,
      phone: user.phone,
      accountType: user.accountType,
      clinicInfo: user.clinicInfo ?? null,
      createdAt: new Date(), // Añadimos fecha de creación
    });

    console.log("✅ Usuario guardado con ID:", newUserRef.id);
    return newUserRef.id;

  } catch (error) {
    console.error("❌ Error al guardar el usuario en Firestore:", error.message, error.stack);
    return null; // o lanzar de nuevo el error si prefieres
  }
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
      message: "✅ Usuario registrado con éxito",
      ...userData,
    };
  } catch (error) {
    console.error("❌ Error al registrar el usuario:", error);
    ctx.response.status = 500;
    ctx.response.body = {
      error: "Error interno al registrar el usuario",
    };
  }
}
