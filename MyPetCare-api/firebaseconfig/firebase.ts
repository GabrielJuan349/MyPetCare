import * as fb from "firebase-admin";
// import * as fs from "https://www.gstatic.com/firebasejs/9.6.0/firebase-firestore.js";

let db: fb.firestore.Firestore;
try {

    const serviceAccount =Deno.readTextFileSync("../"+Deno.env.get("FIREBASE_CREDENTIALS_NAME")!);
    console.log(serviceAccount)
    fb.initializeApp({
        credential: fb.credential.cert(serviceAccount),
    })
    console.log("Firebase Admin SDK inicializado.");
  
    // Obtén la instancia de Firestore del SDK de ADMIN
    db = fb.firestore();
    console.log("Instancia de Firestore (Admin) obtenida.");
  
  } catch (error) {
    console.error("Error inicializando Firebase Admin:", error);
    // Podrías querer lanzar el error o manejarlo de otra forma
    throw error;
  }

  export { db };