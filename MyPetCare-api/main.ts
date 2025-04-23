import { Application, Router } from 'oak';
import { oakCors } from 'cors';
import { load } from 'dotenv';

import { getClinic, getClinics } from './api-functions/clinic-request.ts';
import { getVetsByClinicId } from './api-functions/vet-request.ts';

await load({ export: true });

const app = new Application();
const router = new Router();

app.use(oakCors({
  origin: ['http://localhost:4200'], // Reemplaza con el puerto de tu frontend
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  credentials: true,
  optionsSuccessStatus: 204,
}));

router
  .post('/blocked/{date}/{id}', (ctx) => {
    const date = ctx.params.date;
    if (date === 'month') {
      const id = ctx.params.id;
      if (id) {
        console.log('month', id);
      } else {
        ctx.response.status = 400;
        ctx.response.body = { error: 'Invalid clinic identificator' };
      }
    } else if (date === 'day') {
      const id = ctx.params.id;
      if (id) {
        console.log('day', id);
      } else {
        ctx.response.status = 400;
        ctx.response.body = { error: 'Invalid vet identificator' };
      }
    } else {
      ctx.response.status = 400;
      ctx.response.body = { error: 'Invalid identificator' };
    }
    return ctx.response;
  })
  .get('/', (ctx) => {
    ctx.response.body = 'Hello World!';
    ctx.response.status = 200;
    ctx.response.headers.set('Content-Type', 'text/plain');
    return ctx.response;
  })
  .post('/clinic/list', async (ctx) => {
    const clinics = await getClinics();
    console.log(clinics);
    ctx.response.body = clinics;
    ctx.response.status = 200;
    ctx.response.headers.set('Content-Type', 'application/json');
    return ctx.response;
  })
  .post('/clinic/{id}', async (ctx) => {
    const id = ctx.params.id;
    if (id) {
      const clinic = await getClinic(Number(id));
      if (clinic) {
        ctx.response.body = clinic;
        ctx.response.status = 200;
        ctx.response.headers.set('Content-Type', 'application/json');
      } else {
        ctx.response.status = 404;
        ctx.response.body = { error: 'Clinic not found' };
      }
    } else {
      ctx.response.status = 400;
      ctx.response.body = { error: 'Invalid ID' };
    }
    return ctx.response;
  })
  .post('/category/{id}', (ctx) => {
    console.log(ctx.request.body({ type: 'json' }));
  })
  .post('/vet/list', async (ctx) => {
    const id = ctx.params.id_clinica;
    console.log(id);
    // if (id) {
    //   // const vets = getVetsByClinicId(id);
    //   const vets = getVetsByClinicId("81X7cMWJpEAkd9aFEoax");
    //   ctx.response.body = vets;
    //   ctx.response.status = 200;
    // }
    // else {
    //   ctx.response.status = 400;
    //   ctx.response.body = { error: 'Invalid ID' };
    // }
    const vets = await getVetsByClinicId('81X7cMWJpEAkd9aFEoax');
    ctx.response.body = vets;
    ctx.response.status = 200;
    return ctx.response;
  });

app.use(router.routes());
app.use(router.allowedMethods());

const port = Number(Deno.env.get('API_PORT'));
app.listen({ port });
console.log(`Server running at http://localhost:${port}`);
