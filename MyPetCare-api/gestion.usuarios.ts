import {fs, db} from "./firebaseconfig/firebase.ts"

/*
Read functions
*/
export async function getAllPets() {
    const pets_collection = fs.query(fs.collection(db, "pets"))
    const querySnapshot = await fs.getDocs(pets_collection)
    const pets = querySnapshot.docs.map(doc => {
        const data = doc.data();
        
        // Process the data to convert Firestore timestamp to a human-readable date
        const lastUpdate = data.lastUpdate;
        const lastUpdateDate = new Date(lastUpdate.seconds * 1000 + lastUpdate.nanoseconds / 1000000); // Convert to milliseconds
        
        return {
            id: doc.id,
            name: data.name,
            type: data.type,
            breed: data.breed,
            weight: data.weight,
            age: data.age,
            lastUpdate: lastUpdateDate.toLocaleString(), // Human-readable date
            photoUrls: data.photoUrls
        }
    })
    return pets
}

export async function getAllUsers() {
    const users_collection = fs.query(fs.collection(db, "users"))
    const querySnapshot = await fs.getDocs(users_collection)
    const users = querySnapshot.docs.map(doc => {
        const data = doc.data();
        
        return {
            id: doc.id,
            name: data.firstName + " " + data.surName,
            email: data.email,
            accountType: data.accountType,
            phone: data.phone,
        }
    });
    return users
}

export async function getUserById(userId: string) {
    const userRef = fs.doc(db, "users", userId);
    const docSnap = await fs.getDoc(userRef);
    if (docSnap.exists()) {
        const data = docSnap.data();
        
        return {
            id: docSnap.id,
            name: data.firstName + " " + data.surName,
            email: data.email,
            accountType: data.accountType,
            phone: data.phone,
        }
    } else {
        console.log("No such document!");
        return null;
    }
}

/*
User management functions
*/
export async function updatePhoneNumber(userId: string, newPhoneNumber: string) {
    try{
        const userRef = fs.doc(db, "users", userId);
        await fs.updateDoc(userRef, {
            phone: newPhoneNumber
        });
        console.log("Phone number updated successfully!");
    }catch (error) {
        console.error("Error updating phone number:", error);
    }
}

export async function updateFirstName(userId: string, newFirstName: string) {
    try{
        const userRef = fs.doc(db, "users", userId);
        await fs.updateDoc(userRef, {
            firstName: newFirstName
        });
        console.log("Firstname updated successfully!");
    }catch (error) {
        console.error("Error updating first name:", error);
    }
}

export async function updateSurName(userId: string, newSurName: string) {
    try{
        const userRef = fs.doc(db, "users", userId);
        await fs.updateDoc(userRef, {
            surName: newSurName
        });
        console.log("Surname updated successfully!");
    }catch (error) {
        console.error("Error updating surname:", error);
    }
}

// export async function deleteUser(userId: string) {
//     const userRef = fs.doc(db, "users", userId);
//     await fs.deleteDoc(userRef);
// }

// Test the functions
console.log("Get all pets", await getAllPets())
console.log("Get all users", await getAllUsers())

console.log("Get user by id", await getUserById("bj1NKBFjux4joPrtq5qq"))
await updatePhoneNumber("bj1NKBFjux4joPrtq5qq", "+34622898909")
await updateFirstName("bj1NKBFjux4joPrtq5qq", "Jorge")
await updateSurName("bj1NKBFjux4joPrtq5qq", "Gonzalez")

//Close deno process to exit
Deno.exit(0)