import { firestore_db } from './firebase.ts';

import { Clinic, Clinic_Short } from '../interfaces/clinic.interface.ts';

export async function getClinics() {
  console.log('getClinics');
  const clinics = await firestore_db.collection('clinic').get();
  console.log('clinics', clinics);
  return clinics;
}

export async function getClinic(id: number): Promise<Clinic | null> {
  try {
    const doc = await firestore_db.collection('clinic').doc(id.toString()).get();
    if (doc.exists) {
      const data = doc.data();
      if (data) {
        return data as Clinic;
      }
    } else {
      console.log('No such document!');
    }
  } catch (error) {
    console.log('Error getting document:', error);
  }
  return null;
}

export function getClinicsByCategory(id: number): Clinic_Short[] {
  return [];
}
