import { Application, Router } from 'oak';
import {oakCors} from 'cors';
import { load } from 'dotenv';


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
  .post('/api/endpoint', (ctx) => {
    console.log(ctx.request.body({ type: 'json' }));
  })

app.use(router.routes());
app.use(router.allowedMethods());

const port = Number(Deno.env.get("API_PORT"));
app.listen({ port });
console.log(`Server running at http://localhost:${port}`);
