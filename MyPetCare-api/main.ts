import { Application, Router } from "https://deno.land/x/oak@v12.6.1/mod.ts";

import { oakCors } from "https://deno.land/x/cors@v1.2.2/mod.ts";
import { load } from 'dotenv';

import { authenticate } from "./api-functions/authenticate.ts";
import { validateToken } from './api-functions/validateToken.ts';
import { registerUser } from './api-functions/registerUser.ts';
//import { getRecipeOnce } from "./api-functions/recetas.ts";
import { createPet, deletePet, updatePet, getPetById, getPetsByOwner } from "./api-functions/pet-request.ts";
import { createPrescription, getPrescription, updatePrescription, deletePrescription, getPrescriptionByPet } from "./api-functions/prescription.ts"
import { getClinics, createClinic, deleteClinic, getAllClinics } from "./api-functions/clinics.ts";
import { createVet, deleteVet, getVetById , getVetsByClinic} from "./api-functions/vets.ts";
import { createNews, getAllNews, deleteNews } from "./api-functions/news.ts";
import { updateUser, deleteUser, getUserDataById } from "./api-functions/gestion.usuarios.ts";
import { monthBlockedRequest } from './api-functions/blocked-request.ts';
import { deleteAppointment, getCitasByVetId, newAppointment, getAppointmentById } from './api-functions/appointments.ts';
import { createReport, getReportById, getReportsByVet, getReportsByPet, deleteReport } from "./api-functions/report.ts";
import { createTreatment, getTreatmentById, getTreatmentsByVet, getTreatmentsByPet, deleteTreatment } from "./api-functions/treatment.ts";
import {getVaccineByPetID, createVaccine} from "./api-functions/vaccines.ts";
import { createAdoption, getAllAdoptions, getAdoptionById, updateAdoption, deleteAdoption, getAdoptionsByClinic } from "./api-functions/adoption.ts";

await load({ export: true });

const app = new Application();
const router = new Router();
const port = Number(Deno.env.get("API_PORT")) || 4000;
const url = Deno.env.get("API_URL") || "http://localhost:";
const originURL = url+port.toString();

app.use(oakCors({

  origin: [originURL],
  // origin: ["http://localhost:4200"],
  methods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
  allowedHeaders: ["Content-Type", "Authorization"],
  credentials: true,
  optionsSuccessStatus: 204,
}));

// ---- Endpoints de USERS ----
router
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

  .get("/api/getPrescriptionByPet/pet/:id", getPrescriptionByPet)


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
  .delete("/api/deleteNews/:id", deleteNews)


// ---- Endpoints de NEWS ----
  // CREATE news info
  .post("/api/createNews", createNews)

  // GET all news info
  .get("/api/getAllNews", getAllNews)
  
  // DELETE news info
  .delete("/api/deleteNews/:id", deleteNews)


// ---- Endpoints de REPORT ----
  // CREATE report info
  .post("/api/createReport", createReport)

  // GET report by ID
  .get("/api/getReportById/:id", getReportById)

  // GET reports by vet ID
  .get("/api/getReportsByVet/vet/:id", getReportsByVet)

  // GET reports by pet ID
  .get("/api/getReportsByPet/pet/:id", getReportsByPet)

  // DELETE report info
  .delete("/api/deleteReport/:id", deleteReport)
// ----- Endpoints de Appointments/Calendar  -----
  // CREATE Appointments
  .post("/api/appointment/:id", newAppointment)

  // DELETE Appointments
  .delete("/api/appointment/:id", deleteAppointment)

  // GET Appointment by ID
  .get("/api/getAppointment/:id", getAppointmentById)

  // GET month blocked days from clinicId
  .post("/calendar/month/:id", monthBlockedRequest)
  // GET dates from vetId
  .post("/api/appointment/vet/:vetId", getCitasByVetId)

// ---- Endpoints de TREATMENT ----
  // CREATE treatment info
  .post("/api/createTreatment", createTreatment)

  // GET treatment by ID
  .get("/api/getTreatmentById/:id", getTreatmentById)

  // GET treatments by vet ID
  .get("/api/getTreatmentsByVet/vet/:id", getTreatmentsByVet)

  // GET treatments by pet ID
  .get("/api/getTreatmentsByPet/pet/:id", getTreatmentsByPet)

  // DELETE treatment info
  .delete("/api/deleteTreatment/:id", deleteTreatment)

  //ENDPOINT VACCINES
  .post("/api/vaccine", createVaccine)
  .get("/api/getVaccineByPetID/pet/:id", getVaccineByPetID)

// ---- Endpoints de ADOPTION ----
  .post("/api/createAdoption", createAdoption)
  .get("/api/getAllAdoptions", getAllAdoptions)
  .get("/api/getAdoptionById/:id", getAdoptionById)
  .put("/api/updateAdoption/:id", updateAdoption)
  .delete("/api/deleteAdoption/:id", deleteAdoption)
  .get("/api/getAdoptionsByClinic/:id", getAdoptionsByClinic)



app.use(router.routes());
app.use(router.allowedMethods());


app.listen({ port });
console.log('PORT:', port);
console.log(`Server running at ${originURL}`);

