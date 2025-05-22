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
import 'package:lis_project/pet_test.dart';
import 'package:lis_project/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
late int numOfPets;
late int numOfInboxMessages;
late String userEmail;
IconData inboxIcon = Icons.inbox;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());

  numOfPets = pets.length;
  numOfInboxMessages = myMessages.length;
  //startSnackBarTimer();
  startFirestoreListeners();
}

void startFirestoreListeners() {
  List<String> collections = ['treatment', 'prescription', 'appointments', 'report'];
  //List<String> collections = ['inbox_test'];

  for (var collection in collections) {
    FirebaseFirestore.instance.collection(collection).snapshots().listen(
          (QuerySnapshot snapshot) async {
        for (var change in snapshot.docChanges) {
          final id = change.doc.id;

          if (change.type == DocumentChangeType.added) {
            /*
            await FirebaseFirestore.instance.collection('inbox').add({
              'title': 'Nuevo en $collection',
              'msg': 'Se ha añadido un nuevo registro',
              'type': '$collection',
              'id': '$id',
              'read': false,
            });*/

            myMessages.insert(
              0,
              InboxMessage(
                'Nuevo en $collection',
                'Se ha añadido un nuevo registro',
                '$collection',
                "$id",
                false,
              ),
            );
            inboxIcon = Icons.notification_important;
          } else if (change.type == DocumentChangeType.removed) {
            /*
            await FirebaseFirestore.instance.collection('inbox').add({
              'title': 'Eliminado de $collection',
              'msg': 'Se ha eliminado un registro',
              'type': '$collection',
              'id': '$id',
              'read': false,
            });*/

            myMessages.insert(
              0,
              InboxMessage(
                'Eliminado de $collection',
                'Se ha eliminado un registro',
                '$collection',
                "$id",
                false,
              ),
            );
            inboxIcon = Icons.notification_important;
          }

          numOfInboxMessages = myMessages.length;
        }
      },
    );
  }
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
