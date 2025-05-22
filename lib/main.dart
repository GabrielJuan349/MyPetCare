import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

import 'login.dart';
import 'home.dart';
import 'clinic_register.dart';

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

class AuthLogic extends StatelessWidget{
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _auth.authStateChanges(),
      builder: (BuildContext ctx, snapshot) {
        if (snapshot.hasData) {
          return const HomePage();
        }
        return const Login();
      }
    );
  }
}