import { RouterContext } from "https://deno.land/x/oak@v12.6.1/mod.ts";
import {Vet} from "../interfaces/vets.interface.ts";

const FIREBASE_PROJECT_ID = Deno.env.get("FIREBASE_PROJECT_ID");
const FirestoreVetURL = `https://firestore.googleapis.com/v1/projects/${FIREBASE_PROJECT_ID}/databases/(default)/documents/vets`;

export async function createVet(ctx: RouterContext<"/api/createVet">) {
  console.log("Creando veterinario");
  const { value } = await ctx.request.body({ type: "json" });
  const vet: Vet = await value;

  const response = await fetch(FirestoreVetURL, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      fields: {
        Specialities: {
          arrayValue: {
            values: vet.specialities.map((s) => ({ stringValue: s })),
          },
        },
        clinicId: { stringValue: vet.clinicId },
        firstName: { stringValue: vet.firstName },
        lastName: { stringValue: vet.lastName },
        workingHours: {
          mapValue: {
            fields: Object.fromEntries(
              Object.entries(vet.workingHours).map(([day, hours]) => [
                day,
                {
                  mapValue: {
                    fields: {
                      start: { stringValue: hours.start },
                      end: { stringValue: hours.end },
                    },
                  },
                },
              ])
            ),
          },
        },
      },
    }),
  });

  const result = await response.json();
  ctx.response.status = response.ok ? 200 : 500;
  ctx.response.body = result;
}