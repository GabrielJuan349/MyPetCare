import 'package:flutter/material.dart';
import 'package:lis_project/init_screen.dart';
import 'package:lis_project/home_screen.dart';
import 'package:lis_project/profile_screen.dart';
import 'package:lis_project/reminders_screen.dart';
import 'package:lis_project/my_pets_screen.dart';
import 'package:lis_project/inbox.dart';
import 'package:lis_project/inbox_message.dart';
import 'package:lis_project/map.dart';
import 'package:lis_project/FAQs.dart';
import 'dart:async';
import 'package:lis_project/pet.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
late int numOfPets;
late int numOfInboxMessages;
IconData inboxIcon = Icons.inbox;

void main() {
  runApp(const MyApp());
  numOfPets = pets.length;
  numOfInboxMessages = myMessages.length;
  startSnackBarTimer();
}

void startSnackBarTimer() {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    scaffoldMessengerKey.currentState?.showSnackBar(
      const SnackBar(
        content: Text('Este es un mensaje de ejemplo.'),
        duration: Duration(seconds: 4),
      ),
    );
  });

  Timer.periodic(const Duration(seconds: 20), (timer) {
    if (pets.length > numOfPets) {
      int numOfNewPets = pets.length - numOfPets;
      numOfPets = pets.length;
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text('You have added $numOfNewPets new pets'),
          duration: Duration(seconds: 4),
        ),
      );
    } else if (pets.length < numOfPets) {
      int numOfLostPets = numOfPets - pets.length;
      numOfPets = pets.length;
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text('You have deleted $numOfLostPets pets'),
          duration: Duration(seconds: 4),
        ),
      );
    }

    if (myMessages.length > numOfInboxMessages) {
      inboxIcon = Icons.notification_important;
    }
  });
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
        '/pets': (context)=> MyPetsScreen(myPets: pets),
        '/inbox': (context)=> Inbox(),
        '/map': (context)=> MapScreen(),
        '/help': (context)=> FAQScreen(),
      },
    );
  }
}
