import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

import 'login.dart';
import 'home.dart';
import 'clinic_register.dart';
String? globalClinicId;
String? globalVetName;
String? globalVetId;
String? globalClinicInfo;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyPetCareApp());
}

class MyPetCareApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyPetCare',
      debugShowCheckedModeBanner: false,
      routes: {
        '/login': (context) => const Login(),
        '/clinic-register': (context) => const ClinicRegisterScreen(),
      },
      home: AuthLogic(),
    );
  }
}

class AuthLogic extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
        stream: _auth.authStateChanges(),
        builder: (BuildContext ctx, snapshot) {
          if (snapshot.hasData) {
            final user = snapshot.data!;
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .get(),
              builder: (context, docSnapshot) {
                if (docSnapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                if (docSnapshot.hasData && docSnapshot.data!.exists) {
                  final data = docSnapshot.data!.data() as Map<String, dynamic>;
                  globalClinicInfo = data['clinicInfo'];
                  return const HomePage();
                } else {
                  return const Text('No clinic info found');
                }
              },
            );
          }
          return const Login();
        });
  }
}
