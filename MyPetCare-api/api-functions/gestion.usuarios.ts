import {db} from "../firebaseconfig/firebase.ts"


/*
Read functions
*/
export async function getAllPets() {
    // Use Admin SDK collection and get methods
    const pets_collection = db.collection("pets");
    const querySnapshot = await pets_collection.get();
    const pets = querySnapshot.docs.map(doc => {
        const data = doc.data();

        // Process the data to convert Firestore timestamp to a human-readable date
        const lastUpdate = data.lastUpdate;
        // Check if lastUpdate is a Firestore Timestamp object
        if (lastUpdate && typeof lastUpdate.toDate === 'function') {
            const lastUpdateDate = lastUpdate.toDate(); // Use the toDate() method
            return {
                id: doc.id,
                name: data.name,
                type: data.type,
                breed: data.breed,
                weight: data.weight,
                age: data.age,
                lastUpdate: lastUpdateDate.toLocaleString(), // Human-readable date
                photoUrls: data.photoUrls
            };
        } else {
             // Handle cases where lastUpdate might not be a Timestamp or is missing
             return {
                id: doc.id,
                name: data.name,
                type: data.type,
                breed: data.breed,
                weight: data.weight,
                age: data.age,
                lastUpdate: 'N/A', // Or some other placeholder
                photoUrls: data.photoUrls
            };
        }
    });
    return pets;
}

export async function getAllUsers() {
    // Use Admin SDK collection and get methods
    const users_collection = db.collection("users");
    const querySnapshot = await users_collection.get();
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
    return users;
}

export async function getUserById(userId: string) {
    // Use Admin SDK collection, doc and get methods
    const userRef = db.collection("users").doc(userId);
    const docSnap = await userRef.get();
    if (docSnap.exists) { // Check exists property directly
        const data = docSnap.data()!; // Use non-null assertion if sure data exists

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
export async function updateUser(userId:string, fields: Record<string, any>) { // Add type for fields
    // Use Admin SDK collection and doc methods
    const userRef = db.collection("users").doc(userId);

    try{
        const docSnap = await userRef.get(); // Use Admin SDK get method
        if(!docSnap.exists){ // Check exists property directly
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

        // Use Admin SDK update method
        await userRef.update(fields);

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
        // Use Admin SDK collection and doc methods
        const userRef = db.collection("users").doc(userId);
        const docSnap = await userRef.get(); // Use Admin SDK get method
        if(!docSnap.exists){ // Check exists property directly
            return{
                status: 404,
                message: "User not found",
            };
        }

        // Use Admin SDK delete method
        await userRef.delete();

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