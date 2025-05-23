import { RouterContext } from 'oak';
import {
  createAppointmenInDatabase,
  documentName,
  FirestoreBaseUrl,
  FirestoreQueryUrl,
  getDateInfo,
  updateBlockedDate,
} from './utils.ts';
import {
  AppDataById,
  AppointmentsIdAll,
  AppointmentsInfoAll,
} from '../interfaces/appointments.interface.ts';

export async function getCitasByVetId(ctx: RouterContext<'/api/appointment/vet/:vetId'>) {
  console.log('🚧 Citas por veterinario');
  const vetId = ctx.params.vetId;

  if (!vetId) {
    console.error('⚠️ Error: ID de veterinario no proporcionado');
    ctx.response.status = 400;
    ctx.response.body = { error: 'ID de veterinario no proporcionado' };
    return;
  }
  console.log('✅ ID de veterinario conseguido');

  const query = {
    structuredQuery: {
      from: [{ collectionId: 'appointments' }],
      where: {
        fieldFilter: {
          field: { fieldPath: 'vetId' },
          op: 'EQUAL',
          value: { stringValue: vetId },
        },
      },
    },
  };

  try {
    const response = await fetch(FirestoreQueryUrl, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(query),
    });

    if (!response.ok) {
      const errorBody = await response.text();
      console.error('⚠️ Error de Firestore:', response.status, errorBody);
      ctx.response.status = response.status;
      ctx.response.body = { error: 'Error al obtener las citas de Firestore', details: errorBody };
      return;
    }

    const result = await response.json();

    const citas = result
      .filter((entry: any) => entry.document)
      .map((entry: any) => {
        const fields = entry.document.fields;
        const citaData: any = {};
        for (const fieldName in fields) {
          if (fieldName != 'clinicId') {
            const valueWrapper = fields[fieldName];
            const valueType = Object.keys(valueWrapper)[0];
            citaData[fieldName] = valueWrapper[valueType];
          }
        }

        return citaData;
      });
    console.log(`✅ Citas del vererinario obtenidas`);

    ctx.response.status = 200;
    ctx.response.body = citas;
  } catch (error) {
    console.error('⚠️ Error al procesar la solicitud de citas:', error);
    ctx.response.status = 500;
    ctx.response.body = { error: 'Error interno del servidor al obtener citas' };
  }
}

