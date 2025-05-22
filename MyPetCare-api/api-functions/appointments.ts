import { RouterContext } from "https://deno.land/x/oak@v12.6.1/mod.ts";
import { documentName, FirestoreBaseUrl, FirestoreQueryUrl, getDatabaseDate, getDateInfoForDelete, getVetIdFromClinics } from "./utils.ts"; 
import console from 'node:console';

async function createAppointmenInDatabase(day:number, month:number, year:number, buttonId:number, petId:String, vetId:String) {

    const appDate = new Date(year, month - 1, day).toLocaleDateString('fr-CA');
    const minutes = 15*buttonId;
    const hoursFromJournal = Math.floor(minutes/60)+9;
    const minutesFromJournal = minutes % 60;
    if (hoursFromJournal > 17 || hoursFromJournal < 9) {
        console.log("La hora de la cita está fuera del horario laboral");
        return Error("La hora de la cita está fuera del horario laboral");
    }

    const time = `${hoursFromJournal}:${minutesFromJournal}`;
    const appointmentUrl = `${FirestoreBaseUrl}/appointments`;
    try {
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
        console.log(`✅ Cita creada en Firestore con ID: ${appointId}`);
        return appointId;  
        
    } catch (error) {
        console.error("⚠️ Error al crear la cita:", error);
        return;
        
    }
}

