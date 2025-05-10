import { RouterContext } from "https://deno.land/x/oak@v12.6.1/mod.ts";
// Obtén la clave de la API desde las variables de entorno
const FIREBASE_PROJECT_ID = Deno.env.get("FIREBASE_PROJECT_ID"); // Asegúrate de que sea el ID del proyecto de Firebase

// URL de registro de Firebase
const FireStoreUrl = `https://firestore.googleapis.com/v1/projects/${FIREBASE_PROJECT_ID}/databases/(default)/documents/users`;


function formatToFirestore(fields: Record<string, any>) {
    const formattedFields: Record<string, any> = {};

    for (const key in fields) {
        if (typeof fields[key] === 'string') {
            formattedFields[key] = { stringValue: fields[key] };
        } else if (typeof fields[key] === 'number') {
            formattedFields[key] = { integerValue: fields[key] };
        } else {
            formattedFields[key] = { stringValue: String(fields[key]) };
        }
    }
    return formattedFields;
}

// Firebase Update rquest must use this format ?updateMask.fieldPaths=firstName&updateMask.fieldPaths=lastName
function buildUpdateMask(fields: Record<string, any>) {
    const fieldPaths = Object.keys(fields)
        .map(key => `updateMask.fieldPaths=${encodeURIComponent(key)}`)
        .join('&');
    return fieldPaths;
}

/*
Update user data - REST API version
*/
export async function updateUser(ctx: RouterContext<"/user/:user_id">) {
    try {
        const userId = ctx.params.user_id;
        const body = ctx.request.body();
        const fields = await body.value;
        console.log('Parsed fields:', fields);
        const formattedFields = formatToFirestore(fields); // Convert to Firestore format
        const updateMask = buildUpdateMask(fields); // Build updateMask fieldPaths

        // Build the final endpoint with the updateMask
        const endpoint = `${FireStoreUrl}/${userId}?${updateMask}`;

        // Make the PATCH request
        const response = await fetch(endpoint, {
            method: "PATCH",
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ fields: formattedFields }),
        });

        if (!response.ok) {
            throw new Error(`Firebase request failed: ${response.status}`);
        }

        ctx.response.status = 200;
        ctx.response.body = 'User updated successfully!';
    } catch (e) {
        ctx.response.status = 400;
        ctx.response.body = `Error: ${e}`;
    }
}


/*
Delete user - REST API version
*/
export async function deleteUser(ctx: RouterContext<"/user/:user_id">) {
    try {
        const userId = ctx.params.user_id;
        // Check if the user exists by making a GET request
        const response = await fetch(`${FireStoreUrl}/${userId}`);
        if (!response.ok) {
            // If the user does not exist, Firebase will return a 404 status
            ctx.response.status = 404;
            ctx.response.body = "User not found";
        }

        // Proceed with deleting the user
        const deleteResponse = await fetch(`${FireStoreUrl}/${userId}`, {
            method: 'DELETE',
            headers: {
                'Content-Type': 'application/json',
            },
        });

        if (!deleteResponse.ok) {
            throw new Error(`Delete failed: ${deleteResponse.status}`);
        }

        ctx.response.status = 200;
        ctx.response.body = "User deleted successfully";

    } catch (error) {
        console.error("User delete error:", error);
        ctx.response.status = 400;
        ctx.response.body = "Request error";
    }
}


/*
Use it when log in to bring extra info not contained in firebase auth
*/
export async function getUserDataById(ctx: RouterContext<"/user/:user_id">) {
    try {
        const userId = ctx.params.user_id;
        // Get userData from firestore
        const response = await fetch(`${FireStoreUrl}/${userId}`);
        const result = await response.json();

        if (!response.ok) {
            // If the user does not exist, return a 404 status
            ctx.response.status = 404;
            ctx.response.body = "User not found";
        }
        // Extraer campos limpios
        const fields = result.fields || {};
        const userData = {// Transform to JSON
            userId,
            ...Object.fromEntries(
                Object.entries(fields).map(([key, value]) => [key, Object.values(value as { [key: string]: any })[0]])
            )
        };

        console.log(userData);
        ctx.response.status = 200;
        ctx.response.body = userData;

    } catch (e) {
        ctx.response.status = 500;
        ctx.response.body = `Internal error: ${e}`;
    }

}