export async function deleteAppointment(ctx: RouterContext<'/api/appointment/:id'>) {
  console.log('🚧 Delete appointment');
  const appointmentId = ctx.params.id;
  if (!appointmentId) {
    ctx.response.status = 400;
    ctx.response.body = { error: 'ID de cita no proporcionado' };
    return;
  }
  const appointmentUrl = `${FirestoreBaseUrl}/appointments/${appointmentId}`;
  try {
    //Fetching Appointment
    const responseGET = await fetch(appointmentUrl, {
      method: 'GET',
      headers: { 'Content-Type': 'application/json' },
    });
    if (!responseGET.ok) {
      const errorBody = await responseGET.json();
      console.error('Error al obtener la cita:', errorBody);
      ctx.response.status = responseGET.status;
      ctx.response.body = { error: 'Error al obtener la cita', details: errorBody };
      return;
    }
    const result = await responseGET.json();
    const date = result.fields.date.stringValue;
    const time = result.fields.time.stringValue;
    const vetId = result.fields.vetId.stringValue;

    const { databaseIndex, buttonId, day } = getDateInfo(date, time);

    //Fetching Vet
    const vetUrl = `${FirestoreBaseUrl}/users/${vetId}`;
    const response = await fetch(vetUrl, {
      method: 'GET',
      headers: { 'Content-Type': 'application/json' },
    });
    const resultVet = await response.json();

    if (!response.ok) {
      const errorBody = await response.json();
      console.error('⚠️ Error al obtener la clínica del veterinario:', errorBody);
      ctx.response.status = response.status;
      ctx.response.body = {
        error: 'Error al obtener la clínica del veterinario',
        details: errorBody,
      };
      return;
    }
    const clinicId: string = resultVet.fields.clinicId.stringValue;
    const documentPath = `blocked_date`;
    const query = {
      structuredQuery: {
        from: [{ collectionId: documentPath }], // Nombre de tu colección de citas
        where: {
          fieldFilter: {
            field: { fieldPath: 'clinicId' }, // Campo para filtrar por ID de veterinario
            op: 'EQUAL',
            value: { stringValue: clinicId },
          },
        },
      },
    };
    //Fetching Blocked Dates
    const responseApp = await fetch(FirestoreQueryUrl, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(query),
    });
    if (!response.ok) {
      const errorBody = await response.json();
      console.error('⚠️ Error al procesar la solicitud de calendario:', errorBody);
      ctx.response.status = response.status;
      ctx.response.body = { error: 'Error interno del servidor al obtener calendario' };
      return;
    }
    const resultApp = await responseApp.json();
    // console.log("Firestore result:", resultApp);
    const documentId = resultApp[0].document.name.split('/').pop();

    const existingDocFields =
      (resultApp && resultApp[0] && resultApp[0].document && resultApp[0].document.fields)
        ? JSON.parse(JSON.stringify(resultApp[0].document.fields))
        : { clinicId: { stringValue: clinicId } };

    const buttonIdString = String(buttonId);
    if (
      existingDocFields && existingDocFields[databaseIndex] &&
      existingDocFields[databaseIndex].mapValue &&
      existingDocFields[databaseIndex].mapValue.fields &&
      existingDocFields[databaseIndex].mapValue.fields[day] &&
      existingDocFields[databaseIndex].mapValue.fields[day].mapValue &&
      existingDocFields[databaseIndex].mapValue.fields[day].mapValue.fields &&
      existingDocFields[databaseIndex].mapValue.fields[day].mapValue.fields[buttonIdString]
    ) {
      // Eliminar el buttonId específico
      delete existingDocFields[databaseIndex].mapValue.fields[day].mapValue.fields[buttonIdString];

      // Si el día queda vacío después de eliminar el buttonId, eliminar el día
      if (
        Object.keys(existingDocFields[databaseIndex].mapValue.fields[day].mapValue.fields)
          .length === 0
      ) {
        delete existingDocFields[databaseIndex].mapValue.fields[day];

        // Si el mes queda vacío después de eliminar el día, eliminar el mes
        if (Object.keys(existingDocFields[databaseIndex].mapValue.fields).length === 0) {
          delete existingDocFields[databaseIndex];
        }
      }
    } else {
      console.log(
        `⚠️ No buttonId: ${buttonIdString} found for day: ${day}, month: ${databaseIndex}`,
      );
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
            fields: existingDocFields,
          },
        },
      ],
    };

    console.log('✅ Commit payload done');

    const responseDelCal = await fetch(commitUrl, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(commitPayload),
    });

    if (!responseDelCal.ok) {
      const errorBody = await responseDelCal.json();
      console.error('⚠️ Error al eliminat fecha bloqueada en calendario:', errorBody);
      ctx.response.status = responseDelCal.status;
      ctx.response.body = {
        error: 'Error al eliminar la fecha bloqueada en calendario',
        details: errorBody,
      };
      return;
    }
    //Deleting Appointment
    const responseDEL = await fetch(appointmentUrl, {
      method: 'DELETE',
      headers: { 'Content-Type': 'application/json' },
    });

    if (!responseDEL.ok) {
      const errorBody = await responseDEL.json();
      console.error('⚠️ Error al eliminar la cita:', errorBody);
      ctx.response.status = responseDEL.status;
      ctx.response.body = { error: 'Error al eliminar la cita', details: errorBody };
      return;
    }
    console.log('✅ Cita eliminada correctamente');
    ctx.response.status = 200;
    ctx.response.body = { message: 'Cita eliminada correctamente' };
  } catch (error) {
    console.error('⚠️ Excepción al eliminar la cita:', error);
    ctx.response.status = 500;
    ctx.response.body = { error: 'Excepción interna del servidor' };
  }
}

