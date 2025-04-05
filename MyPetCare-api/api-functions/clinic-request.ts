import * as fa from "firebase-admin" ;

import { Clinic_Short, Clinic } from '../interfaces/clinic.interface.ts';

export function getClinics(): Clinic_Short[] {


    return [];
}
export function getClinic(id: number): Clinic | null {
    fa.firestore().collection('clinics').doc(id.toString()).get()
        .then((doc) => {
            if (doc.exists) {
                const data = doc.data();
                if (data) {
                    return data as Clinic;
                }
            } else {
                console.log("No such document!");
            }
        })
        .catch((error) => {
            console.log("Error getting document:", error);
        });
    return null;
}

export function getClinicsByCategory(id: number): Clinic_Short[] {
    
    return [];
}
