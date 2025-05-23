// authenticate.ts
import { RouterContext } from "oak";
// import "https://deno.land/std@0.213.0/dotenv/load.ts";


const FIREBASE_API_KEY = Deno.env.get("FIREBASE_API_KEY");

export const authenticate = async (ctx: RouterContext<"/api/authenticate">) => {
  const { value } = await ctx.request.body({ type: "json" });
  console.log(value);
  const { email, password } = await value;

  try {
    const response = await fetch(
      `https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${FIREBASE_API_KEY}`,
      {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          email,
          password,
          returnSecureToken: true,
        }),
      },
    );

    const data = await response.json();

    if (data.error) {
      ctx.response.status = 404;
      ctx.response.body = { message: "Usuario o contraseña incorrecta" };
      return;
    }

    ctx.response.status = 200;
    ctx.response.body = {
      message: "Autenticación exitosa",
      idToken: data.idToken,
      userId: data.localId,
    };
  } catch (error) { //No esta puesto en el swagger, pero es importante para el manejo de errores
    console.error("Error al autenticar:", error);
    ctx.response.status = 500;
    ctx.response.body = { message: "Error interno del servidor" };
  }
};
