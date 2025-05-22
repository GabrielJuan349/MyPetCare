import { randomInt } from 'node:crypto';

const FIREBASE_PROJECT_ID = Deno.env.get("FIREBASE_PROJECT_ID");
// La URL para ejecutar queries, la colección se especifica en el cuerpo de la query.
export const FirestoreQueryUrl = `https://firestore.googleapis.com/v1/projects/${FIREBASE_PROJECT_ID}/databases/(default)/documents:runQuery`;
export const FirestoreBaseUrl = `https://firestore.googleapis.com/v1/projects/${FIREBASE_PROJECT_ID}/databases/(default)/documents`;
export const documentName = `projects/${FIREBASE_PROJECT_ID}/databases/(default)/documents`;
/**
 * Devuelve una cadena de fecha formateada para la base de datos basada en el mes y el año.
 * @param month El mes como una cadena numérica (e.g., "1" para Enero).
 * @param year El año como una cadena (e.g., "2023").
 * @returns Una cadena que representa el mes y el año formateados (e.g., "January_2023").
 */
export function getDatabaseDate(month: string, year: string) {
    const Months: Array<string> = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
    const monthIndex:string = Months[parseInt(month)-1];
    console.log(`✅ Database date Index`)
    return monthIndex+"_"+year;
}
export async function getVetIdFromClinics(clinicId: string){
    const query = {
        structuredQuery: {
            from: [{ collectionId: "vets" }], 
            where: {
                fieldFilter: {
                    field: { fieldPath: "clinicId" }, 
                    op: "EQUAL",
                    value: { stringValue: clinicId }
                }
            }
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
            return;
        }

        const result = await response.json();
        const vet_pos = randomInt(0, result.length);
        const vetId = result[vet_pos].document.name.split("/").pop();
        console.log(`✅ Vet ID: ${vetId}`);
    
        return vetId; 
    } catch (error) {
        console.error("Error al procesar la solicitud de citas:", error);
        return;
    }
}

export function getDateInfoForDelete(date:string, hour:string) {
    const dateParts = date.split("-");
    const year = dateParts[0];
    const month = dateParts[1];
    const day = dateParts[2];
    const hourParts = hour.split(":");
    console.log(`✅ Hour parts: ${hourParts}`);
    const buttonId = (parseInt(hourParts[0])-9)*4 +(parseInt(hourParts[1])/15);

    return {
        databaseIndex: getDatabaseDate(month, year),
        day,
        buttonId
    };
}

