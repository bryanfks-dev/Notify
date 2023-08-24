import 'package:collection/collection.dart';

// Import flutter packages
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

// Import models
import 'package:notify/model/config.dart';
import 'package:notify/model/uang_makan_attr.dart';
import 'package:notify/model/calendar_event.dart';

// Import screens
import 'package:notify/screens/errors/service_stopped.dart';

// Import widgets
import 'package:notify/screens/home/widgets/data_field.dart';

// Import services
import 'package:notify/services/notification.dart';

class UangMakanPage extends StatefulWidget {
  const UangMakanPage({Key? key}) : super(key: key);

  @override
  State<UangMakanPage> createState() => _UangMakanPage();
}

class _UangMakanPage extends State<UangMakanPage> {
  final Box<dynamic> _storage = Hive.box("storage");

  // Variable to convert integer into rupiah format
  final NumberFormat _toIdCurrency =
      NumberFormat.currency(locale: "id_ID", symbol: "");

  // Class objects
  Config _config = Config();

  final Map<String, List<dynamic>> _events = {};

  UangMakanAttr _uangMakanAttr = UangMakanAttr();

  // Variables for data field
  int _makanHariIni = 0;
  int _makanMingguIni = 0;
  String _jatuhTempo = '';
  int _sisaWaktu = 0;

  void makanHariIni() {
    dynamic today = DateTime.now();

    today = DateFormat('yyyy-MM-dd')
        .format(DateTime(today.year, today.month, today.day));

    if (_events[today] != null) {
      // Search for an object
      dynamic selectedObj = _events[today]!
          .firstWhereOrNull((event) => event.title == 'Makan di kost');

      if (selectedObj != null) {
        setState(() {
          _makanHariIni = int.parse(selectedObj.subtitle);
        });
      }
    }
  }

  void makanMingguIni() {
    DateTime minDay = DateFormat('yyyy-MM-dd').parse(_uangMakanAttr.jatuhTempo);

    minDay = (DateTime(minDay.year, minDay.month, minDay.day - 6));

    for (int day = 1; day <= 7; day++) {
      if (_events[DateFormat('yyyy-MM-dd').format(minDay)] != null) {
        final List? currDayEvent =
            _events[DateFormat('yyyy-MM-dd').format(minDay)];

        // Search for an object
        dynamic selectedObj = currDayEvent!
            .firstWhereOrNull((event) => event.title == 'Makan di kost');

        if (selectedObj != null) {
          setState(() {
            _makanMingguIni += int.parse(selectedObj.subtitle);
          });
        }
      }

      minDay = DateTime(minDay.year, minDay.month, minDay.day + 1);
    }
  }

  void jatuhTempo() {
    final List<String> splitedDate = _uangMakanAttr.jatuhTempo.split("-");

    // This list variable contains months in indonesian lang
    final List<String> months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "Mei",
      "Jun",
      "Jul",
      "Agu",
      "Sep",
      "Okt",
      "Nov",
      "Des"
    ];