export async function getCitasByVetId(ctx: RouterContext<"/api/appointment/vet/:vetId">) {
    const vetId = ctx.params.vetId;

    if (!vetId) {
        ctx.response.status = 400;
        ctx.response.body = { error: "ID de veterinario no proporcionado" };
        return;
    }

    const query = {
        structuredQuery: {
            from: [{ collectionId: "appointments" }], 
            where: {
                fieldFilter: {
                    field: { fieldPath: "vetId" }, 
                    op: "EQUAL",
                    value: { stringValue: vetId }
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
            console.error("⚠️ Error de Firestore:", response.status, errorBody);
            ctx.response.status = response.status;
            ctx.response.body = { error: "Error al obtener las citas de Firestore", details: errorBody };
            return;
        }

        const result = await response.json();
    

        const citas = result
            .filter((entry: any) => entry.document)
            .map((entry: any) => {
                const fields = entry.document.fields;
                const citaData: any = {};
                for (const fieldName in fields) {
                    if (fieldName != "clinicId") {
                        const valueWrapper = fields[fieldName];
                        const valueType = Object.keys(valueWrapper)[0];
                        citaData[fieldName] = valueWrapper[valueType];
                    }
                }
                
                return citaData;
             
            });

        ctx.response.status = 200;
        ctx.response.body = citas;

    } catch (error) {
        console.error("⚠️ Error al procesar la solicitud de citas:", error);
        ctx.response.status = 500;
        ctx.response.body = { error: "Error interno del servidor al obtener citas" };
    }
}

export async function newAppointment(ctx: RouterContext<"/api/appointment/:id">) {
    const clinicId = ctx.params.id; 
    let requestPayload;

    try {
        const body = ctx.request.body({ type: "json" });
        requestPayload = await body.value; 
    } catch (e) {
        console.error("⚠️ Failed to parse JSON body:", e.message);
        ctx.response.status = 400; 
        ctx.response.body = { 
            error: "Invalid JSON payload.",
            details: `Failed to parse JSON: ${e.message}` 
        };
        return;
    }
    const { day, month, year, buttonId, petId } = requestPayload; 
    const buttonID = parseInt(buttonId);
    if (!day || !month || !year || !clinicId) {
        console.error("⚠️ Error: clínica, día, mes o año no proporcionado");
        ctx.response.status = 400;
        ctx.response.body = { error: "Clínica, día, mes o año no proporcionado" };
        return;
    }
    if (!buttonId && !petId) {
        console.error("⚠️ Error: buttonId o petId no proporcionado");
        ctx.response.status = 400;
        ctx.response.body = { error: "Debe proporcionar buttonId o petId para el bloqueo" };
        return;
    }
    const databaseIndex = getDatabaseDate(month, year);
    const vetId = await getVetIdFromClinics(clinicId);
    if (!vetId) {
        ctx.response.status = 404;
        ctx.response.body = { error: "Veterinario no encontrado para la clínica proporcionada" };
        return;
    }
    const appointmentId = await createAppointmenInDatabase(day, month, year, buttonID, petId, vetId);

    let documentPath:string = `blocked_date`;
    
    const query = {
        structuredQuery: {
            from: [{ collectionId: documentPath }], 
            where: {
                fieldFilter: {
                    field: { fieldPath: "clinicId" }, 
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
            console.error("⚠️ Error de Firestore:", response.status, errorBody);
            ctx.response.status = response.status;
            ctx.response.body = { error: "Error al obtener las citas de Firestore", details: errorBody };
            return;
        }
        const queryResult = await response.json();
        console.log(`✅ Calendar information for clinicId ${clinicId} collected`);

        if (queryResult && queryResult.length > 0 && queryResult[0].document) {

            result = queryResult; 
            documentId = result[0].document.name.split("/").pop();
            console.log("✅ Document ID found:", documentId);
        } else {

            console.log(`No document found for clinicId ${clinicId} in ${documentPath}. Creating new document.`);
            const createDocUrl = `${FirestoreBaseUrl}/${documentPath}`; 
            
            const createResponse = await fetch(createDocUrl, {
                method: "POST", 
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({
                    fields: {
                        clinicId: { stringValue: clinicId }

                    }
                })
            });

            if (!createResponse.ok) {
                const errorBody = await createResponse.text(); 
                console.error("⚠️ Error creating document in Firestore:", createResponse.status, errorBody);
                ctx.response.status = createResponse.status;
                ctx.response.body = { error: "Error al crear el documento de fechas bloqueadas en Firestore", details: errorBody };
                return;
            }
            const newDocument = await createResponse.json();
            documentId = newDocument.name.split("/").pop();
            console.log(`✅ New document created with ID: ${documentId}`);
        }
        
    }catch (error) {
        console.error(`⚠️ Error al procesar la solicitud de citas: ${error}`);
        ctx.response.status = 500;
        ctx.response.body = { error: "Error interno del servidor al obtener citas" };
        return;
    }
    const existingDocFields = (result && result[0] && result[0].document && result[0].document.fields)
                              ? JSON.parse(JSON.stringify(result[0].document.fields))
                              : { clinicId: { stringValue: clinicId } }; 

    if (!existingDocFields[databaseIndex]) {
        existingDocFields[databaseIndex] = { mapValue: { fields: {} } };
    } else if (!existingDocFields[databaseIndex].mapValue) { 
        existingDocFields[databaseIndex].mapValue = { fields: {} };
    } else if (!existingDocFields[databaseIndex].mapValue.fields) { 
         existingDocFields[databaseIndex].mapValue.fields = {};
    }

    const monthFields = existingDocFields[databaseIndex].mapValue.fields;

    const dayString = String(day); 
    if (!monthFields[dayString]) {
        monthFields[dayString] = { mapValue: { fields: {} } };
    } else if (!monthFields[dayString].mapValue) { 
        monthFields[dayString].mapValue = { fields: {} };
    } else if (!monthFields[dayString].mapValue.fields) {
        monthFields[dayString].mapValue.fields = {};
    }

    const dayFields = monthFields[dayString].mapValue.fields;

    dayFields[buttonId] = { stringValue: String(appointmentId) };
    
    documentPath = `blocked_date/${documentId}`; 
    console.log("Document path for commit:", documentPath);
    const commitUrl = `${FirestoreBaseUrl}:commit`;

    const documentResourceName = `${documentName}/${documentPath}`;

    const commitPayload = {
        writes: [
            {
                update: {
                    name: documentResourceName, 
                    fields: existingDocFields 
                },
            }
        ],
    };
    
    console.log("Commit payload done");
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
            return;
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

export async function deleteAppointment(ctx: RouterContext<"/api/appointment/:id">) {
    const appointmentId = ctx.params.id; 
    if (!appointmentId) {
        ctx.response.status = 400;
        ctx.response.body = { error: "ID de cita no proporcionado" };
        return;
    }
    const appointmentUrl = `${FirestoreBaseUrl}/appointments/${appointmentId}`;
    try {
        //Fetching Appointment
        const responseGET = await fetch(appointmentUrl, {
            method: "GET",
            headers: { "Content-Type": "application/json" },
        });
        if (!responseGET.ok) {
            const errorBody = await responseGET.json();
            console.error("Error al obtener la cita:", errorBody);
            ctx.response.status = responseGET.status;
            ctx.response.body = { error: 'Error al obtener la cita', details: errorBody };
            return;
        }
        const result = await responseGET.json();
        const date = result.fields.date.stringValue;
        const time = result.fields.time.stringValue;
        const vetId = result.fields.vetId.stringValue;
        
        const {databaseIndex, buttonId, day} = getDateInfoForDelete(date, time); 
        
        
        //Fetching Vet
        const vetUrl = `${FirestoreBaseUrl}/vets/${vetId}`;
            const response = await fetch(vetUrl, {
        method: "GET",
        headers: { "Content-Type": "application/json" },
        });
        const resultVet = await response.json();
        
        if (!response.ok) {
            const errorBody = await response.json();
            console.error("⚠️ Error al obtener la clínica del veterinario:", errorBody);
            ctx.response.status = response.status;
            ctx.response.body = { error: 'Error al obtener la clínica del veterinario', details: errorBody };
            return;
        }
        const clinicId:string = resultVet.fields.clinicId.stringValue;
        const documentPath = `blocked_date`;
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
        //Fetching Blocked Dates
        const responseApp = await fetch(FirestoreQueryUrl, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify(query)
        });
        if (!response.ok) {
            const errorBody = await response.json();
            console.error("⚠️ Error al procesar la solicitud de calendario:", errorBody);
            ctx.response.status = response.status;
            ctx.response.body = { error: "Error interno del servidor al obtener calendario" };
            return;
        }
        const resultApp = await responseApp.json();
        // console.log("Firestore result:", resultApp);
        const documentId = resultApp[0].document.name.split("/").pop();

        const existingDocFields = (resultApp && resultApp[0] && resultApp[0].document && resultApp[0].document.fields)
                              ? JSON.parse(JSON.stringify(resultApp[0].document.fields))
                              : { clinicId: { stringValue: clinicId } };
        
        const buttonIdString = String(buttonId);
        if (existingDocFields && existingDocFields[databaseIndex] &&
            existingDocFields[databaseIndex].mapValue && existingDocFields[databaseIndex].mapValue.fields &&
            existingDocFields[databaseIndex].mapValue.fields[day] &&
            existingDocFields[databaseIndex].mapValue.fields[day].mapValue &&
            existingDocFields[databaseIndex].mapValue.fields[day].mapValue.fields &&
            existingDocFields[databaseIndex].mapValue.fields[day].mapValue.fields[buttonIdString]) {

            // Eliminar el buttonId específico
            delete existingDocFields[databaseIndex].mapValue.fields[day].mapValue.fields[buttonIdString];
            

            // Si el día queda vacío después de eliminar el buttonId, eliminar el día
            if (Object.keys(existingDocFields[databaseIndex].mapValue.fields[day].mapValue.fields).length === 0) {
                delete existingDocFields[databaseIndex].mapValue.fields[day];

                // Si el mes queda vacío después de eliminar el día, eliminar el mes
                if (Object.keys(existingDocFields[databaseIndex].mapValue.fields).length === 0) {
                    delete existingDocFields[databaseIndex];
                }
            }
        } else {
            console.log(`⚠️ No buttonId: ${buttonIdString} found for day: ${day}, month: ${databaseIndex}`);
            ctx.response.status = 404;
            ctx.response.body = { error: 'No se encontró el buttonId para eliminar' };
            return;
        }
        

        const documentPathCommit = `blocked_date/${documentId}`;
        const commitUrl = `${FirestoreBaseUrl}:commit`;
        const documentResourceName = `${documentName}/${documentPathCommit}`;
        
        const commitPayload = {
            writes: [
                {
                    update: {
                        name: documentResourceName, 
                        fields: existingDocFields 
                    },
                }
            ],
        };
        
        console.log("✅ Commit payload done");
        
        const responseDelCal = await fetch(commitUrl, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify(commitPayload),
        });

        if (!responseDelCal.ok) {
            const errorBody = await responseDelCal.json();
            console.error("⚠️ Error al eliminat fecha bloqueada en calendario:", errorBody);
            ctx.response.status = responseDelCal.status;
            ctx.response.body = { error: 'Error al eliminar la fecha bloqueada en calendario', details: errorBody };
            return;
        }
         //Deleting Appointment
        const responseDEL = await fetch(appointmentUrl, {
            method: "DELETE",
            headers: { "Content-Type": "application/json" },
        });

        if (!responseDEL.ok) {
            const errorBody = await responseDEL.json();
            console.error("⚠️ Error al eliminar la cita:", errorBody);
            ctx.response.status = responseDEL.status;
            ctx.response.body = { error: 'Error al eliminar la cita', details: errorBody };
            return;
        }
        console.log("✅ Cita eliminada correctamente");
        ctx.response.status = 200;
        ctx.response.body = { message: 'Cita eliminada correctamente' };

    } catch (error) {
        console.error("⚠️ Excepción al eliminar la cita:", error);
        ctx.response.status = 500;
        ctx.response.body = { error: 'Excepción interna del servidor' };
    }
}

export async function getAppointmentById(ctx: RouterContext<"/api/getAppointment/:id">) {
    const appointmentId = ctx.params.id; 
    if (!appointmentId) {
        ctx.response.status = 400;
        ctx.response.body = { error: "ID de cita no proporcionado" };
        return;
    }
    const appointmentUrl = `${FirestoreBaseUrl}/appointments/${appointmentId}`;
    try {
        const response = await fetch(appointmentUrl, {
            method: "GET",
            headers: { "Content-Type": "application/json" },
        });
        if (!response.ok) {
            const errorBody = await response.json();
            console.error("⚠️ Error al obtener la cita:", errorBody);
            ctx.response.status = response.status;
            ctx.response.body = { error: 'Error al obtener la cita', details: errorBody };
            return;
        }
        const result = await response.json();
        console.log("✅ Cita encontrada:", appointmentId);

        const vetId = result.fields.vetId.stringValue;
        const vetUrl = `${FirestoreBaseUrl}/vets/${vetId}`;
        const responseVet = await fetch(vetUrl, {
            method: "GET",
            headers: { "Content-Type": "application/json" },
        });
        if (!responseVet.ok) {
            const errorBody = await responseVet.json();
            console.error("⚠️ Error al obtener la clínica del veterinario:", errorBody);
            ctx.response.status = responseVet.status;
            ctx.response.body = { error: 'Error al obtener la clínica del veterinario', details: errorBody };
            return;
        }
        const resultVet = await responseVet.json();
        console.log("✅ Veterinario encontrado:", vetId);
        const clinicId = resultVet.fields.clinicId.stringValue;
        const clinicUrl = `${FirestoreBaseUrl}/clinic/${clinicId}`;
        const responseClinic = await fetch(clinicUrl, {
            method: "GET",
            headers: { "Content-Type": "application/json" },
        });
        if (!responseClinic.ok) {
            const errorBody = await responseClinic.json();
            console.error("⚠️ Error al obtener la clínica:", errorBody);
            ctx.response.status = responseClinic.status;
            ctx.response.body = { error: 'Error al obtener la clínica', details: errorBody };
            return;
        }
        const resultClinic = await responseClinic.json();
        console.log("✅ Clínica encontrada:", clinicId);
        const clinicName = resultClinic.fields.name.stringValue;
        const petId = result.fields.petId.stringValue;
        const petUrl = `${FirestoreBaseUrl}/pets/${petId}`;
        const responsePet = await fetch(petUrl, {
            method: "GET",
            headers: { "Content-Type": "application/json" },
        });
        if (!responsePet.ok) {
            const errorBody = await responsePet.json();
            console.error("⚠️ Error al obtener la mascota:", errorBody);
            ctx.response.status = responsePet.status;
            ctx.response.body = { error: 'Error al obtener la mascota', details: errorBody };
            return;
        }
        const resultPet = await responsePet.json();
        console.log("✅ Mascota encontrada:", petId);
        const ownerId = resultPet.fields.owner.stringValue;
        const ownerUrl = `${FirestoreBaseUrl}/users/${ownerId}`;
        const responseOwner = await fetch(ownerUrl, {
            method: "GET",
            headers: { "Content-Type": "application/json" },
        });
        if (!responseOwner.ok) {
            const errorBody = await responseOwner.json();
            console.error("⚠️ Error al obtener el propietario:", errorBody);
            ctx.response.status = responseOwner.status;
            ctx.response.body = { error: 'Error al obtener el propietario', details: errorBody };
            return;
        }
        const resultOwner = await responseOwner.json();
        console.log("✅ Propietario encontrado:", ownerId);


        const ownerPhone= resultOwner.fields.phone.stringValue;
        const vetName = resultVet.fields.firstName.stringValue + " " + resultVet.fields.lastName.stringValue;
        const ownerName = resultOwner.fields.firstName.stringValue + " " + resultOwner.fields.lastName.stringValue;

        const appointmentData = {
            id: appointmentId,
            date: result.fields.date.stringValue,
            time: result.fields.time.stringValue,
            vetName: vetName,
            clinicName: clinicName,
            petName: resultPet.fields.name.stringValue,
            petType: resultPet.fields.type.stringValue,
            petBreed: resultPet.fields.breed.stringValue,
            ownerName: ownerName,
            ownerEmail: resultOwner.fields.email.stringValue,
            ownerPhone: ownerPhone,
            ownerId: ownerId,
            clinicId: clinicId,
            vetId: vetId,
            petId: petId
        }
        console.log("✅ Cita obtenida:", appointmentData);
        ctx.response.status = 200;
        ctx.response.body = appointmentData;

    } catch (error) {
        console.error("⚠️ Excepción al obtener la cita:", error);
        ctx.response.status = 500;
        ctx.response.body = { error: 'Excepción interna del servidor' };
    }
}