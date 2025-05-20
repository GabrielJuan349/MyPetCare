import { RouterContext } from "https://deno.land/x/oak@v12.6.1/mod.ts";

// Asumimos que tienes una interfaz para Cita, si no, deberías crearla.
// import { Cita } from "../interfaces/cita.interface.ts"; 

const FIREBASE_PROJECT_ID = Deno.env.get("FIREBASE_PROJECT_ID");
// La URL para ejecutar queries, la colección se especifica en el cuerpo de la query.
const FirestoreQueryUrl = `https://firestore.googleapis.com/v1/projects/${FIREBASE_PROJECT_ID}/databases/(default)/documents:runQuery`;



export async function getCitasByVetId(ctx: RouterContext<"/api/citas/vet/:vetId">) {
    const vetId = ctx.params.vetId;

    if (!vetId) {
        ctx.response.status = 400;
        ctx.response.body = { error: "ID de veterinario no proporcionado" };
        return;
    }

    const query = {
        structuredQuery: {
            from: [{ collectionId: "citas" }], // Nombre de tu colección de citas
            where: {
                fieldFilter: {
                    field: { fieldPath: "vetId" }, // Campo para filtrar por ID de veterinario
                    op: "EQUAL",
                    value: { stringValue: vetId }
                }
            }
            // Puedes añadir orderBy aquí si quieres ordenar las citas, por ejemplo, por fecha:
            // orderBy: [{ field: { fieldPath: "fecha" }, direction: "ASCENDING" }]
        }
    };

    try {
        const response = await fetch(FirestoreQueryUrl, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify(query)
        });

        if (!response.ok) {
            const errorBody = await response.text();
            console.error("Error de Firestore:", response.status, errorBody);
            ctx.response.status = response.status;
            ctx.response.body = { error: "Error al obtener las citas de Firestore", details: errorBody };
            return;
        }

        const result = await response.json();

        // Los resultados de runQuery vienen como un array de objetos,
        // cada uno puede ser un documento o una notificación de que no hay más resultados.
        // Filtramos solo los que tienen un documento.
        const citas = result
            .filter((entry: any) => entry.document)
            .map((entry: any) => {
                const document = entry.document;
                const id = document.name.split("/").pop(); // Extrae el ID del documento de su path
                const fields = document.fields;
                
                // Transforma los campos de Firestore a un objeto más plano
                const citaData: { [key: string]: any } = { id };
                for (const fieldName in fields) {
                    const valueWrapper = fields[fieldName];
                    // El valor real está dentro de una clave como stringValue, integerValue, mapValue, etc.
                    const valueType = Object.keys(valueWrapper)[0];
                    citaData[fieldName] = valueWrapper[valueType];
                }
                return citaData;
                // Si tienes una interfaz Cita, puedes mapear a ella:
                // return {
                //     id: id,
                //     // ...otros campos mapeados según tu interfaz Cita
                //     // Ejemplo:
                //     // petId: fields.petId?.stringValue,
                //     // fecha: fields.fecha?.timestampValue, 
                //     // motivo: fields.motivo?.stringValue,
                //     // vetId: fields.vetId?.stringValue 
                // } as Cita;
            });

        ctx.response.status = 200;
        ctx.response.body = citas;

    } catch (error) {
        console.error("Error al procesar la solicitud de citas:", error);
        ctx.response.status = 500;
        ctx.response.body = { error: "Error interno del servidor al obtener citas" };
    }
}