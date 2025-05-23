// import { randomInt } from 'node:crypto';
import { functionResponse, getDateInfoReturn } from '../interfaces/appointments.interface.ts';

const FIREBASE_PROJECT_ID = Deno.env.get('FIREBASE_PROJECT_ID');
// La URL para ejecutar queries, la colección se especifica en el cuerpo de la query.
export const FirestoreQueryUrl =
  `https://firestore.googleapis.com/v1/projects/${FIREBASE_PROJECT_ID}/databases/(default)/documents:runQuery`;
export const FirestoreBaseUrl =
  `https://firestore.googleapis.com/v1/projects/${FIREBASE_PROJECT_ID}/databases/(default)/documents`;
export const documentName = `projects/${FIREBASE_PROJECT_ID}/databases/(default)/documents`;

export function getDateInfo(date: string, time: string): getDateInfoReturn {
  const dateParts = date.split('-');
  const year = dateParts[0];
  const month = dateParts[1];
  const day = dateParts[2];
  const hourParts = time.split(':');
  console.log(`✅ Hour parts: ${hourParts}`);
  const buttonId = (parseInt(hourParts[0]) - 9) * 4 + (parseInt(hourParts[1]) / 15);

  return {
    databaseIndex: getDatabaseDate(month, year),
    day,
    buttonId,
  };
}
export function getDatabaseDate(month: string, year: string) {
  const Months: Array<string> = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  const monthIndex: string = Months[parseInt(month) - 1];
  console.log(`✅ Database date Index`);
  return monthIndex + '_' + year;
}
/*
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
*/

export async function createAppointmenInDatabase(
  date: Date,
  hour: string,
  type: string,
  reason: string,
  petId: string,
  vetId: string,
) {
  const hourSplit = hour.split(':');
  const hoursFromJournal = [parseInt(hourSplit[0]), parseInt(hourSplit[1])];

  if (
    hoursFromJournal[0] > 17 || hoursFromJournal[0] < 9 ||
    (hoursFromJournal[0] == 17 && hoursFromJournal[1] > 0)
  ) {
    console.log('La hora de la cita está fuera del horario laboral');
    return Error('La hora de la cita está fuera del horario laboral');
  }

  const appointmentUrl = `${FirestoreBaseUrl}/appointments`;
  try {
    const response = await fetch(appointmentUrl, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        fields: {
          date: { stringValue: date.toLocaleDateString('fr-CA') },
          time: { stringValue: hour },
          type: { stringValue: type },
          reason: { stringValue: reason },
          petId: { stringValue: petId },
          vetId: { stringValue: vetId },
          createdAt: { stringValue: new Date().toISOString() },
        },
      }),
    });

    const result = await response.json();
    const appointId = result.name.split('/').pop();
    console.log(`✅ Cita creada en Firestore con ID: ${appointId}`);
    return appointId;
  } catch (error) {
    console.error('⚠️ Error al crear la cita:', error);
    return;
  }
}

export async function updateBlockedDate(
  clinicId: string,
  databaseIndex: string,
  day: string,
  buttonId: number,
  appointmentId: string,
): Promise<functionResponse> {
  let documentPath: string = `blocked_date`;

  const query = {
    structuredQuery: {
      from: [{ collectionId: documentPath }],
      where: {
        fieldFilter: {
          field: { fieldPath: 'clinicId' },
          op: 'EQUAL',
          value: { stringValue: clinicId },
        },
      },
    },
  };
  // deno-lint-ignore no-explicit-any
  let documentId: string, result: any;
  try {
    const response = await fetch(FirestoreQueryUrl, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(query),
    });
    if (!response.ok) {
      const errorBody = await response.text();
      console.error('⚠️ Error de Firestore:', response.status, errorBody);

      return {
        error: {
          status: response.status,
          body: { error: 'Error al obtener las citas de Firestore', details: errorBody },
        },
        done: false,
      };
    }
    const queryResult = await response.json();
    console.log(`✅ Calendar information for clinicId ${clinicId} collected`);

    if (queryResult && queryResult.length > 0 && queryResult[0].document) {
      result = queryResult;
      documentId = result[0].document.name.split('/').pop();
      console.log('✅ Document ID found:', documentId);
    } else {
      console.log(`🔜 No document found for clinicId ${clinicId} in ${documentPath}.`);
      const createDocUrl = `${FirestoreBaseUrl}/${documentPath}`;

      const createResponse = await fetch(createDocUrl, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          fields: {
            clinicId: { stringValue: clinicId },
          },
        }),
      });

      if (!createResponse.ok) {
        const errorBody = await createResponse.text();
        console.error('⚠️ Error creating document in Firestore:', createResponse.status, errorBody);
        return {
          error: {
            status: createResponse.status,
            body: { error: 'Error creating document in Firestore', details: errorBody },
          },
          done: false,
        };
      }
      const newDocument = await createResponse.json();
      documentId = newDocument.name.split('/').pop();
      console.log(`✅ New document created with ID: ${documentId}`);
    }
  } catch (err) {
    console.error(`⚠️ Error al procesar la solicitud de citas: ${err}`);
    return {
      error: {
        status: 500,
        body: { error: 'Error al procesar la solicitud de citas', details: err },
      },
      done: false,
    };
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

  if (!monthFields[day]) {
    monthFields[day] = { mapValue: { fields: {} } };
  } else if (!monthFields[day].mapValue) {
    monthFields[day].mapValue = { fields: {} };
  } else if (!monthFields[day].mapValue.fields) {
    monthFields[day].mapValue.fields = {};
  }

  const dayFields = monthFields[day].mapValue.fields;

  dayFields[buttonId] = { stringValue: String(appointmentId) };

  documentPath = `blocked_date/${documentId}`;
  const commitUrl = `${FirestoreBaseUrl}:commit`;

  const documentResourceName = `${documentName}/${documentPath}`;

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
  try {
    const response = await fetch(commitUrl, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(commitPayload),
    });

    if (!response.ok) {
      const errorBody = await response.json();
      console.error('Error al registrar fecha bloqueada:', errorBody);
      return {
        error: {
          status: response.status,
          body: { error: 'Error al registrar fecha bloqueada', details: errorBody },
        },
        done: false,
      };
    } else {
      return { done: true };
    }
  } catch (error) {
    console.error('Excepción al registrar fecha bloqueada:', error);
    return {
      error: {
        status: 500,
        body: { error: 'Error al registrar fecha bloqueada', details: error },
      },
      done: false,
    };
  }
}
