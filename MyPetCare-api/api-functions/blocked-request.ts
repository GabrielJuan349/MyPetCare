import { FirestoreBaseUrl, getDatabaseDate } from "./utils.ts"; 
import { RouterContext } from "oak";

/**
 * Maneja las solicitudes para obtener los días bloqueados para una clínica en un mes y año específicos.
 * @param ctx El contexto del enrutador de Oak.
 */
export async function monthBlockedRequest(ctx: RouterContext<"/api/calendar/:id">) {
    console.log("🚧 Obteniendo fechas bloqueadas")
    const clinicId = ctx.params.id; 
    let requestPayload;

    try {

        const body = ctx.request.body({ type: "json" });
        requestPayload = await body.value; 
        
    } catch (e) {

        console.error("⚠️ Failed to parse JSON body:", (e as Error).message);
        ctx.response.status = 400; 
        ctx.response.body = { 
            error: "Invalid JSON payload.",
            details: `Failed to parse JSON: ${(e as Error).message}` 
        };
        return;
    }

    const { month, year } = requestPayload; 

    if (!month || !year || !clinicId) { 
        ctx.response.status = 400; 
        const missingParams = [];
        if (!month) missingParams.push("month");
        if (!year) missingParams.push("year");
        if (!clinicId) missingParams.push("'clinicId' (from path)"); 
        
        ctx.response.body = { 
            error: "Missing required parameters.",
            message: `The following parameters are required: ${missingParams.join(", ")}.` 
        };
        return;
    }
    
    const databaseIndex = getDatabaseDate(month, year);
    const documentUrl = `${FirestoreBaseUrl}:runQuery`;
    const query = {
        structuredQuery: {
            from: [{ collectionId: "blocked_date" }], 
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
        const response = await fetch(documentUrl, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify(query)
        });

        if (!response.ok) {
            if (response.status === 404) {
                ctx.response.status = 200; 
                ctx.response.body = { clinicId, month, year, blockedDays: {} }; 
                return;
            }
            const errorBody = await response.json();
            console.error("⚠️ Error al obtener fechas bloqueadas:", errorBody);
            ctx.response.status = response.status;
            ctx.response.body = { error: 'Error al obtener las fechas bloqueadas', details: errorBody };
            return;
        }

        const result = await response.json();
        console.log("✅ Fechas bloqueadas obtenidas con éxito");   

        const citas = result
            .filter((entry: { document: unknown }) => entry.document) // Assuming entry has a document property
            .map((entry: { document: { fields: Record<string, any> } }) => { // Assuming document has fields
                const fields = entry.document.fields;
                const citaData: Record<string, string[]> = {}; // More specific type for citaData
                for (const fieldName in fields) {
                    if (fieldName != "clinicId" && fieldName === databaseIndex) {
                        const valueWrapper = fields[fieldName];
                        const appoint_day = valueWrapper.mapValue.fields;
                        const day = Object.keys(appoint_day)[0];
                        citaData[day] = [];
                        for (const innerFieldName in appoint_day[day].mapValue.fields) {
                            const buttonId = parseInt(innerFieldName);
                            const minutes = (buttonId%4)*15;
                            const hour = Math.floor(buttonId/4)+9;
                            const formatedHour = hour.toString().padStart(2, '0') + ":" + minutes.toString().padStart(2, '0');

                            citaData[day].push(formatedHour);
                        }
                    }
                }
                
                return citaData;
             
            });

        console.log("✅ Fechas bloqueadas obtenidas");
        ctx.response.status = 200;
        ctx.response.body = { blockedDays: citas };

    } catch (error) {
        console.error("⚠️ Excepción al obtener fechas bloqueadas:", error);
        ctx.response.status = 500;
        ctx.response.body = { error: 'Excepción interna del servidor al obtener fechas bloqueadas' };
    }
}