

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';

Future<void> main() async {

  Workmanager().initialize(
    callbackDispatcher,
  );
  // Registering a periodic task
  Workmanager().registerOneOffTask(
    "periodicTaskId", // Unique ID for the periodic task
    "PeriodicTask", // Task name
    initialDelay: const Duration(seconds: 30),
    constraints: Constraints(networkType: NetworkType.connected)
    // equency of the task
  );

  runApp(MyApp());
}

@pragma('vm:entry-point') // Mandatory if the App is obfuscated or using Flutter 3.1+
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    FlutterLocalNotificationsPlugin flip = FlutterLocalNotificationsPlugin();

    var android = const AndroidInitializationSettings('@mipmap/ic_launcher');
    var iOS = const DarwinInitializationSettings(); // Add iOS initialization

    var settings = InitializationSettings(android: android, iOS: iOS);



    await flip.initialize(settings);

    // Ensure channel is created only once
    await _createNotificationChannel(flip);

    _showNotificationWithDefaultSound(flip, task); // Pass task name to the notification
    return Future.value(true);
  });
}

Future<void> _createNotificationChannel(FlutterLocalNotificationsPlugin flip) async {
  const channel = AndroidNotificationChannel(
    'geeks_channel_id', // Use a fixed ID
    'Geeks Notification Channel', // Use a fixed name
    description: 'This is a unique notification channel.',
    importance: Importance.max,
  );

  // Create the channel
  await flip.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
}

Future<void> _showNotificationWithDefaultSound(FlutterLocalNotificationsPlugin flip, String task) async {
  var platformChannelSpecifics = const NotificationDetails(
    android: AndroidNotificationDetails(
      'geeks_channel_id', // Use the same fixed ID
      'Geeks Notification Channel',
      channelDescription: 'This is a unique notification channel.',
      importance: Importance.max,
      priority: Priority.high,
    ),
    iOS: DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    ),
  );

  await flip.show(
    0,
    'GeeksforGeeks',
    'Task: $task - You are one step away to connect with GeeksforGeeks', // Include task name in the notification
    platformChannelSpecifics,
    payload: 'Default_Sound',
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Geeks Demo',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: HomePage(title: "GeeksforGeeks"),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(),
    );
  }
}
