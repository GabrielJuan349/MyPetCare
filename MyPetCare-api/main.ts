import { Application, Router } from "https://deno.land/x/oak@v12.6.1/mod.ts";

import { oakCors } from "https://deno.land/x/cors@v1.2.2/mod.ts";
import { load } from 'dotenv';

import { authenticate } from "./api-functions/authenticate.ts";
import { validateToken } from './api-functions/validateToken.ts';
import { registerUser } from './api-functions/registerUser.ts';
//import { getRecipeOnce } from "./api-functions/recetas.ts";
import { createPet, deletePet, updatePet, getPetById, getPetsByOwner } from "./api-functions/pet-request.ts";
import { createPrescription, getPrescription, updatePrescription, deletePrescription } from "./api-functions/prescription.ts"
import { getClinics, createClinic, deleteClinic, getAllClinics } from "./api-functions/clinics.ts";
import { createVet, deleteVet, getVetById , getVetsByClinic} from "./api-functions/vets.ts";
import { createNews, getAllNews, deleteNews } from "./api-functions/news.ts";
import { updateUser, deleteUser, getUserDataById } from "./api-functions/gestion.usuarios.ts";
import { monthBlockedRequest } from './api-functions/blocked-request.ts';
import { deleteAppointment, getCitasByVetId, newAppointment } from './api-functions/appointments.ts';


await load({ export: true });

const app = new Application();
const router = new Router();

app.use(oakCors({

  origin: ["http://localhost:4200"],
  methods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
  allowedHeaders: ["Content-Type", "Authorization"],
  credentials: true,
  optionsSuccessStatus: 204,
}));

// ---- Endpoints de USERS ----
router
  .post("/api/appointment/:id", newAppointment)
  .delete("/api/appointment/:id", deleteAppointment)
  .post("/blocked/month/:id", monthBlockedRequest)
  .post("/api/citas/vet/:vetId", getCitasByVetId)
  
  .get('/', (ctx) => {
    ctx.response.body = 'MyPetCare API Online✅';
    ctx.response.status = 200;
    ctx.response.headers.set('Content-Type', 'text/plain');
    return ctx.response;
  })
  .post("/api/authenticate", authenticate)
  .post("/api/validateToken", validateToken)
  .post("/api/registerUser", registerUser)

  // UPDATE user info
  .put("/user/:user_id", updateUser)

  // DELETE user by id
  .delete("/user/:user_id", deleteUser)

  // GET user by id
  .get("/user/:user_id", getUserDataById)

  // ---- Endpoints de PETS ----

  // CREATE pet info
  .post("/api/pet", createPet)

  // DELETE pet info
  .delete("/api/pet/:id", deletePet)

  // UPDATE pet info
  .put("/api/pet/:id", updatePet)

  // GETPETBYID pet info
  .get("/api/pet/:id", getPetById)


  // GETPETBYOWNER pet info
  .get("/api/getPet/:owner", getPetsByOwner)

  //.get("/api/getprescription/:id", getRecipeOnce);


  // ---- Endpoints de PRESCRIPTIONS ----

  // CREATE prescription info
  .post("/api/prescription", createPrescription)

  // Get prescription info
  .get("/api/getPrescription/:id", getPrescription)

  // DELETE prescription info
  .delete("/api/deletePrescription/:id", deletePrescription)

  // UPDATE prescription info
  .put("/api/putPrescription/:id", updatePrescription)


// ---- Endpoints de CLINICS ----
  // GET clinics info
  .get("/api/getClinics/:id", getClinics)

  .post("/api/createClinic", createClinic)

  // DELETE clinic info
  .delete("/api/deleteClinic/:id", deleteClinic)
  // GET all clinics info
  .get("/api/getClinics", getAllClinics)

// ---- Endpoints de VETS ----
  // CREATE vets info
  .post("/api/createVet", createVet)

  // DELETE vets info
  .delete("/api/deleteVet/:id", deleteVet)
  
  // GET vets info
  .get("/api/getVetsByClinic/:clinicId", getVetsByClinic)

  .get("/api/getVet/:id", getVetById)


// ---- Endpoints de NEWS ----
  // CREATE news info
  .post("/api/createNews", createNews)

  // GET news info
  .get("/api/getAllNews", getAllNews)
  
  // DELETE news info
  .delete("/api/deleteNews/:id", deleteNews);


app.use(router.routes());
app.use(router.allowedMethods());


const port = Number(Deno.env.get("API_PORT")) || 8000;
app.listen({ port });
console.log('PORT:', port);
console.log(`Server running at http://localhost:${port}`);

