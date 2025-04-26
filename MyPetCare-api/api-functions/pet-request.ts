import { db } from "../firebaseconfig/firebase.ts";
import { Pet } from "../interfaces/pet.interface.ts";
import { Router } from "oak";
import {
  collection,
  addDoc,
  doc,
  Timestamp,
  query,
  where,
  getDoc,
  getDocs,
  updateDoc,
  deleteDoc
} from "https://www.gstatic.com/firebasejs/9.6.0/firebase-firestore.js";

const petRouter = new Router();

function calculateAgeFromBirthDate(birthDate: string): number {
  const birth = new Date(birthDate);
  const today = new Date();
  let age = today.getFullYear() - birth.getFullYear();
  const m = today.getMonth() - birth.getMonth();
  if (m < 0 || (m === 0 && today.getDate() < birth.getDate())) {
    age--;
  }
  return age;
}

export async function createPet(newPet: any) {
  const birthDate = newPet.birthDate;
  const age = calculateAgeFromBirthDate(birthDate);

  const petData = {
    ...newPet,
    age,
    owner: doc(db, "users", newPet.ownerId),
    createdAt: Timestamp.now(),
    lastUpdated: Timestamp.now(),
  };

  const petRef = await addDoc(collection(db, "pets"), petData);
  return { id: petRef.id, ...petData };
}

export async function getPetsByOwner(ownerId: string): Promise<Pet[]> {
  const petsRef = collection(db, "pets");
  const q = query(petsRef, where("ownerId", "==", ownerId));
  const querySnapshot = await getDocs(q);
  const pets: Pet[] = [];
  querySnapshot.forEach((doc) => {
    pets.push(doc.data() as Pet);
  });
  return pets;
}

export async function getPetById(id: string): Promise<Pet | null> {
  const docRef = doc(db, "pets", id);
  const docSnap = await getDoc(docRef);
  if (!docSnap.exists()) return null;
  return { id: docSnap.id, ...(docSnap.data() as Pet) };
}

export async function updatePet(id: string, updatedData: Partial<Pet>): Promise<Pet | null> {
  const docRef = doc(db, "pets", id);
  const docSnap = await getDoc(docRef);
  if (!docSnap.exists()) return null;

  const updatedPet = { ...docSnap.data(), ...updatedData, lastUpdated: Timestamp.now() };
  await updateDoc(docRef, updatedPet);
  return { id, ...(updatedPet as Pet) };
}

export async function deletePet(id: string): Promise<boolean> {
  const docRef = doc(db, "pets", id);
  const docSnap = await getDoc(docRef);
  if (!docSnap.exists()) return false;
  await deleteDoc(docRef);
  return true;
}

// RUTAS

petRouter
  .post("/getPets", async (ctx) => {
    const { ownerId } = await ctx.request.body({ type: "json" }).value;
    const pets = await getPetsByOwner(ownerId);
    ctx.response.body = pets;
  })
  .post("/pet", async (ctx) => {
    const body = await ctx.request.body({ type: "json" }).value;
    const pet = await createPet(body);
    ctx.response.body = pet;
  })
  .get("/pet/:id", async (ctx) => {
    const id = ctx.params.id!;
    const pet = await getPetById(id);
    if (pet) {
      ctx.response.body = pet;
    } else {
      ctx.response.status = 404;
      ctx.response.body = { message: "Pet not found" };
    }
  })
  .put("/pet/:id", async (ctx) => {
    const id = ctx.params.id!;
    const { value } = await ctx.request.body({ type: "json" });
    const updatedData = await value;
    const result = await updatePet(id, updatedData);
    if (result) {
      ctx.response.body = result;
    } else {
      ctx.response.status = 404;
      ctx.response.body = { message: "Pet not found" };
    }
  })
  .delete("/pet/:id", async (ctx) => {
    const id = ctx.params.id!;
    const deleted = await deletePet(id);
    ctx.response.body = { success: deleted, message: deleted ? "Pet deleted" : "Pet not found" };
  });

export default petRouter;
