import { cert, initializeApp } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';
import { dirname, fromFileUrl, join } from 'paths';

// Construir una ruta absoluta utilizando import.meta.url
const currentDir = dirname(fromFileUrl(import.meta.url));
const serviceAccountPath = join(currentDir, '..', 'serviceAccountKey.json');

// Leer el archivo de credenciales
const serviceAccountJson = await Deno.readTextFile(serviceAccountPath);
const serviceAccount = JSON.parse(serviceAccountJson);

const firebaseApp = initializeApp({
  credential: cert(serviceAccount),
  projectId: Deno.env.get('FIREBASE_PROJECT_ID'),
});
export const firestore_db = getFirestore(firebaseApp);
