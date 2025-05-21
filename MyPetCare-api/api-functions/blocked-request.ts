import { Console } from 'node:console';
import { RouterContext } from "https://deno.land/x/oak@v12.6.1/mod.ts";
const FIREBASE_PROJECT_ID = Deno.env.get("FIREBASE_PROJECT_ID");
// URL base para operaciones de documentos individuales y para :commit
const FirestoreBaseUrl = `https://firestore.googleapis.com/v1/projects/${FIREBASE_PROJECT_ID}/databases/(default)/documents`;

function getDatabaseDate(month: string, year: string) {
    const Months: Array<string> = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
    const monthIndex:string = Months[parseInt(month)-1];
    return monthIndex+"_"+year;
}

export async function dayBlockedRequest(ctx: RouterContext<"/blocked/day/:id">) {
    const clinicId = ctx.params.id; // Renombrado para claridad
    let requestPayload;
    console.log("Received request payload:", clinicId);

    try {
        // El cuerpo de la solicitud se espera que sea JSON.
        const body = ctx.request.body({ type: "json" });
        requestPayload = await body.value; // Esto puede lanzar un error si el cuerpo no es JSON válido.
    } catch (e) {
        // Registrar el error y devolver una respuesta 400 si falla el análisis JSON.
        console.error("Failed to parse JSON body:", e.message);
        ctx.response.status = 400; // Bad Request
        ctx.response.body = { 
            error: "Invalid JSON payload.",
            details: `Failed to parse JSON: ${e.message}` // Proporcionar detalles del analizador.
        };
        return;
    }
    const { day, month, year, buttonId, petId } = requestPayload; // Desestructuración del payload

    if (!day || !month || !year || !clinicId) {
        ctx.response.status = 400;
        ctx.response.body = { error: "Clínica, día, mes o año no proporcionado" };
        return;
    }
    if (!buttonId && !petId) {
        ctx.response.status = 400;
        ctx.response.body = { error: "Debe proporcionar buttonId o petId para el bloqueo" };
        return;
    }

    const databaseIndex = getDatabaseDate(month, year);
    const documentPath = `blocked_date/${databaseIndex}`;
    const valueToBlock = buttonId || petId; // Prioriza buttonId

    // El fieldPath para la transformación, ej: "clinicId123.15"
    // Asegúrate que 'day' no empiece con número si es parte de un fieldPath así directamente,
    // o envuélvelo si es necesario, aunque Firestore suele manejarlo.
    // Para mayor seguridad, los nombres de campos que son puramente numéricos a veces se prefijan o se tratan con cuidado.
    // Aquí asumimos que Firestore lo maneja bien o que 'day' es un string que puede ser numérico.
    const fieldPathToUpdate = `${clinicId}.${day}`;

    const commitUrl = `${FirestoreBaseUrl}:commit`;
    const commitPayload = {
        writes: [
            {
                update: {
                    name: `${FirestoreBaseUrl}/${documentPath}`
                },
                updateTransforms: [
                    {
                        fieldPath: fieldPathToUpdate,
                        appendMissingElements: {
                            values: [{ stringValue: valueToBlock }]
                        }
                    }
                ],
                // currentDocument: { exists: true } // Opcional: para fallar si el documento no existe.
                                                  // Si se omite, creará el documento y los campos si no existen.
            }
        ]
    };

    try {
        const response = await fetch(commitUrl, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify(commitPayload),
        });

        if (!response.ok) {
            const errorBody = await response.json();
            console.error("Error al registrar fecha bloqueada:", errorBody);
            ctx.response.status = response.status;
            ctx.response.body = { error: 'Error al registrar la fecha bloqueada', details: errorBody };
        } else {
            ctx.response.status = 200;
            ctx.response.body = { message: 'Fecha bloqueada registrada correctamente' };
        }
    } catch (error) {
        console.error("Excepción al registrar fecha bloqueada:", error);
        ctx.response.status = 500;
        ctx.response.body = { error: 'Excepción interna del servidor' };
    }
}

export async function monthBlockedRequest(ctx: RouterContext<"/blocked/month/:id">) {
    const clinicId = ctx.params.id; // Renombrado para claridad
    let requestPayload;
    console.log("Received request payload:", clinicId);

    try {
        // El cuerpo de la solicitud se espera que sea JSON.
        const body = ctx.request.body({ type: "json" });
        requestPayload = await body.value; // Esto puede lanzar un error si el cuerpo no es JSON válido.
    } catch (e) {
        // Registrar el error y devolver una respuesta 400 si falla el análisis JSON.
        console.error("Failed to parse JSON body:", e.message);
        ctx.response.status = 400; // Bad Request
        ctx.response.body = { 
            error: "Invalid JSON payload.",
            details: `Failed to parse JSON: ${e.message}` // Proporcionar detalles del analizador.
        };
        return;
    }

    const { month, year } = requestPayload; 

    if (!month || !year || !clinicId) { // Manteniendo la verificación de clinicId como en la lógica original
        ctx.response.status = 400; // Bad Request
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
            from: [{ collectionId: "blocked_date" }], // Nombre de tu colección de citas
            where: {
                fieldFilter: {
                    field: { fieldPath: "clinicId" }, // Campo para filtrar por ID de veterinario
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
                ctx.response.status = 200; // O 404 si prefieres indicar que no hay datos
                ctx.response.body = { clinicId, month, year, blockedDays: {} }; // No hay documento, por lo tanto no hay bloqueos para esta clínica este mes
                return;
            }
            const errorBody = await response.json();
            console.error("Error al obtener fechas bloqueadas:", errorBody);
            ctx.response.status = response.status;
            ctx.response.body = { error: 'Error al obtener las fechas bloqueadas', details: errorBody };
            return;
        }

        const result = await response.json();
        
        // const clinicData = result.document.fields; // Acceder a los campos del documento
        // console.log("Clinic data:", clinicData);
        const citas = result
            .filter((entry: any) => entry.document)
            .map((entry: any) => {
                const fields = entry.document.fields;
                const citaData: any = {};
                for (const fieldName in fields) {
                    if (fieldName != "clinicId" && fieldName === databaseIndex) {
                        const valueWrapper = fields[fieldName];
                        const appoint_day = valueWrapper.mapValue.fields;
                        // El valor real está dentro de una clave como stringValue, integerValue, mapValue, etc.
                        const day = Object.keys(appoint_day)[0];
                        citaData[day] = [];
                        // citaData[day] = appoint_day[day].mapValue.fields;
                        for (const fieldName in appoint_day[day].mapValue.fields) {
                            citaData[day].push(fieldName);
                        }
                    }
                }
                
                return citaData;
             
            });
        console.log("Citas:", citas);

        ctx.response.status = 200;
        ctx.response.body = { blockedDays: citas };

    } catch (error) {
        console.error("Excepción al obtener fechas bloqueadas:", error);
        ctx.response.status = 500;
        ctx.response.body = { error: 'Excepción interna del servidor al obtener fechas bloqueadas' };
    }
}