
import { db } from "./api-functions/firebase.ts";

console.log("📡 Probando conexión con Firestore…");

try {
  const snapshot = await db.collection("pets").limit(1).get();
  console.log(`✅ Conectado. Se encontraron ${snapshot.size} documento(s).`);
} catch (err) {
  console.error("❌ Error conectando con Firestore:", err);
}