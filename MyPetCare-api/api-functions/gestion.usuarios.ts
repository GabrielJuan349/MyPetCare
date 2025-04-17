import {fs, db} from "../firebaseconfig/firebase.ts"

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
Update user data
*/
export async function updateUser(userId:string, fields) {
    const userRef = fs.doc(db, "users", userId);

    try{
        const docSnap = await fs.getDoc(userRef);
        if(!docSnap.exists()){
            return{//User doesn't exist
                status: 404,
                message: "User not found",
            };
        }
        if(Object.keys(fields).length==0){
            return{//No fields passed to update
                status: 400,
                message: "Error in the submitted data"
            }
        }

        await fs.updateDoc(userRef, fields);

        return{//Success
            status: 200,
            message: "User data updated successfully"
        }

    }catch(e){
        console.error("User update error: ", e);
        return{
            status: 500,
            message: "Internal server error",
        };
    }
}

/*
Delete user
*/
export async function deleteUser(userId: string) {
    try{
        const userRef = fs.doc(db, "users", userId);
        const docSnap = await fs.getDoc(userRef);
        if(!docSnap.exists()){
            return{
                status: 404,
                message: "User not found",
            };
        }

        await fs.deleteDoc(userRef);

        return{
            status: 200,
            message: "User deleted successfully"
        };

    }catch(e){
        console.log("User delete error:", e);
        return{
            status:400,
            message: "Request error"
        };
    }
}

// Test the functions
// console.log("Get all pets", await getAllPets())
// console.log("Get all users", await getAllUsers())

// console.log("Get user by id", await getUserById("bj1NKBFjux4joPrtq5qq"))