export async function getAppointmentById(ctx: RouterContext<'/api/getAppointment/:id'>) {
  console.log('🚧 Get appointment by ID');
  const appointmentId = ctx.params.id;
  if (!appointmentId) {
    ctx.response.status = 400;
    ctx.response.body = { error: 'ID de cita no proporcionado' };
    return;
  }
  const appointmentUrl = `${FirestoreBaseUrl}/appointments/${appointmentId}`;
  try {
    const response = await fetch(appointmentUrl, {
      method: 'GET',
      headers: { 'Content-Type': 'application/json' },
    });
    if (!response.ok) {
      const errorBody = await response.json();
      console.error('⚠️ Error al obtener la cita:', errorBody);
      ctx.response.status = response.status;
      ctx.response.body = { error: 'Error al obtener la cita', details: errorBody };
      return;
    }
    const result = await response.json();
    console.log('✅ Cita encontrada:', appointmentId);

    const vetId = result.fields.vetId.stringValue;
    const vetUrl = `${FirestoreBaseUrl}/users/${vetId}`;
    const responseVet = await fetch(vetUrl, {
      method: 'GET',
      headers: { 'Content-Type': 'application/json' },
    });
    if (!responseVet.ok) {
      const errorBody = await responseVet.json();
      console.error('⚠️ Error al obtener la clínica del veterinario:', errorBody);
      ctx.response.status = responseVet.status;
      ctx.response.body = {
        error: 'Error al obtener la clínica del veterinario',
        details: errorBody,
      };
      return;
    }
    const resultVet = await responseVet.json();
    console.log('✅ Veterinario encontrado:', vetId);
    const clinicId = resultVet.fields.clinicId.stringValue;
    console.log('✅ Clínica encontrada:', clinicId);
    const petId = result.fields.petId.stringValue;
    console.log('✅ Mascota encontrada:', petId);
    const petUrl = `${FirestoreBaseUrl}/pets/${petId}`;
    const responsePet = await fetch(petUrl, {
      method: 'GET',
      headers: { 'Content-Type': 'application/json' },
    });
    if (!responsePet.ok) {
      const errorBody = await responsePet.json();
      console.error('⚠️ Error al obtener la mascota:', errorBody);
      ctx.response.status = responsePet.status;
      ctx.response.body = { error: 'Error al obtener la mascota', details: errorBody };
      return;
    }
    const resultPet = await responsePet.json();
    const ownerId = resultPet.fields.owner.stringValue;
    console.log('✅ Propietario encontrado:', ownerId);

    const appointmentData: AppDataById = {
      id: appointmentId,
      date: result.fields.date.stringValue,
      time: result.fields.time.stringValue,
      type: result.fields.type.stringValue,
      reason: result.fields.reason.stringValue,
      userId: ownerId,
      clinicId: clinicId,
      vetId: vetId,
      petId: petId,
    };
    console.log('✅ Cita obtenida:', appointmentData);
    ctx.response.status = 200;
    ctx.response.body = appointmentData;
  } catch (error) {
    console.error('⚠️ Excepción al obtener la cita:', error);
    ctx.response.status = 500;
    ctx.response.body = { error: 'Excepción interna del servidor' };
  }
}

