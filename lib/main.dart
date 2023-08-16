// Import flutter packages
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timezone/data/latest.dart' as tz;

// Import screens
import 'package:notify/screens/home.dart';
import 'package:notify/screens/introduction.dart';

// Import services
import 'package:notify/services/notification.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize hive
  await Hive.initFlutter();

  // Open storage
  await Hive.openBox("storage");

  // Initialize notification
  NotificationService().initNotification();

  // Initialize timezone
  tz.initializeTimeZones();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyApp();
}

class _MyApp extends State<MyApp> {
  int _currIdx = 0;

  final List<Widget> _startingScreen = [
    const IntroductionPage(),
    const HomePage()
  ];

  @override
  void initState() {
    super.initState();

    final storage = Hive.box("storage");

    /* storage.deleteAll(
        ["config", "uang_makan_attr", "uang_kost_attr", "calendar_events"]); */

    // Redirect user to homepage if old config found
    if (storage.get("config") != null) _currIdx = 1;

    // Manage notification
    // Uang kost
    dynamic uangKostAttr = storage.get("uang_kost_attr");

    if (uangKostAttr != null && uangKostAttr["status"]) {
      NotificationService().cancelNotifications(id: 1);
    }

    // Uang makan
    dynamic uangMakanAttr = storage.get("uang_makan_attr");

    if (uangMakanAttr != null && (uangMakanAttr["status"] || !uangMakanAttr["is_active"])) {
      NotificationService().cancelNotifications(id: 2);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "Notify",
        debugShowCheckedModeBanner: false,
        home: _startingScreen[_currIdx]);
  }
}
