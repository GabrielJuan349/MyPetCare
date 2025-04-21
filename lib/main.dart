import 'package:flutter/material.dart';
import 'package:lis_project/init_screen.dart';
import 'package:lis_project/home_screen.dart';
import 'package:lis_project/profile_screen.dart';
import 'package:lis_project/reminders_screen.dart';
import 'package:lis_project/my_pets_screen.dart';
import 'package:lis_project/inbox.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/init',
      routes: {
        '/init': (context) => const InitScreen(),
        '/home': (context) => HomeScreen(),
        '/profile': (context) => ProfileScreen(),
        '/reminders': (context) => const RemindersScreen(),
        '/pets': (context)=> MyPetsScreen(),
        '/inbox': (context)=> Inbox(),
      },
    );
  }
}
