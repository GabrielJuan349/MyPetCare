import { RouterContext } from "https://deno.land/x/oak@v12.6.1/mod.ts";
import "https://deno.land/std@0.213.0/dotenv/load.ts";

// Obtén la clave de la API desde las variables de entorno
const FIREBASE_API_KEY = Deno.env.get("FIREBASE_PROJECT_ID"); // Asegúrate de que sea la API Key de Firebase

// URL de registro de Firebase
const signUpUrl = `https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=${FIREBASE_API_KEY}`;

// Función para registrar un nuevo usuario
export async function registerUser(ctx: RouterContext<"/api/registerUser">) {
  // Obtener el cuerpo de la solicitud
  const { value } = await ctx.request.body({ type: "json" });
  const {
    email,
    password,
    userId,
    accountType,
    firstName,
    lastName,
    phone,
    clinicInfo,
  } = await value;

  // Datos del usuario que se enviarán a Firebase
  const userData = {
    email,
    password,
    returnSecureToken: true,
    accountType,
    firstName,
    lastName,
    phone,
    clinicInfo,
  };

  try {
    // Realizar la solicitud de registro a Firebase
    const response = await fetch(signUpUrl, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(userData),
    });

    const result = await response.json();

    if (!response.ok) {
      ctx.response.status = 400; // Bad request
      ctx.response.body = { message: result.error?.message || "Error desconocido al registrar usuario" };
      return;
    }

    // Si el registro es exitoso, responder con los datos del usuario registrado
    ctx.response.status = 200; // OK
    ctx.response.body = {
      message: "Usuario registrado con éxito",
      userId,
      email: result.email,
      idToken: result.idToken,
      phone,
      firstName,
      lastName,
      accountType,
      clinicInfo,
    };
  } catch (error) {
    console.error("❌ Error al registrar el usuario:", error);
    ctx.response.status = 500; // Internal server error
    ctx.response.body = { message: "Error al registrar el usuario" };
  }
}
