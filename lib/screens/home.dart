// Import flutter packages
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Import models
import 'package:notify/model/config.dart';

// Import screens
import 'package:notify/screens/home/uang_kost.dart';
import 'package:notify/screens/home/kalender.dart';
import 'package:notify/screens/home/uang_makan.dart';
import 'package:notify/screens/home/profil.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  int _currIdx = 0;

  final Box<dynamic> _storage = Hive.box("storage");

  late bool _isZero;

  // Class object
  Config _config = Config();

  @override
  void initState() {
    super.initState();

    // Retrieve old config data
    _config = Config.fromJson(_storage.get("config"));

    // Initialize variable
    _isZero = (_config.uangSekaliMakan == 0) ? true : false;
  }

  // Function to re-build widget
  // Only called after changing Uang Sekali Makan data
  void _callback() {
    setState(() {
      _config = Config.fromJson(_storage.get("config"));

      _isZero = (_config.uangSekaliMakan == 0) ? true : false;

      // Update current index
      if (_isZero) {
        _currIdx--;
      } else {
        _currIdx++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<List<Widget>> screens = [
      // Main screens
      [
        const UangMakanPage(),
        const KalenderPage(),
        const UangKostPage(),
        ProfilPage(callback: _callback)
      ],
      // Secondary screens without Uang Makan Page
      [
        const UangKostPage(),
        const KalenderPage(),
        ProfilPage(callback: _callback)
      ]
    ];

    return Scaffold(
        body: screens[(!_isZero) ? 0 : 1][_currIdx],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currIdx,
          type: BottomNavigationBarType.fixed,
          items: [
            if (!_isZero) ...[
              // Uang Makan icon
              const BottomNavigationBarItem(
                icon: Icon(Icons.fastfood),
                label: "Uang Makan",
              )
            ] else ...[
              // Uang Kost icon
              const BottomNavigationBarItem(
                  icon: Icon(Icons.local_hotel_rounded), label: "Uang kost")
            ],
            // Kalender icon
            const BottomNavigationBarItem(
                icon: Icon(Icons.calendar_month), label: "Kalender"),
            if (!_isZero) ...[
              // Uang Kost icon
              const BottomNavigationBarItem(
                  icon: Icon(Icons.local_hotel_rounded), label: "Uang kost")
            ],
            // Profil icon
            const BottomNavigationBarItem(
                icon: Icon(Icons.person), label: "Profil")
          ],
          selectedFontSize: 12,
          unselectedFontSize: 12,
          // On tap listener
          onTap: (int idx) {
            setState(() {
              _currIdx = idx;
            });
          },
        ));
  }
}