    setState(() {
      _jatuhTempo = "${splitedDate[2]} ${months[int.parse(splitedDate[1]) - 1]}";
    });
  }

  void sisaWaktu() {
    // Convert string into datetime object
    DateTime jatuhTempo =
        DateFormat('yyyy-MM-dd').parse(_uangMakanAttr.jatuhTempo);
    DateTime today = DateTime.now();

    // Reformat today
    today = DateTime(today.year, today.month, today.day);

    setState(() {
      _sisaWaktu = (jatuhTempo.difference(today).inHours / 24).round();
    });
  }

  @override
  void initState() {
    super.initState();

    // Retrieve old config and uang makan attr data
    _config = Config.fromJson(_storage.get("config"));

    _uangMakanAttr = UangMakanAttr.fromJson(_storage.get("uang_makan_attr"));

    jatuhTempo();
    sisaWaktu();

    dynamic events = _storage.get("calendar_events");

    if (events != null) {
      events.forEach((dynamic key, dynamic value) {
        List<CalendarEvent> newValues = [];

        // Convert event json into class object
        for (var item in value) {
          newValues.add(CalendarEvent.fromJson(item));
        }

        _events[key] = newValues;
      });
    }

    makanHariIni();
    makanMingguIni();

    // Update jatuh tempo
    if ((_uangMakanAttr.status && _sisaWaktu <= 0) ||
        (_sisaWaktu <= 0 && _makanMingguIni == 0)) {
      DateTime date = DateFormat("yyyy-MM-dd").parse(_uangMakanAttr.jatuhTempo);

      date = DateTime(date.year, date.month, date.day + (7 - date.weekday));

      _uangMakanAttr.jatuhTempo = DateFormat("yyyy-MM-dd").format(date);

      _uangMakanAttr.status = false;

      // Save updated uang makan attr into storage
      _storage.put("uang_makan_attr", _uangMakanAttr.toJson());

      jatuhTempo();
      sisaWaktu();

      setState(() {
        _makanHariIni = 0;
        _makanMingguIni = 0;
      });

      // Cancel old notification
      NotificationService().cancelNotifications(id: 2);

      // Create new notification
      NotificationService().scheduleNotification(
          id: 2,
          title: "Jangan lupa untuk bayar uang makanmu!",
          body: "Bayar uang makanmu sekarang!",
          scheduledNotificationDateTime:
              DateTime(date.year, date.month, date.day, 14, 0, 0));
    }
  }

  @override
  Widget build(BuildContext context) {
    return (!_config.layananAplikasi)
        ? const ServiceStoppedPage()
        : SafeArea(
            child: Stack(children: [
            Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Title(
                          color: Colors.black,
                          child: Text("Uang Makan ${_config.nama}",
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 24))),
                      SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(vertical: 30),
                          child: Column(children: <Widget>[
                            // Fee
                            Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 20, horizontal: 30),
                                decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(35)),
                                    boxShadow: [
                                      BoxShadow(
                                          offset: const Offset(4, 4),
                                          color: Colors.black.withOpacity(.2))
                                    ]),
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Title(
                                          color: Colors.white,
                                          child: const Text("Biaya",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 21))),
                                      const SizedBox(height: 15),
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text("Rp. ",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 19)),
                                            Text(
                                                "${_toIdCurrency.format(_config.uangSekaliMakan)}/makan",
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 19))
                                          ])
                                    ])),
                            const SizedBox(height: 20),
                            DataField(
                                title: "Statistik",
                                widgets: <Widget>[
                                  Data(
                                      left: "Makan dikost hari ini",
                                      right: Text("$_makanHariIni",
                                          style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold))),
                                  Data(
                                      left: "Makan dikost minggu ini",
                                      right: Text("$_makanMingguIni",
                                          style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold))),
                                ],
                                needFooter: false),
                            const SizedBox(height: 10),
                            DataField(
                                title: "Pembayaran",
                                widgets: <Widget>[
                                  Data(
                                      left: "Total biaya",
                                      right: Text(
                                          "Rp. ${_toIdCurrency.format(_makanMingguIni * _config.uangSekaliMakan)}",
                                          style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold))),
                                  Data(
                                      left: "Jatuh tempo",
                                      right: Text(_jatuhTempo,
                                          style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold))),
                                  Data(
                                      left: "Sisa waktu",
                                      right: Text("$_sisaWaktu hari",
                                          style: TextStyle(
                                              fontSize: 15,
                                              color: (_sisaWaktu < 2)
                                                  ? Colors.red
                                                  : (_sisaWaktu < 3)
                                                      ? Colors.orange
                                                      : Colors.green,
                                              fontWeight: FontWeight.bold))),
                                  Data(
                                      left: "Status",
                                      right: Text(
                                          (_uangMakanAttr.status)
                                              ? "Sudah dibayar"
                                              : "Belum dibayar",
                                          style: TextStyle(
                                              fontSize: 15,
                                              color: (_uangMakanAttr.status)
                                                  ? Colors.green
                                                  : Colors.red,
                                              fontWeight: FontWeight.bold)))
                                ],
                                needFooter: true)
                          ]))
                    ])),
            Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: SpeedDial(
                        spacing: 10,
                        animatedIcon: AnimatedIcons.menu_close,
                        overlayOpacity: 0,
                        children: [
                          // Matikan layanan / aktifkan layanan
                          SpeedDialChild(
                              child: Icon(
                                  (_uangMakanAttr.isActive)
                                      ? Icons.notifications_off
                                      : Icons.notifications_on,
                                  color: Colors.white),
                              label: (_uangMakanAttr.isActive)
                                  ? 'Matikan layanan'
                                  : 'Nyalakan layanan',
                              backgroundColor: (_uangMakanAttr.isActive)
                                  ? Colors.red
                                  : Colors.green,
                              onTap: () {
                                setState(() {
                                  _uangMakanAttr.isActive =
                                      !_uangMakanAttr.isActive;

                                  // Save updated uang makan attribute into storage
                                  _storage.put("uang_makan_attr",
                                      _uangMakanAttr.toJson());
                                });

                                if (_uangMakanAttr.isActive) {
                                  DateTime date = DateFormat("yyyy-MM-dd")
                                      .parse(_uangMakanAttr.jatuhTempo);

                                  date = DateTime(date.year, date.month,
                                      date.day + (7 - date.weekday));

                                  NotificationService().scheduleNotification(
                                      id: 2,
                                      title:
                                          "Jangan lupa untuk bayar uang makanmu!",
                                      body: "Bayar uang makanmu sekarang!",
                                      scheduledNotificationDateTime: DateTime(
                                          date.year,
                                          date.month,
                                          date.day,
                                          14,
                                          0,
                                          0));
                                } else {
                                  NotificationService()
                                      .cancelNotifications(id: 2);
                                }
                              }),
                          // Tambah makan di kost
                          SpeedDialChild(
                              visible: !_uangMakanAttr.status,
                              child: const Icon(Icons.food_bank,
                                  color: Colors.white),
                              label: 'Tambah makan di kost',
                              backgroundColor: Colors.red,
                              onTap: () {
                                dynamic today = DateTime.now();

                                // Re-format today date
                                today = DateFormat('yyyy-MM-dd').format(
                                    DateTime(
                                        today.year, today.month, today.day));

                                setState(() {
                                  // To add this feature, there 2 main cases
                                  // and 2 sub cases
                                  // For the first main case, if current date haven't made
                                  // and for second main case, if current date have been made
                                  // For first subcase, data already made, but there's no same feature in list
                                  // and the second subcase, data already made, but there is same feafure in list

                                  dynamic oldEvents =
                                      _storage.get("calendar_events") ?? {};

                                  // Check if date haven't made
                                  if (_events[today] == null) {
                                    // Create new calendar event
                                    _events[today] = [
                                      CalendarEvent(
                                          title: "Makan di kost", subtitle: "1")
                                    ];

                                    oldEvents[today] = [
                                      CalendarEvent(
                                              title: "Makan di kost",
                                              subtitle: "1")
                                          .toJson()
                                    ];
                                  } else {
                                    dynamic selectedObj = _events[today]!
                                        .firstWhereOrNull((event) =>
                                            event.title == 'Makan di kost');

                                    if (selectedObj == null) {
                                      _events[today]!.add(CalendarEvent(
                                          title: "Makan di kost",
                                          subtitle: "1"));

                                      dynamic oldEvents =
                                          _storage.get("calendar_events");

                                      oldEvents[today].add(CalendarEvent(
                                              title: "Makan di kost",
                                              subtitle: "1")
                                          .toJson());
                                    } else {
                                      selectedObj.subtitle =
                                          "${int.parse(selectedObj.subtitle) + 1}";

                                      Map<dynamic, dynamic> selectedJson =
                                          oldEvents[today]!.firstWhere(
                                              (event) =>
                                                  event["title"] ==
                                                  'Makan di kost');

                                      selectedJson["subtitle"] =
                                          "${int.parse(selectedJson['subtitle']) + 1}";
                                    }
                                  }

                                  _makanHariIni++;
                                  _makanMingguIni++;

                                  // Save updated calendar events into storage
                                  _storage.put("calendar_events", oldEvents);
                                });
                              }),
                          // Tandai sudah bayar
                          SpeedDialChild(
                              visible: !_uangMakanAttr.status &&
                                  _makanMingguIni != 0,
                              child:
                                  const Icon(Icons.done, color: Colors.white),
                              label: 'Tandai sudah bayar',
                              backgroundColor: Colors.green,
                              onTap: () {
                                setState(() {
                                  _uangMakanAttr.status = true;

                                  // Save updated uang makan attribute into storage
                                  _storage.put("uang_makan_attr",
                                      _uangMakanAttr.toJson());

                                  // Add new event into calender event
                                  CalendarEvent newEvent = CalendarEvent(
                                      title: "Bayar uang makan",
                                      subtitle:
                                          "Rp. ${_toIdCurrency.format(_makanMingguIni * _config.uangSekaliMakan)}");

                                  // Retrieve old calendar event data
                                  dynamic oldEvents =
                                      _storage.get("calendar_events") ?? {};

                                  final DateTime today = DateTime.now();

                                  // Check if current date haven't made in event
                                  if (oldEvents[DateFormat("yyyy-MM-dd")
                                          .format(today)] ==
                                      null) {
                                    oldEvents[DateFormat("yyyy-MM-dd")
                                        .format(today)] = [newEvent.toJson()];

                                    _events[DateFormat("yyyy-MM-dd")
                                        .format(today)] = [newEvent];
                                  } else {
                                    oldEvents[DateFormat("yyyy-MM-dd")
                                            .format(today)]
                                        .add(newEvent.toJson());

                                    _events[DateFormat("yyyy-MM-dd")
                                            .format(today)]!
                                        .add(newEvent);
                                  }

                                  // Save updated calendar event into storage
                                  _storage.put("calendar_events", oldEvents);
                                });
                              })
                        ])))
          ]));
  }
}
