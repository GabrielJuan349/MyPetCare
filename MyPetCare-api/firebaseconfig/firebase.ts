/*
import firebaseAdmin from "firebase-admin";
// import * as fs from "https://www.gstatic.com/firebasejs/9.6.0/firebase-firestore.js";

let db: firebaseAdmin.firestore.Firestore;
try {

    const serviceAccount =JSON.parse(Deno.readTextFileSync("../"+Deno.env.get("FIREBASE_CREDENTIALS_NAME")!));
    console.log(serviceAccount)
    firebaseAdmin.initializeApp({
        credential: firebaseAdmin.credential.cert(serviceAccount),
    })
    console.log("Firebase Admin SDK inicializado.");
  
    // Obtén la instancia de Firestore del SDK de ADMIN
    db = firebaseAdmin.firestore();
    console.log("Instancia de Firestore (Admin) obtenida.");
  
  } catch (error) {
    console.error("Error inicializando Firebase Admin:", error);
    // Podrías querer lanzar el error o manejarlo de otra forma
    throw error;
  }

  export { db };
*/


// firebase.ts
import { initializeApp } from "https://www.gstatic.com/firebasejs/9.6.0/firebase-app.js";
import { getFirestore } from "https://www.gstatic.com/firebasejs/9.6.0/firebase-firestore.js";

const firebaseConfig = {
  apiKey: "TU_API_KEY",
  authDomain: "mypetcare-1ca5a.firebaseapp.com",
  projectId: "mypetcare-1ca5a",
  storageBucket: "mypetcare-1ca5a.appspot.com",
  messagingSenderId: "TU_MESSAGING_SENDER_ID",
  appId: "TU_APP_ID",
};

const app = initializeApp(firebaseConfig);
export const db = getFirestore(app);