export async function getAllAppointmentsFromOwner(
  ctx: RouterContext<'/api/appointment/owner/:id'>,
) {
  console.log('🚧 Get all appointments from owner');
  const ownerId = ctx.params.id;
  if (!ownerId) {
    ctx.response.status = 400;
    ctx.response.body = { error: 'ID de propietario no proporcionado' };
    return;
  }
  const query = {
    structuredQuery: {
      from: [{ collectionId: 'pets' }],
      where: {
        fieldFilter: {
          field: { fieldPath: 'owner' },
          op: 'EQUAL',
          value: { stringValue: ownerId },
        },
      },
    },
  };

  try {
    const response = await fetch(FirestoreQueryUrl, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(query),
    });

    if (!response.ok) {
      const errorBody = await response.text();
      console.error('⚠️ Error de Firestore:', response.status, errorBody);
      ctx.response.status = response.status;
      ctx.response.body = { error: 'Error al obtener las citas de Firestore', details: errorBody };
      return;
    }

    const resultPets = await response.json();
    const petsIds: Array<string> = [];
    for (const entry of resultPets) {
      if (entry.document) {
        petsIds.push(entry.document.name.split('/').pop());
      }
    }
    console.log('✅ IDs de mascotas encontradas');
    const queryApp = {
      structuredQuery: {
        from: [{ collectionId: 'appointments' }],
        where: {
          fieldFilter: {
            field: { fieldPath: 'petId' },
            op: 'IN',
            value: { arrayValue: { values: petsIds.map((id) => ({ stringValue: id })) } },
          },
        },
      },
    };
    const responseApp = await fetch(FirestoreQueryUrl, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(queryApp),
    });
    if (!responseApp.ok) {
      const errorBody = await responseApp.text();
      console.error('⚠️ Error de Firestore:', responseApp.status, errorBody);
      ctx.response.status = responseApp.status;
      ctx.response.body = { error: 'Error al obtener las citas de Firestore', details: errorBody };
      return;
    }
    const resultApp = await responseApp.json();
    console.log('✅ Citas encontradas para el propietario');
    const appointmentsArray: Array<AppointmentsInfoAll> = [];
    const appointmentsIds: Array<AppointmentsIdAll> = [];

    for (const entry of resultApp) {
      if (entry.document) {
        const fields = entry.document.fields;
        const appointmentData: AppointmentsInfoAll = { id: '', date: '', time: '' };
        const appIds: AppointmentsIdAll = { petId: '', vetId: '' };
        appointmentData.id = entry.document.name.split('/').pop();
        for (const fieldName in fields) {
          if (fieldName != 'createdAt' && fieldName != 'petId' && fieldName != 'vetId') {
            const valueWrapper = fields[fieldName];
            const valueType = Object.keys(valueWrapper)[0];
            appointmentData[fieldName as keyof AppointmentsInfoAll] = valueWrapper[valueType];
          } else if (fieldName == 'petId' || fieldName == 'vetId') {
            const valueWrapper = fields[fieldName];
            const valueType = Object.keys(valueWrapper)[0];
            appIds[fieldName as keyof AppointmentsIdAll] = valueWrapper[valueType];
          }
        }
        appointmentsArray.push(appointmentData);
        appointmentsIds.push(appIds);
      }
    }
    console.log('✅ Citas obtenidas');
    console.log('✅ IDs de citas obtenidas');

    // deno-lint-ignore no-explicit-any
    const appPetsInfo: any = {};
    // deno-lint-ignore no-explicit-any
    const appVetsInfo: any = {};
    // deno-lint-ignore no-explicit-any
    const vetforClinic: any = {};
    // deno-lint-ignore no-explicit-any
    const appClinicsInfo: any = {};

    for (let index = 0; index < appointmentsIds.length; index++) {
      const appointment = appointmentsIds[index];

      if (appPetsInfo[appointment.petId]) {
        appointmentsArray[index].petName = appPetsInfo[appointment.petId];
      } else {
        const petId = appointment.petId;
        const petUrl = `${FirestoreBaseUrl}/pets/${petId}`;
        const responsePet = await fetch(petUrl, {
          method: 'GET',
          headers: { 'Content-Type': 'application/json' },
        });
        if (!responsePet.ok) {
          const errorBody = await responsePet.json();
          console.error('⚠️ Error al obtener la mascota:', errorBody);
          ctx.response.status = responsePet.status;
          ctx.response.body = { error: 'Error al obtener la mascota', details: errorBody };
          return;
        }
        const resultPet = await responsePet.json();
        appointmentsArray[index].petName = resultPet.fields.name.stringValue;
        console.log('✅ Mascota encontrada');
      }

      if (appVetsInfo[appointment.vetId]) {
        appointmentsArray[index].vetName = appVetsInfo[appointment.vetId];
      } else {
        const vetId = appointment.vetId;
        const vetUrl = `${FirestoreBaseUrl}/vets/${vetId}`;
        const responseVet = await fetch(vetUrl, {
          method: 'GET',
          headers: { 'Content-Type': 'application/json' },
        });
        if (!responseVet.ok) {
          const errorBody = await responseVet.json();
          console.error('⚠️ Error al obtener el veterinario:', errorBody);
          ctx.response.status = responseVet.status;
          ctx.response.body = { error: 'Error al obtener el veterinario', details: errorBody };
          return;
        }
        const resultVet = await responseVet.json();
        const VetName = resultVet.fields.firstName.stringValue + ' ' +
          resultVet.fields.lastName.stringValue;
        appointmentsArray[index].vetName = VetName;
        appVetsInfo[vetId] = VetName;
        vetforClinic[vetId] = resultVet.fields.clinicId.stringValue;
        console.log('✅ Veterinario encontrado');
      }

      const clinicId = vetforClinic[appointment.vetId];
      if (appClinicsInfo[vetforClinic[appointment.vetId]]) {
        appointmentsArray[index].clinicName = appClinicsInfo[clinicId];
      } else {
        const clinicUrl = `${FirestoreBaseUrl}/clinic/${clinicId}`;
        const responseClinic = await fetch(clinicUrl, {
          method: 'GET',
          headers: { 'Content-Type': 'application/json' },
        });
        if (!responseClinic.ok) {
          const errorBody = await responseClinic.json();
          console.error('⚠️ Error al obtener la clínica:', errorBody);
          ctx.response.status = responseClinic.status;
          ctx.response.body = { error: 'Error al obtener la clínica', details: errorBody };
          return;
        }
        const resultClinic = await responseClinic.json();
        appointmentsArray[index].clinicName = resultClinic.fields.name.stringValue;
        appClinicsInfo[clinicId] = resultClinic.fields.name.stringValue;
        console.log('✅ Clínica encontrada');
      }
    }

    console.log('✅ Citas obtenidas');
    ctx.response.status = 200;
    ctx.response.body = appointmentsArray;
  } catch (error) {
    console.error('⚠️ Error al procesar la solicitud de citas:', error);
    ctx.response.status = 500;
    ctx.response.body = { error: 'Error interno del servidor al obtener citas' };
  }
}

