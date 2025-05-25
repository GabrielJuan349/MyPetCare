import 'package:flutter/material.dart';
import 'package:lis_project/FAQs.dart';
import 'package:lis_project/calendar_screen.dart';
import 'package:lis_project/init_screen.dart';
import 'package:lis_project/home_screen.dart';
import 'package:lis_project/profile_screen.dart';
import 'package:lis_project/reminders_screen.dart';
import 'package:lis_project/my_pets_screen.dart';
import 'package:lis_project/inbox.dart';
import 'package:lis_project/register_screen.dart';
import 'package:lis_project/register_form_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:lis_project/services/notification_service.dart';
import 'package:provider/provider.dart';
import 'package:lis_project/data.dart';
import 'firebase_options.dart';
import 'package:lis_project/reset_password_screen.dart';
import 'package:lis_project/news.dart';
import 'package:lis_project/map.dart';
import 'appointment_list_screen.dart';
import 'add_appointment_screen.dart';
// import 'dart:html' as html;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:lis_project/firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lis_project/inbox.dart';
import 'package:lis_project/inbox_message.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
late int numOfPets;
late int numOfInboxMessages;
late String userEmail;
IconData inboxIcon = Icons.inbox;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  /*if(kIsWeb){
    await html.window.navigator.serviceWorker
        ?.register('firebase-messaging-sw.js');
  }*/
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Setup notification functionality
  final notificationService = NotificationService(); // <-- New instance, not singleton
  await notificationService.initialize();
  // Uncomment the following line to run auth in emulator mode:
  // await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
  runApp(
    ChangeNotifierProvider(
      create: (_) => OwnerModel(),
      child: const MyApp(),
    ),

  );
  numOfInboxMessages = myMessages.length;
}

Future<void> startFirestoreListeners(String userId) async {
  List<String> collections = ['treatment', 'prescription', 'appointments', 'report'];

  // Obtener todas las mascotas del usuario
  final petsSnapshot = await FirebaseFirestore.instance
      .collection('pets')
      .where('owner', isEqualTo: userId)
      .get();

  // Si no hay mascotas, no seguimos con los listeners
  if (petsSnapshot.docs.isEmpty) {
    print('El usuario no tiene mascotas registradas.');
    return;
  }

  final userPets = petsSnapshot.docs.map((doc) {
    final data = doc.data();
    return {
      'id': data['id'],
      'name': data['name'],
    };
  }).toList();

  for (var collection in collections) {
    FirebaseFirestore.instance.collection(collection).snapshots().listen(
          (QuerySnapshot snapshot) async {
        for (var change in snapshot.docChanges) {
          final docData = change.doc.data() as Map<String, dynamic>?;

          if (docData == null) continue; // Seguridad si algún doc no tiene datos

          final docId = change.doc.id;

          // Obtener el ID de la mascota según la colección
          String? petId;
          if (collection == 'appointments') {
            petId = docData['petId'];
          } else {
            petId = docData['id_pet'];
          }

          // Si petId es null o vacío, ignoramos ese documento
          if (petId == null || petId.isEmpty) continue;

          // Verificamos si el doc pertenece a alguna mascota del usuario
          final matchingPet = userPets.firstWhere(
                (pet) => pet['id'] == petId,
            orElse: () => {},
          );

          if (matchingPet.isEmpty) continue;

          final petName = matchingPet['name'] ?? 'Mascota desconocida';
          final title = _getTitle(change.type, collection);
          final message = _getMessage(change.type, collection);

          final alreadyExists = await _checkNotificationExists(
            title: title,
            message: message,
            type: collection,
            docId: docId,
          );

          if (!alreadyExists) {
            inboxIcon = Icons.notification_important;
            numOfInboxMessages = myMessages.length;

            // Guardamos en Firebase
            await FirebaseFirestore.instance.collection('inbox').add({
              'title': title,
              'msg': message,
              'type': collection,
              'id': docId,
              'read': false,
              'pet_name': petName,
              'userId': userId,
            });

            scaffoldMessengerKey.currentState?.showSnackBar(
              SnackBar(content: Text('$title: $message')),
            );
          }
        }
      },
    );
  }
}



String _getTitle(DocumentChangeType type, String collection) {
  switch (type) {
    case DocumentChangeType.added:
      return 'Nuevo en $collection';
    case DocumentChangeType.removed:
      return 'Eliminado de $collection';
    case DocumentChangeType.modified:
      return 'Actualización en $collection';
    default:
      return 'Cambio en $collection';
  }
}

String _getMessage(DocumentChangeType type, String collection) {
  switch (type) {
    case DocumentChangeType.added:
      return 'Se ha añadido un nuevo registro';
    case DocumentChangeType.removed:
      return 'Se ha eliminado un registro';
    case DocumentChangeType.modified:
      return 'Se ha actualizado un registro';
    default:
      return 'Se ha modificado algo';
  }
}

Future<bool> _checkNotificationExists({
  required String title,
  required String message,
  required String type,
  required String docId,
}) async {
  final query = await FirebaseFirestore.instance
      .collection('inbox')
      .where('title', isEqualTo: title)
      .where('msg', isEqualTo: message)
      .where('type', isEqualTo: type)
      .where('id', isEqualTo: docId)
      .get();

  return query.docs.isNotEmpty;
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
        '/home': (context) => const HomeScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/reminders': (context) => const RemindersScreen(),
        '/pets': (context) => const MyPetsScreen(),
        '/inbox': (context) => Inbox(),
        '/register': (context) => const RegisterScreen(),
        '/formRegister': (context) => const RegisterFormScreen(),
        '/resetPassword': (context) => const ResetPasswordScreen(),
        '/news': (context) => const NewsScreen(),
        '/map' : (context) => MapScreen(),
        '/help' : (context) => FAQScreen(),
        '/appointmentList': (context) => const AppointmentListScreen(),
      },
    );
  }
}
