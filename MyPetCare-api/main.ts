import { Application, Router} from "https://deno.land/x/oak@v12.6.1/mod.ts";

import { oakCors } from "https://deno.land/x/cors@v1.2.2/mod.ts";
import { load } from 'dotenv';
import { authenticate } from "./api-functions/authenticate.ts";
import { validateToken } from './api-functions/validateToken.ts';
import { registerUser } from './api-functions/registerUser.ts';

import {updateUser, deleteUser} from "./api-functions/gestion.usuarios.ts"

import { createPet, deletePet, getPetById, getPetsByOwner, updatePet } from "./api-functions/pet-request.ts";

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

// ---- Endpoints de USERS ----
router
  .post("/api/authenticate", authenticate)

  // Ruta para validar el token
  .post("/api/validateToken", validateToken)

  .post("/api/registerUser", registerUser)
//UPDATE user info
  .put("/user/:user_id", async (ctx)=>{
  const userId = ctx.params.user_id; //Get id from the endpoint
  const fields = await ctx.request.body({type: "json"}).value;
  const res = await updateUser(userId, fields);
  ctx.response.status = res.status;
  ctx.response.body = res.message;
})

//DELETE user by id
  .delete("/user/:user_id", async (ctx)=>{
  const userId = ctx.params.user_id;
  const res = await deleteUser(userId);
  ctx.response.status = res.status;
  ctx.response.body = res.message;
})

// ---- Endpoints de PETS ----
// Listar mascotas de un owner
router.post("/api/getPets", async (ctx) => {
  try {
    const { ownerId } = await ctx.request.body({ type: "json" }).value;
    console.log("/api/getPets called with ownerId:", ownerId);
    const pets = await getPetsByOwner(ownerId);
    ctx.response.status = 200;
    ctx.response.body = pets;
  } catch (err) {
    console.error("❌ Error en /api/getPets:", err);
    ctx.response.status = 500;
    ctx.response.body = { error: "Internal Server Error" };
  }
});

// Crear nueva mascota
router.post("/api/pet", async (ctx) => {
  try {
    const body = await ctx.request.body({ type: "json" }).value;
    const createdPet = await createPet(body);
    ctx.response.status = 200;
    ctx.response.body = createdPet;
  } catch (err) {
    console.error("❌ Error en /api/pet:", err);
    ctx.response.status = 500;
    ctx.response.body = { error: "Internal Server Error" };
  }
});

// Obtener una mascota por ID
router.get("/api/pet/:id", async (ctx) => {
  const id = ctx.params.id!;
  const pet = await getPetById(id);
  if (pet) {
    ctx.response.body = pet;
  } else {
    ctx.response.status = 404;
    ctx.response.body = { message: "Pet not found" };
  }
});

// Actualizar mascota por ID
router.put("/api/pet/:id", async (ctx) => {
  const id = ctx.params.id!;
  const { value } = await ctx.request.body({ type: "json" });
  const updatedPetData = await value;

  const result = await updatePet(id, updatedPetData);
  if (result) {
    ctx.response.body = result;
  } else {
    ctx.response.status = 404;
    ctx.response.body = { message: "Pet not found" };
  }
});

// Eliminar mascota por ID
router.delete("/api/pet/:id", async (ctx) => {
  const id = ctx.params.id!;
  const deleted = await deletePet(id);
  ctx.response.body = {
    success: deleted,
    message: deleted ? "Pet deleted" : "Pet not found",
  };
});


app.use(router.routes());
app.use(router.allowedMethods());

const port = Number(Deno.env.get("API_PORT")) || 8000; 
app.listen({ port });
console.log('PORT:', port);
console.log(`Server running at http://localhost:${port}`);
