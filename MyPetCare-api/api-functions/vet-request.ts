// import { User } from '../interfaces/user.interface';
import { firestore_db } from './firebase.ts';

export async function getVetsByClinicId(clinicId: string) {
  try {
    const vetsSnapshot = await firestore_db.collection('vets')
      .where('clinicId', '==', clinicId)
      .get();

    const vets = vetsSnapshot.docs.map((doc) => {
      const data = doc.data();
      return {
        id: doc.id,
        ...data,
      };
    });

    return vets;
  } catch (error) {
    console.error('Error getting vets:', error);
    return [];
  }
}
