// web/firebase-messaging-sw.js
importScripts('https://www.gstatic.com/firebasejs/9.6.1/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/9.6.1/firebase-messaging-compat.js');

firebase.initializeApp({
    apiKey: "AIzaSyA6sRtCo5NdLn7T2X2ZTTL_Znv4t0DstPQ",
    authDomain: "mypetcare-1ca5a.firebaseapp.com",
    projectId: "mypetcare-1ca5a",
    messagingSenderId: "503119642245",
    appId: "1:503119642245:web:821bffe3fcdc6c4e3173ec"
});

const messaging = firebase.messaging();
