import { RouterContext } from "https://deno.land/x/oak@v12.6.1/mod.ts";
import { FirestoreBaseUrl, FirestoreQueryUrl, getDatabaseDate } from "./utils.ts"; // Asegúrate de que la ruta sea correcta
import console from 'node:console';
import { randomInt } from 'node:crypto';

async function createAppointmenInDatabase(day:number, month:number, year:number, buttonId:number, petId:String, vetId:String): String|Error {
    // Implementación de la función para crear una cita en la base de datos
    const appDate = new Date(year, month - 1, day).toLocaleDateString('fr-CA');
    console.log("Cita creada en la base de datos:", appDate);
    const minutes = 15*buttonId;
    const hoursFromJournal = Math.floor(minutes/60)+8;
    const minutesFromJournal = minutes % 60;
    if (hoursFromJournal > 17 || hoursFromJournal < 9) {
        console.log("La hora de la cita está fuera del horario laboral");
        return Error("La hora de la cita está fuera del horario laboral");
    }

    const time = `${hoursFromJournal}:${minutesFromJournal}`;
    console.log("Cita creada en la base de datos:", time);
    const appointmentUrl = `${FirestoreBaseUrl}/appointments`;

    const response = await fetch(appointmentUrl, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      fields: {
        date: { stringValue: appDate },
        time: { stringValue: time },
        petId: { stringValue: petId },
        vetId: { stringValue: vetId },
        createdAt: { stringValue: new Date().toISOString() }, 
      }
    }),
  });   
     
    const result = await response.json();
    const appointId = result.name.split("/").pop();
    return appointId;  
}

async function getVetIdFromClinics(clinicId: string){
    const query = {
        structuredQuery: {
            from: [{ collectionId: "vets" }], // Nombre de tu colección de citas
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
    
        return vetId; // Cambia esto por la lógica real
    } catch (error) {
        console.error("Error al procesar la solicitud de citas:", error);
        return;
    }
}


export async function getCitasByVetId(ctx: RouterContext<"/api/citas/vet/:vetId">) {
    const vetId = ctx.params.vetId;
    console.log("vetId", vetId);

    if (!vetId) {
        ctx.response.status = 400;
        ctx.response.body = { error: "ID de veterinario no proporcionado" };
        return;
    }

    const query = {
        structuredQuery: {
            from: [{ collectionId: "appointments" }], // Nombre de tu colección de citas
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
    

        const citas = result
            .filter((entry: any) => entry.document)
            .map((entry: any) => {
                const fields = entry.document.fields;
                console.log("fields", fields);
                const citaData: any = {};
                for (const fieldName in fields) {
                    if (fieldName != "clinicId") {
                        const valueWrapper = fields[fieldName];
                        // El valor real está dentro de una clave como stringValue, integerValue, mapValue, etc.
                        const valueType = Object.keys(valueWrapper)[0];
                        citaData[fieldName] = valueWrapper[valueType];
                    }
                }
                
                return citaData;
             
            });

        ctx.response.status = 200;
        ctx.response.body = citas;

    } catch (error) {
        console.error("Error al procesar la solicitud de citas:", error);
        ctx.response.status = 500;
        ctx.response.body = { error: "Error interno del servidor al obtener citas" };
    }
}



export async function newAppointment(ctx: RouterContext<"/api/appointment/:id">) {
    const clinicId = ctx.params.id; // Renombrado para claridad
    let requestPayload;

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
    const buttonID = parseInt(buttonId);
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
    console.log("Received request payload:", clinicId, day, month, year, buttonID, petId);
    const databaseIndex = getDatabaseDate(month, year);
    const vetId = await getVetIdFromClinics(clinicId);
    if (!vetId) {
        ctx.response.status = 404;
        ctx.response.body = { error: "Veterinario no encontrado para la clínica proporcionada" };
        return;
    }
    const appointmentId = await createAppointmenInDatabase(day, month, year, buttonID, petId, vetId);
    console.log("Appointment ID:", appointmentId);
    let documentPath:string = `blocked_date`;
    
    const query = {
        structuredQuery: {
            from: [{ collectionId: documentPath }], // Nombre de tu colección de citas
            where: {
                fieldFilter: {
                    field: { fieldPath: "clinicId" }, // Campo para filtrar por ID de veterinario
                    op: "EQUAL",
                    value: { stringValue: clinicId }
                }
            }
            
        }
    };
    let documentId: string, result: any;
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
        result = await response.json();
        console.log("Firestore result:", result);

        documentId= result[0].document.name.split("/").pop();
        
        console.log("Document ID:", documentId);
        
    }catch (error) {
        console.error("Error al procesar la solicitud de citas:", error);
        ctx.response.status = 500;
        ctx.response.body = { error: "Error interno del servidor al obtener citas" };
        return;
    }
    const monthsInDatabase = result[0].document.fields;
    let fieldPathToUpdate:string, newData:any;
    if (!(databaseIndex in monthsInDatabase)) {
        console.log("El mes no existe en la base de datos, creando nuevo mes");
        newData = {
            [databaseIndex]: {
                mapValue: {
                    values: []
                }
            }
        };
        fieldPathToUpdate = "";
    }else if (!(day in monthsInDatabase[databaseIndex].mapValue.fields) ) {
        console.log("El día no existe en la base de datos, creando nuevo día");
        newData = {
            [day]: {
                mapValue: {
                    values: []
                }
            }
        };
        fieldPathToUpdate = `${databaseIndex}`;
    } else {
        newData = {
            [buttonId]: {stringValue: appointmentId}
        }

        fieldPathToUpdate = `${databaseIndex}.${day}`;
    }

    documentPath = `blocked_date/${documentId}`;
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
                            values: [newData]
                        }
                    }
                ],
            }
        ],
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