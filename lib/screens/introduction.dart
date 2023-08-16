// Import flutter packages
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

// Import screens
import 'package:notify/screens/home.dart';
import 'package:introduction_screen/introduction_screen.dart';

// Import services
import 'package:notify/services/notification.dart';

// Input field widget
class InputField extends StatefulWidget {
  final TextEditingController controller;
  final Map<String, dynamic> saveObject;
  final bool isNumeric;
  final int maxLength;
  final Icon? prefixIcon;
  final String? prefixText;
  final String labelText;

  const InputField(
      {super.key,
      required this.controller,
      required this.saveObject,
      required this.isNumeric,
      required this.maxLength,
      this.prefixIcon,
      this.prefixText,
      required this.labelText});

  @override
  State<InputField> createState() => _InputField();
}

class _InputField extends State<InputField> {
  bool _showError = false;

  // Function to return various error message
  String? _errorText() {
    dynamic text = widget.controller.value.text;

    if (text.isEmpty && widget.labelText != 'Uang Sekali Makan') {
      return "${widget.labelText} mu harus diisi";
    }

    if (widget.isNumeric && text.isNotEmpty) {
      text = int.parse(text);

      // If is Uang Kost/Bln field
      if (widget.labelText == "Uang Kost/Bln" && text < 50000) {
        return "${widget.labelText} minimum Rp. 50.000,00";
      }
      // If is Bayar Uang Kost/Tgl field
      else if (widget.labelText == "Bayar Uang Kost/Tgl" &&
          (text < 1 || text > 28)) {
        return "Tanggal yang tersedia 1-28";
      }
      // If is Uang Sekali Makan
      else if (widget.labelText == "Uang Sekali Makan" && text < 10000) {
        return "${widget.labelText} minimum Rp. 10.000,00";
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) => ValueListenableBuilder(
      valueListenable: widget.controller,
      builder: (context, TextEditingValue value, _) => TextField(
            controller: widget.controller,
            keyboardType:
                (widget.isNumeric) ? TextInputType.number : TextInputType.name,
            maxLength: widget.maxLength,
            inputFormatters: [
              if (widget.isNumeric) FilteringTextInputFormatter.digitsOnly
            ],
            decoration: InputDecoration(
                prefixIcon:
                    (widget.prefixIcon != null) ? widget.prefixIcon : null,
                prefixText:
                    (widget.prefixText != null) ? widget.prefixText : null,
                prefixIconColor: Colors.grey,
                suffixIcon:
                    (_errorText() == null) ? const Icon(Icons.done) : null,
                suffixIconColor: Colors.green,
                counterText: '',
                labelText: widget.labelText,
                helperText: (widget.labelText == "Uang Sekali Makan")
                    ? "Kosongkan jika tidak ada"
                    : null,
                border: const OutlineInputBorder(),
                errorText: _showError ? _errorText() : null),
            onChanged: (value) {
              _showError = true;

              if (value.isNotEmpty) {
                // Save input into json object
                widget.saveObject[
                        widget.labelText.toLowerCase().replaceAll(' ', '_')] =
                    (widget.isNumeric) ? int.parse(value) : value;
              }
            },
          ));
}

class IntroductionPage extends StatefulWidget {
  const IntroductionPage({Key? key}) : super(key: key);

  @override
  State<IntroductionPage> createState() => _IntroductionPage();
}

class _IntroductionPage extends State<IntroductionPage> {
  // Text editing controllers
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _uangKostController = TextEditingController();
  final TextEditingController _bayarUangKostController =
      TextEditingController();
  final TextEditingController _uangMakanController = TextEditingController();

  // Map variables
  final Map<String, dynamic> _newConfig = {};
  final Map<String, dynamic> _newUangKostAttr = {};

  @override
  void dispose() {
    super.dispose();

    // Dispose all text editing controller
    _namaController.dispose();
    _uangKostController.dispose();
    _bayarUangKostController.dispose();
    _uangMakanController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const PageDecoration pageDecoration = PageDecoration(
        titleTextStyle: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        bodyTextStyle: TextStyle(fontSize: 19, color: Colors.white),
        bodyPadding: EdgeInsets.all(16));

    return Scaffold(
        backgroundColor: Colors.blue,
        body: SafeArea(
            child: IntroductionScreen(
                globalBackgroundColor: Colors.blue,
                pages: <PageViewModel>[
                  // Page 1: Greetings
                  PageViewModel(
                      title: 'Hallo👋!',
                      image: SvgPicture.asset("assets/hello.svg"),
                      body: 'Selamat datang di Notify!',
                      decoration: pageDecoration),
                  // Page 2: About Notify
                  PageViewModel(
                      title: 'Notify!',
                      image: SvgPicture.asset("assets/notify.svg"),
                      body:
                          'Aku Notify, aplikasi yang akan memberitahu dan mengingatkanmu untuk selalu membayar tagihan kost-mu tepat waktu',
                      decoration: pageDecoration),
                  PageViewModel(
                      title: 'Dann.. Kamu?',
                      bodyWidget: Center(
                          child: Column(children: <Widget>[
                        const SizedBox(height: 35),
                        InputField(
                            controller: _namaController,
                            saveObject: _newConfig,
                            isNumeric: false,
                            maxLength: 10,
                            prefixIcon: const Icon(Icons.person),
                            labelText: "Nama"),
                        const SizedBox(height: 35),
                        InputField(
                            controller: _uangKostController,
                            saveObject: _newConfig,
                            isNumeric: true,
                            maxLength: 100,
                            prefixText: "Rp. ",
                            labelText: "Uang Kost/Bln"),
                        const SizedBox(height: 35),
                        InputField(
                            controller: _bayarUangKostController,
                            saveObject: _newConfig,
                            isNumeric: true,
                            maxLength: 2,
                            prefixIcon: const Icon(Icons.date_range),
                            labelText: "Bayar Uang Kost/Tgl"),
                        const SizedBox(height: 35),
                        InputField(
                            controller: _uangMakanController,
                            saveObject: _newConfig,
                            isNumeric: true,
                            maxLength: 100,
                            prefixText: "Rp. ",
                            labelText: "Uang Sekali Makan")
                      ])),
                      decoration: const PageDecoration(
                          titleTextStyle: TextStyle(
                              color: Colors.blue,
                              fontSize: 32,
                              fontWeight: FontWeight.bold),
                          bodyTextStyle:
                              TextStyle(fontSize: 19, color: Colors.white),
                          bodyPadding: EdgeInsets.all(16),
                          pageColor: Colors.white))
                ],
                showNextButton: true,
                showDoneButton: true,
                showBackButton: true,
                back: const Icon(Icons.arrow_back, color: Colors.white),
                next: const Icon(Icons.arrow_forward, color: Colors.white),
                done: const Text("Selesai",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 16)),
                dotsDecorator: const DotsDecorator(
                    size: Size(10, 10),
                    color: Colors.white,
                    activeSize: Size(22, 10),
                    activeColor: Colors.white,
                    activeShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25)))),
                onDone: () {
                  // Function to decide text controller already valid or not
                  bool isValid(
                      TextEditingController controller, bool isNumeric) {
                    dynamic text = controller.value.text;

                    if (text.isEmpty && controller != _uangMakanController) {
                      return false;
                    }

                    if (isNumeric && text.isNotEmpty) {
                      text = int.parse(text);

                      // If is Uang Kost/Bln field
                      if (controller == _uangKostController && text < 50000) {
                        return false;
                      }
                      // If is Bayar Uang Kost/Tgl field
                      else if (controller == _bayarUangKostController &&
                          (text < 1 || text > 28)) {
                        return false;
                      }
                      // If is Uang Sekali Makan field
                      else if (controller == _uangMakanController &&
                          text < 10000) {
                        return false;
                      }
                    }

                    return true;
                  }

                  // Validate all input
                  if (isValid(_namaController, false) &&
                      isValid(_uangKostController, true) &&
                      isValid(_bayarUangKostController, true) &&
                      isValid(_uangMakanController, true)) {
                    // Validate uang_sekali_makan key
                    if (_newConfig["uang_sekali_makan"] == null) {
                      _newConfig["uang_sekali_makan"] = 0;
                    }

                    // Set application service on
                    _newConfig["layanan_aplikasi"] = true;

                    // Create Uang Kost Attribute
                    final DateTime today = DateTime.now();

                    _newUangKostAttr["jatuh_tempo"] = DateFormat('yyyy-MM-dd')
                        .format(DateTime(today.year, today.month + 1,
                            _newConfig["bayar_uang_kost/tgl"]));

                    _newUangKostAttr["status"] = false;

                    // Save new config and uang kost attr into storage
                    final storage = Hive.box("storage");

                    storage.put("config", _newConfig);
                    storage.put("uang_kost_attr", _newUangKostAttr);

                    // Create Uang Makan Attribute
                    if (_newConfig["uang_sekali_makan"] != 0) {
                      final Map<String, dynamic> newUangMakanAttr = {};

                      /*
                        To find next sunday date
                        How weekday works:
                        Monday -> 1
                        Tuesday -> 2
                        ...
                        Sunday -> 7

                        For ex. current day Tuesday 15, and next sunday is 20,
                        needs 15 + 5 days to reach next sunday,
                        Therefore, to get 5, we can use 7(total of days in a week) - 2 (from Tuesday weekday)
                      */
                      newUangMakanAttr["jatuh_tempo"] = DateFormat('yyyy-MM-dd')
                          .format(DateTime(today.year, today.month,
                              today.day + (7 - today.weekday)));

                      newUangMakanAttr["status"] = false;

                      newUangMakanAttr["is_active"] = true;

                      // Save new uang makan attr into storage
                      storage.put("uang_makan_attr", newUangMakanAttr);

                      // Notification for uang makan
                      NotificationService().scheduleNotification(
                          id: 2,
                          title: "Jangan lupa untuk bayar uang makanmu!",
                          body: "Bayar uang makanmu sekarang!",
                          scheduledNotificationDateTime: DateTime(
                              today.year,
                              today.month,
                              today.day + (7 - today.weekday),
                              14,
                              0,
                              0));
                    }

                    DateTime due = DateTime(today.year, today.month + 1,
                            _newConfig["bayar_uang_kost/tgl"]);

                    // Create notification
                    // Notification for uang kost
                    NotificationService().scheduleNotification(
                        id: 1,
                        title: "Jangan lupa untuk bayar uang kostmu!",
                        body:
                            "Bayar uang kostmu Rp. ${NumberFormat.currency(locale: 'id_ID', symbol: '').format(_newConfig['uang_kost/bln'])} sekarang!",
                        scheduledNotificationDateTime: DateTime(
                            due.year, due.month, due.day - 2, 14, 0, 0));

                    // Go to homepage
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (builder) {
                      return const HomePage();
                    }));
                  }
                })));
  }
}
