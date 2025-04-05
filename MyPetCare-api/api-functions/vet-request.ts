import { User } from '../interfaces/user.interface';
import { firestore } from 'firebase-admin';

export async function getVetsByClinicId(clinicId: string): Promise<User> {
  return await firestore().collection('clinics').doc(clinicId).collection('vet').get()
}