// validateToken.ts
import { RouterContext } from "https://deno.land/x/oak@v12.6.1/mod.ts";
import "https://deno.land/std@0.213.0/dotenv/load.ts";

// Obtén la clave de la API desde las variables de entorno
const FIREBASE_API_KEY = Deno.env.get("FIREBASE_PROJECT_ID");


export async function validateToken(ctx: RouterContext<"/api/validateToken">) {
  const url = `https://identitytoolkit.googleapis.com/v1/accounts:lookup?key=${FIREBASE_API_KEY}`;
  const { value } = await ctx.request.body({ type: "json" });
  const { idToken } = await value;

  try {
    const response = await fetch(url, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ idToken }),
    });

    const data = await response.json();

    if (data.error) {
      // Si hay un error, responde con 401 Unauthorized
      ctx.response.status = 401;
      ctx.response.body = { message: "El token es incorrecto" };
      return;
    }

    // Si el token es válido, responde con 200 OK y la información del usuario
    ctx.response.status = 200;
    ctx.response.body = {
      message: "El token no es correcto",
      userData: data.users[0], // Retorna la información del usuario autenticado
    };
  } catch (error) {
    console.error("Error al validar el token:", error);
    ctx.response.status = 500;
    ctx.response.body = { message: "Error interno del servidor" };
  }
}
