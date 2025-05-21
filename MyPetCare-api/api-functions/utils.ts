const FIREBASE_PROJECT_ID = Deno.env.get("FIREBASE_PROJECT_ID");
// La URL para ejecutar queries, la colección se especifica en el cuerpo de la query.
export const FirestoreQueryUrl = `https://firestore.googleapis.com/v1/projects/${FIREBASE_PROJECT_ID}/databases/(default)/documents:runQuery`;
export const FirestoreBaseUrl = `https://firestore.googleapis.com/v1/projects/${FIREBASE_PROJECT_ID}/databases/(default)/documents`;

export function getDatabaseDate(month: string, year: string) {
    const Months: Array<string> = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
    const monthIndex:string = Months[parseInt(month)-1];
    return monthIndex+"_"+year;
}