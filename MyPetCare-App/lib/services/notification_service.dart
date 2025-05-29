//https://www.youtube.com/watch?v=CCrBHh8TcIE
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../firebase_options.dart';

// Remain notification persistent in background
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async{
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final service = NotificationService();
  await service.setUpFlutterNotifications();
  await service.showNotification(message);
}

class NotificationService {
  NotificationService();

  FirebaseMessaging? _messaging;
  final _localNotifications = FlutterLocalNotificationsPlugin();
  bool _isFlutterNotificationInitialized = false;

  Future<void> initialize() async {
    _messaging = FirebaseMessaging.instance;
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Request permission
    await _requestPermission();

    // Setup message handlers
    await _setUpMessageHandlers();

    // Get FCM token from each device to be able to send messages
    final token = await _messaging?.getToken();

    // Debug
    print('FCM Token: $token');

  }

  Future<void> _requestPermission() async {
    final settings = await _messaging?.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
    );
    // Debug
    print('Permission status: ${settings?.authorizationStatus}');
  }

  Future<void> setUpFlutterNotifications() async {
    if (_isFlutterNotificationInitialized) {
      return;
    }

    // Android setup => we'll only gonna use android
    const channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    const initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/logo');

    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {},
    );

    // Singleton logic, just need to initialize once.
    _isFlutterNotificationInitialized = true;
  }

  Future<void> showNotification(RemoteMessage message) async {
    // If you have more data use: message.data.notification
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    if (notification != null && android != null) {
      await _localNotifications.show(
          notification.hashCode,
          notification.title,
          notification.body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'high_importance_channel',
              'High Importance Notifications',
              channelDescription: 'This channel is used for important notifications.',
              importance: Importance.high,
              priority: Priority.high,
              icon: '@mipmap/logo',
            ),
          ),
          payload: message.data.toString()
      );
    }
  }

  Future<void> _setUpMessageHandlers() async{
    //foreground message
    FirebaseMessaging.onMessage.listen((message){
      showNotification(message);

    });

    // Settings for background messages
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

    // opened app
    final initialMessage = await _messaging?.getInitialMessage();
    if(initialMessage!=null){
      _handleBackgroundMessage(initialMessage);
    }
  }

  void _handleBackgroundMessage(RemoteMessage message){
    /*
      if(message.data['type'] == 'report'){
        // open report screen of the indicated pet
      }
     */

  }

}