export async function newAppointment(ctx: RouterContext<'/api/appointment/:id'>) {
  console.log('🚧 Nueva cita');
  const vetId = ctx.params.id;
  let requestPayload;

  if (!vetId) {
    ctx.response.status = 404;
    ctx.response.body = { error: 'Veterinario no encontrado para la clínica proporcionada' };
    return;
  }
  try {
    const body = ctx.request.body({ type: 'json' });
    requestPayload = await body.value;
  } catch (e) {
    console.error('⚠️ Failed to parse JSON body:', e.message);
    ctx.response.status = 400;
    ctx.response.body = {
      error: 'Invalid JSON payload.',
      details: `Failed to parse JSON: ${e.message}`,
    };
    return;
  }
  const { date, time, type, reason, petId, clinicId } = requestPayload;
  const dateFormated = new Date(date);
  const { databaseIndex, day, buttonId } = getDateInfo(date, time);

  if (!date || !vetId) {
    console.error('⚠️ Error: clínica, día, mes o año no proporcionado');
    ctx.response.status = 400;
    ctx.response.body = { error: 'Clínica, día, mes o año no proporcionado' };
    return;
  }
  if (!buttonId && !petId) {
    console.error('⚠️ Error: buttonId o petId no proporcionado');
    ctx.response.status = 400;
    ctx.response.body = { error: 'Debe proporcionar buttonId o petId para el bloqueo' };
    return;
  }
  const appointmentId = await createAppointmenInDatabase(
    dateFormated,
    time,
    type,
    reason,
    petId,
    vetId,
  );
  if (!appointmentId) {
    ctx.response.status = 500;
    ctx.response.body = { error: 'Error al crear la cita en Firestore' };
    return;
  }

  const { done, error } = await updateBlockedDate(
    clinicId,
    databaseIndex,
    day,
    buttonId,
    appointmentId,
  );

  if (!done) {
    const errorBody = error!.body;
    console.error('Error al registrar fecha bloqueada:', errorBody);
    ctx.response.status = error!.status;
    ctx.response.body = { error: 'Error al registrar la fecha bloqueada', details: errorBody };
    return;
  } else {
    console.log('✅ Fecha bloqueada registrada correctamente');
    ctx.response.status = 200;
    ctx.response.body = { message: 'Fecha bloqueada registrada correctamente' };
  }
}
