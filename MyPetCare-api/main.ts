import { Application, Router} from 'oak';
import {oakCors} from 'cors';
import { load } from 'dotenv';

import {updateUser, deleteUser} from "./api-functions/gestion.usuarios.ts"

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

//UPDATE user info
router.put("/user/:user_id", async (ctx)=>{
  const userId = ctx.params.user_id; //Get id from the endpoint
  const fields = await ctx.request.body({type: "json"}).value;
  const res = await updateUser(userId, fields);
  ctx.response.status = res.status;
  ctx.response.body = res.message;
})

//DELETE user by id
router.delete("/user/:user_id", async (ctx)=>{
  const userId = ctx.params.user_id;
  const res = await deleteUser(userId);
  ctx.response.status = res.status;
  ctx.response.body = res.message;
})

app.use(router.routes());
app.use(router.allowedMethods());

const port = Number(Deno.env.get("API_PORT"));
app.listen({ port });
console.log(`Server running at http://localhost:${port}`);
