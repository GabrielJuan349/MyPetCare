//https://www.youtube.com/watch?v=dEQj7x574kU
import { initializeApp } from "https://www.gstatic.com/firebasejs/9.6.0/firebase-app.js";
import * as fs from "https://www.gstatic.com/firebasejs/9.6.0/firebase-firestore.js";
export {fs};

/*
Using env didn't work, so I created a file name secrets.ts 
with the config values of firebase
*/
import {firebaseConfig} from "./secret.ts"

//Inicialize Firebase
const app = initializeApp(firebaseConfig)
//Get firestore as the database instance
export const db = fs.getFirestore(app)