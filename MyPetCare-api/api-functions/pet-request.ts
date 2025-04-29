import { db } from "../firebaseconfig/firebase.ts";
import { Pet } from "../interfaces/pet.interface.ts";
import { RouterContext } from "https://deno.land/x/oak@v12.6.1/mod.ts";
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

// Obtén la clave de la API desde las variables de entorno
const FIREBASE_API_KEY = Deno.env.get("FIREBASE_API_KEY"); // Asegúrate de que sea la API Key de Firebase
const FIREBASE_PRIVATE_KEY = Deno.env.get("FIREBASE_PROJECT_ID"); // Asegúrate de que sea el ID del proyecto de Firebase

// URL de registro de Firebase
const signUpUrl = `https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=${FIREBASE_API_KEY}`;
const FireStoreUrl = `https://firestore.googleapis.com/v1/projects/${FIREBASE_PRIVATE_KEY}/databases/(default)/documents/pets`;


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

export async function createPet(ctx: RouterContext<"/api/pet">) {
  console.log("🐶 createPet endpoint called");

  const { value } = await ctx.request.body({ type: "json" });
  console.log(value);
  const Pet = await value;
  //const birthDate = calculateAgeFromBirthDate(birthDateJSon);

  const response = await fetch(FireStoreUrl, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      fields: {
        age: { integerValue: Pet.age },
        birthDate: { stringValue: Pet.birthDate },
        breed: { stringValue: Pet.breed },
        name: { stringValue: Pet.name },
        owner: { stringValue: Pet.owner },
        type: { stringValue: Pet.type },
        weight: { doubleValue: Pet.weight }
      }
    }),
  });

  console.log("Response from Firestore:", response);

  const result = await response.json();
  if (!response.ok) {
    throw new Error(result.error?.message || "Error al registrar mascota");
  }

  ctx.response.status = 200;
  ctx.response.body = 'Pet created successfully!';

  return result;

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
  const docRef = db.collection("pets").doc(id);
  const docSnap = await docRef.get();

  if (!docSnap.exists) return false;

  await docRef.delete();
  return true;
}

