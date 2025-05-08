import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lis_project/init_screen.dart';
import 'package:lis_project/home_screen.dart';
import 'package:lis_project/profile_screen.dart';
import 'package:lis_project/reminders_screen.dart';
import 'package:lis_project/my_pets_screen.dart';
import 'package:lis_project/inbox.dart';
import 'package:lis_project/register_screen.dart';
import 'package:lis_project/register_form_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Uncomment the following line to run auth in emulator mode:
  await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    runApp(const MyApp());

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/init',
      routes: {
        '/init': (context) => const InitScreen(),
        '/home': (context) => const HomeScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/reminders': (context) => const RemindersScreen(),
        '/pets': (context)=> const MyPetsScreen(),
        '/inbox': (context)=> const Inbox(),
        '/register': (context) => const RegisterScreen(),
        '/formRegister': (context) => const RegisterFormScreen(),
      },
    );
  }
}
