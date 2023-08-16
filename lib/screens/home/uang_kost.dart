// Import flutter packages
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

// Import models
import 'package:notify/model/config.dart';
import 'package:notify/model/uang_kost_attr.dart';
import 'package:notify/model/calendar_event.dart';

// Import screens
import 'package:notify/screens/errors/service_stopped.dart';
import 'package:notify/screens/home/widgets/data_field.dart';

// Import services
import 'package:notify/services/notification.dart';

class UangKostPage extends StatefulWidget {
  const UangKostPage({Key? key}) : super(key: key);

  @override
  State<UangKostPage> createState() => _UangKostPage();
}

class _UangKostPage extends State<UangKostPage> {
  final Box<dynamic> _storage = Hive.box("storage");

  // Variable to convert integer into rupiah format
  final NumberFormat _toIdCurrency =
      NumberFormat.currency(locale: "id_ID", symbol: "");

  // Class objects
  Config _config = Config();

  UangKostAttr _uangKostAttr = UangKostAttr();

  String _jatuhTempo = '';
  int _sisaWaktu = 0;

  void jatuhTempo() {
    final List<String> splitedDate = _uangKostAttr.jatuhTempo.split("-");

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

    _jatuhTempo = "${splitedDate[2]} ${months[int.parse(splitedDate[1])]}";
  }

  void sisaWaktu() {
    setState(() {
      // Convert string into datetime object
      DateTime jatuhTempo =
          DateFormat('yyyy-MM-dd').parse(_uangKostAttr.jatuhTempo);
      DateTime today = DateTime.now();

      // Reformat today
      today = DateTime(today.year, today.month, today.day);

      _sisaWaktu = (jatuhTempo.difference(today).inHours / 24).round();
    });
  }

  @override
  void initState() {
    super.initState();

    // Retrieve old config and uang kost attr data
    _config = Config.fromJson(_storage.get("config"));

    _uangKostAttr = UangKostAttr.fromJson(_storage.get("uang_kost_attr"));

    jatuhTempo();
    sisaWaktu();

    // Update jatuh tempo
    if (_uangKostAttr.status && _sisaWaktu <= 0) {
      DateTime date = DateFormat("yyyy-MM-dd").parse(_uangKostAttr.jatuhTempo);

      date = DateTime(date.year, date.month + 1, date.day);

      _uangKostAttr.jatuhTempo = DateFormat("yyyy-MM-dd").format(date);

      _uangKostAttr.status = false;

      // Save updated uang kost attr into storage
      _storage.put("uang_kost_attr", _uangKostAttr.toJson());

      jatuhTempo();
      sisaWaktu();

      // Cancle old notification
      NotificationService().cancelNotifications(id: 1);

      // Create new notification
      NotificationService().scheduleNotification(
          id: 1,
          title: "Jangan lupa untuk bayar uang kostmu!",
          body:
              "Bayar uang kostmu Rp. ${_toIdCurrency.format(_config.uangKostPerBulan)} sekarang!",
          scheduledNotificationDateTime:
              DateTime(date.year, date.month, date.day - 2, 14, 0, 0));
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
                        child: Text("Uang Kost ${_config.nama}",
                            style: const TextStyle(
                                color: Colors.black, fontSize: 24))),
                    SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(vertical: 30),
                      child: Column(
                        children: <Widget>[
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                            "${_toIdCurrency.format(_config.uangKostPerBulan)}/bln",
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 19))
                                      ],
                                    )
                                  ])),
                          const SizedBox(height: 20),
                          DataField(
                              title: "Pembayaran",
                              widgets: [
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
                                            color: (_sisaWaktu < 3)
                                                ? Colors.red
                                                : (_sisaWaktu < 6)
                                                    ? Colors.orange
                                                    : Colors.green,
                                            fontWeight: FontWeight.bold))),
                                Data(
                                    left: "Status",
                                    right: Text(
                                        (_uangKostAttr.status)
                                            ? "Sudah dibayar"
                                            : "Belum dibayar",
                                        style: TextStyle(
                                            fontSize: 15,
                                            color: (_uangKostAttr.status)
                                                ? Colors.green
                                                : Colors.red,
                                            fontWeight: FontWeight.bold))),
                              ],
                              needFooter: true)
                        ],
                      ),
                    )
                  ],
                )),
            (_uangKostAttr.status)
                ? const SizedBox.shrink()
                : Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: FloatingActionButton.extended(
                          onPressed: () {
                            setState(() {
                              // Update status
                              _uangKostAttr.status = true;

                              // Save updated uang kost attr into storage
                              _storage.put(
                                  "uang_kost_attr", _uangKostAttr.toJson());
                            });

                            // Add new event into calender event
                            CalendarEvent newEvent = CalendarEvent(
                                title: "Bayar uang kost",
                                subtitle:
                                    "Rp. ${_toIdCurrency.format(_config.uangKostPerBulan)}");

                            // Retrieve old calendar event data
                            dynamic oldEvents =
                                _storage.get("calendar_events") ?? {};

                            final DateTime today = DateTime.now();

                            // Check if current date haven't made in event
                            if (oldEvents[DateFormat("yyyy-MM-dd")
                                    .format(DateTime.now())] ==
                                null) {
                              oldEvents[DateFormat("yyyy-MM-dd")
                                  .format(today)] = [newEvent.toJson()];
                            } else {
                              oldEvents[DateFormat("yyyy-MM-dd").format(today)]
                                  .add(newEvent.toJson());
                            }

                            // Save updated calendar event into storage
                            _storage.put("calendar_events", oldEvents);
                          },
                          icon: const Icon(Icons.done),
                          label: const Text("Tandai sudah bayar"),
                          backgroundColor: Colors.green),
                    ))
          ]));
  }
}
