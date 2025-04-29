import { db } from "../firebaseconfig/firebase.ts";
import { Pet } from "../interfaces/pet.interface.ts";
import { RouterContext } from "https://deno.land/x/oak@v12.6.1/mod.ts";

// Obtén la clave de la API desde las variables de entorno

const FIREBASE_PRIVATE_KEY = Deno.env.get("FIREBASE_PROJECT_ID"); // Asegúrate de que sea el ID del proyecto de Firebase

// URL de registro de Firebase
const FireStoreUrl = `https://firestore.googleapis.com/v1/projects/${FIREBASE_PRIVATE_KEY}/databases/(default)/documents/pets`;

//Create
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

//Delete
export async function deletePet(ctx: RouterContext<"/api/pet/:id">) {
  const id = ctx.params.id;
  const deleteUrl = `${FireStorePetsURL}/${id}`;
  const response = await fetch(deleteUrl, { method: "DELETE" });

  if (!response.ok) {
    ctx.response.status = 500;
    ctx.response.body = { error: "Error eliminando la mascota" };
  } else {
    ctx.response.status = 200;
    ctx.response.body = { success: true };
  }
}

//Update
export async function updatePet(ctx: RouterContext<"/api/pet/:id">) {
  const id = ctx.params.id;
  const { value } = await ctx.request.body({ type: "json" });
  const pet = await value;

  const updateUrl = `${FireStorePetsURL}/${id}?updateMask.fieldPaths=name&updateMask.fieldPaths=type&updateMask.fieldPaths=breed&updateMask.fieldPaths=birthDate&updateMask.fieldPaths=weight&updateMask.fieldPaths=owner&updateMask.fieldPaths=age&updateMask.fieldPaths=photoUrls`;

  const response = await fetch(updateUrl, {
    method: "PATCH",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      fields: {
        age: { integerValue: pet.age },
        birthDate: { stringValue: pet.birthDate },
        breed: { stringValue: pet.breed },
        name: { stringValue: pet.name },
        owner: { stringValue: pet.owner },
        type: { stringValue: pet.type },
        weight: { doubleValue: pet.weight },
        photoUrls: { arrayValue: { values: pet.photoUrls.map((url: string) => ({ stringValue: url })) } }
      }
    })
  });

  const result = await response.json();
  if (!response.ok) {
    ctx.response.status = 500;
    ctx.response.body = { error: result.error?.message || "Error actualizando mascota" };
  } else {
    ctx.response.status = 200;
    ctx.response.body = result;
  }
}

//GetPetById
export async function getPetById(ctx: RouterContext<"/api/pet/:id">) {
  const id = ctx.params.id;
  const getUrl = `${FireStorePetsURL}/${id}`;

  const response = await fetch(getUrl);
  const result = await response.json();

  if (!response.ok || result.error) {
    ctx.response.status = 404;
    ctx.response.body = { error: "Pet not found" };
  } else {
    ctx.response.status = 200;
    ctx.response.body = result;
  }
}

//GetPetsByOwner
export async function getPetsByOwner(ctx: RouterContext<"/api/getPets">) {
  const { value } = await ctx.request.body({ type: "json" });
  const { ownerId } = await value;

  const structuredQuery = {
    structuredQuery: {
      from: [{ collectionId: "pets" }],
      where: {
        fieldFilter: {
          field: { fieldPath: "owner" },
          op: "EQUAL",
          value: { stringValue: ownerId }
        }
      }
    }
  };

  const queryUrl = `https://firestore.googleapis.com/v1/projects/${FIREBASE_PROJECT_ID}/databases/(default)/documents:runQuery`;
  const response = await fetch(queryUrl, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(structuredQuery)
  });

  const result = await response.json();
  const pets = result
    .filter((entry: any) => entry.document)
    .map((entry: any) => ({
      id: entry.document.name.split("/").pop(),
      ...Object.fromEntries(Object.entries(entry.document.fields).map(([k, v]) => [k, Object.values(v)[0]]))
    }));

  ctx.response.status = 200;
  ctx.response.body = pets;
}
