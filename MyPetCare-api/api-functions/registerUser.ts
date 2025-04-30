import { RouterContext } from "https://deno.land/x/oak@v12.6.1/mod.ts";
import "https://deno.land/std@0.213.0/dotenv/load.ts";
import { User } from "../interfaces/user.interface.ts";
import { db } from "../firebaseconfig/firebase.ts"; // Asegúrate que db se inicializa correctamente aquí

// 👉 Función que guarda datos en Firestore
async function saveUserToFirestore(user: User) {
  // 👇 Log para verificar los datos que llegan a la función
  console.log("📄 Datos recibidos para guardar:", JSON.stringify(user, null, 2));

  // 👇 Validar datos básicos (opcional pero recomendado)
  if (!user || !user.email || !user.firstName || !user.lastName) {
      console.error("❌ Datos de usuario incompletos o inválidos.");
      return null;
  }

  try {
    const usersRef = db.collection("users");
    console.log("🔥 Intentando añadir documento a la colección 'users'...");

    // Crear un nuevo documento con ID automático
    const userDataToSave = {
      email: user.email,
      firstName: user.firstName,
      lastName: user.lastName,
      phone: user.phone,
      accountType: user.accountType,
      clinicInfo: user.clinicInfo ?? null, // Asegura que clinicInfo sea null si no se proporciona
      createdAt: new Date(),
    };

    // 👇 Log de los datos exactos que se enviarán a Firestore
    console.log("💾 Datos a guardar:", JSON.stringify(userDataToSave, null, 2));

    const newUserRef = await usersRef.add(userDataToSave);

    // Si llega aquí, la operación add tuvo éxito a nivel de cliente
    console.log("✅ Documento añadido con ID:", newUserRef.id);
    return newUserRef.id; // Devuelve el ID del nuevo documento

  } catch (error) {
    console.error("❌ Error DETALLADO al intentar guardar en Firestore:");
    // 👇 Loggear más detalles del error
    if (error instanceof Error) {
        console.error("  Mensaje:", error.message);
        console.error("  Stack:", error.stack);
    } else {
        console.error("  Error (objeto completo):", error);
    }
    // Considera si necesitas devolver null o relanzar el error
    return null;
  }
}

// 👉 Handler principal (modificado para loggear datos de entrada)
export async function registerUser(ctx: RouterContext<"/api/registerUser">) {
  try {
    const { value } = await ctx.request.body({ type: "json" });
    const userData: User = await value;

    // 👇 Log para ver qué datos llegan desde la petición HTTP
    console.log("📬 Datos recibidos en el handler:", JSON.stringify(userData, null, 2));

    // Llamada a la función de guardado (sin cambios aquí respecto a la versión anterior)
    const userId = await saveUserToFirestore(userData);

    // 👇 Comprueba si el guardado fue exitoso
    if (userId) {
      ctx.response.status = 200;
      // 👇 Evitar duplicados en la respuesta
      ctx.response.body = {
        message: "✅ Usuario registrado con éxito",
        userId: userId,
      };
    } else {
      // Si userId es null, hubo un error al guardar
      ctx.response.status = 500;
      ctx.response.body = {
        error: "Error interno al guardar el usuario en la base de datos",
      };
    }
  } catch (error) {
    // 👇 Comprobar si error es una instancia de Error
    if (error instanceof Error) {
        console.error("❌ Error en el handler registerUser:", error.message, error.stack);
    } else {
        console.error("❌ Error desconocido en el handler registerUser:", error);
    }
    ctx.response.status = 500;
    ctx.response.body = {
      error: "Error interno al registrar el usuario",
    };
  }
}
