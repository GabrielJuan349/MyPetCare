import { Application, Router } from 'oak';
import {oakCors} from 'cors';
import { load } from 'dotenv';
import { authenticate } from "./api-functions/authenticate.ts";
import { validateToken } from './api-functions/validateToken.ts';
import { registerUser } from './api-functions/registerUser.ts';


await load({ export: true });

const app = new Application();
const router = new Router();

app.use(oakCors({
  origin: ["http://localhost:4200"], // Reemplaza con el puerto de tu frontend
  methods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
  allowedHeaders: ["Content-Type", "Authorization"],
  credentials: true,
  optionsSuccessStatus: 204
}));

router
  .post("/api/authenticate", authenticate)

  // Ruta para validar el token
  .post("/api/validateToken", validateToken)

  .post("/api/registerUser", registerUser); 

app.use(router.routes());
app.use(router.allowedMethods());

const port = Number(Deno.env.get("API_PORT")) || 8000; 
app.listen({ port });
console.log(`Server running at http://localhost:${port}`);
