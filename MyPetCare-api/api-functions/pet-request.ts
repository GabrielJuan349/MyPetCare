
import { RouterContext } from "https://deno.land/x/oak@v12.6.1/mod.ts";

// Obtén la clave de la API desde las variables de entorno

//const FIREBASE_PRIVATE_KEY = Deno.env.get("FIREBASE_PROJECT_ID");
const FIREBASE_PROJECT_ID = Deno.env.get("FIREBASE_PROJECT_ID") // Asegúrate de que sea el ID del proyecto de Firebase

// URL de registro de Firebase
const FireStoreUrl = `https://firestore.googleapis.com/v1/projects/${FIREBASE_PROJECT_ID}/databases/(default)/documents/pets`;

//Create
export async function createPet(ctx: RouterContext<"/api/pet">) {
  console.log("🐶 createPet endpoint called");
  console.log(FireStoreUrl);
  console.log(FIREBASE_PROJECT_ID);

  const { value } = await ctx.request.body({ type: "json" });
  console.log(value);
  const Pet = await value;
  //const birthDate = calculateAgeFromBirthDate(birthDateJSon);

  const response = await fetch(FireStoreUrl, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      fields: {
        age: { doubleValue: Pet.age },
        birthDate: { stringValue: Pet.birthDate },
        breed: { stringValue: Pet.breed },
        name: { stringValue: Pet.name },
        owner: { stringValue: Pet.owner },
        type: { stringValue: Pet.type },
        weight: { doubleValue: Pet.weight },
        photoUrls: { stringValue: Pet.image },
        cartilla: { stringValue: Pet.cartilla },
        chip: { stringValue: Pet.chip },
        gender: { stringValue: Pet.gender },
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
  const fullDocPath = result.name; 
  const segments = fullDocPath.split("/");
  const documentId = segments[segments.length - 1]; 

  ctx.response.body = { id: documentId }; // Conseguir petID

  return result;
}

//Delete
export async function deletePet(ctx: RouterContext<"/api/pet/:id">) {
  const id = ctx.params.id;
  const deleteUrl = `${FireStoreUrl}/${id}`;
  const response = await fetch(deleteUrl, { method: "DELETE" });

  if (!response.ok) {
    ctx.response.status = 500;
    ctx.response.body = { error: "Error eliminando la mascota" };
  } else {
    ctx.response.status = 200;
    ctx.response.body = { success: true };
  }
}

// Update
export async function updatePet(ctx: RouterContext<"/api/pet/:id">) {
  const id = ctx.params.id;
  if (!id) {
    ctx.response.status = 400;
    ctx.response.body = { error: "ID de mascota no proporcionado" };
    return;
  }

  const { value } = await ctx.request.body({ type: "json" });
  const pet = await value;

  const fields: Record<string, any> = {};
  const updateMask: string[] = [];

  if (typeof pet.breed === "string") {
    fields.breed = { stringValue: pet.breed };
    updateMask.push("breed");
  }
  if (typeof pet.name === "string") {
    fields.name = { stringValue: pet.name };
    updateMask.push("name");
  }
  if (typeof pet.weight === "number") {
    fields.weight = { doubleValue: pet.weight };
    updateMask.push("weight");
  }
  if (typeof pet.gender === "string") {
    fields.gender = { stringValue: pet.gender };
    updateMask.push("gender");
  }
  if (Array.isArray(pet.photoUrls)) {
    fields.photoUrls = {
      arrayValue: {
        values: pet.photoUrls.map((url: string) => ({ stringValue: url }))
      }
    };
    updateMask.push("photoUrls");
  }

  if (updateMask.length === 0) {
    ctx.response.status = 400;
    ctx.response.body = { error: "No se proporcionaron campos válidos para actualizar" };
    return;
  }

  const updateUrl = `${FireStoreUrl}/${id}?` +
    updateMask.map((field) => `updateMask.fieldPaths=${field}`).join("&");

  const response = await fetch(updateUrl, {
    method: "PATCH",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ fields }),
  });

  const rawText = await response.text();
  let result;
  try {
    result = JSON.parse(rawText);
  } catch {
    result = { raw: rawText };
  }

  if (!response.ok) {
    ctx.response.status = 500;
    ctx.response.body = {
      error: "Error actualizando la mascota",
      details: result
    };
    return;
  }

  ctx.response.status = 200;
  ctx.response.body = { success: true, updated: result };
}


//GetPetById
export async function getPetById(ctx: RouterContext<"/api/pet/:id">) {
  const id = ctx.params.id;
  const getUrl = `${FireStoreUrl}/${id}`;

  const response = await fetch(getUrl);
  const result = await response.json();

  if (!response.ok || result.error) {
    ctx.response.status = 404;
    ctx.response.body = { error: "Pet not found" };
    return;
  }

  // Extraer campos limpios
  const fields = result.fields || {};
  const pet = {
    id,
    ...Object.fromEntries(
      Object.entries(fields).map(([key, value]) => [key, Object.values(value as { [key: string]: any })[0]])
    )    
  };

  ctx.response.status = 200;
  ctx.response.body = pet;
}

//GetPetsByOwner
export async function getPetsByOwner(ctx: RouterContext<"/api/getPet/:owner">) {
  console.log("📥 Endpoint getPetsByOwner llamado");
  
  const ownerId = ctx.params.owner;

  if (!ownerId) {
    ctx.response.status = 400;
    ctx.response.body = { error: "ownerId no proporcionado" };
    return;
  }

  const ownerPath = `/users/${ownerId}`;
  const url = `https://firestore.googleapis.com/v1/projects/${FIREBASE_PROJECT_ID}/databases/(default)/documents/pets`;
  console.log("ownerpath: ", ownerPath, " y url: ", url)

  const response = await fetch(url, {
    method: "GET",
    headers: {
      "Content-Type": "application/json"
    }
  });

  const result = await response.json();

  if (result.error) {
    ctx.response.status = 500;
    ctx.response.body = {
      error: "Error al obtener mascotas",
      details: result.error
    };
    return;
  }
  result.documents.forEach((doc: any) => {
    console.log(JSON.stringify(doc, null, 2));
  });


  const pets = (result.documents || [])
    .map((doc: any) => {
      const data = doc.fields;
      return {
        id: doc.name.split("/").pop(),
        ...Object.fromEntries(
          Object.entries(data).map(
            ([k, v]) => [k, Object.values(v as { [key: string]: any })[0]]
          )
        )
      };
    })
    .filter((pet) => pet.owner === ownerId);

  console.log(pets)
  ctx.response.status = 200;
  ctx.response.body = pets;
}
