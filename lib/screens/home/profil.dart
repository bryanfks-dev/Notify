import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

// Import flutter packages
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Import models
import 'package:notify/model/config.dart';

// Data widget
class Data extends StatefulWidget {
  final IconData icon;
  final String content;
  final void Function()? onPressed;

  const Data(
      {super.key,
      required this.icon,
      required this.content,
      required this.onPressed});

  @override
  State<Data> createState() => _Data();
}

class _Data extends State<Data> {
  @override
  Widget build(BuildContext context) =>
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(children: [
          Icon(widget.icon, size: 30),
          const SizedBox(width: 15),
          Text(widget.content, style: const TextStyle(fontSize: 18))
        ]),
        IconButton(onPressed: widget.onPressed, icon: const Icon(Icons.edit))
      ]);
}

// Data field widget
class DataField extends StatefulWidget {
  final String title;
  final List<Widget> widgets;

  const DataField({super.key, required this.title, required this.widgets});

  @override
  State<DataField> createState() => _DataField();
}

class _DataField extends State<DataField> {
  @override
  Widget build(BuildContext context) {
    final listLength = widget.widgets.length;

    return Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.all(Radius.circular(35)),
            boxShadow: [
              BoxShadow(
                  offset: const Offset(4, 4),
                  color: Colors.black.withOpacity(.2))
            ]),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 19)),
              const SizedBox(height: 10),
              // Content
              for (int idx = 0; idx < listLength; idx++) ...[
                widget.widgets[idx],
                if (idx + 1 < listLength)
                  const Divider(color: Colors.black, thickness: 1)
              ]
            ]));
  }
}

class ProfilPage extends StatefulWidget {
  final Function callback;

  const ProfilPage({Key? key, required this.callback}) : super(key: key);

  @override
  State<ProfilPage> createState() => _ProfilPage();
}

class _ProfilPage extends State<ProfilPage> {
  // Text editing controllers
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _uangKostController = TextEditingController();
  final TextEditingController _bayarUangKostController =
      TextEditingController();
  final TextEditingController _uangMakanController = TextEditingController();

  final Box<dynamic> _storage = Hive.box("storage");

  // Class objects
  Config _config = Config();

  // Variable to convert integer into rupiah format
  final NumberFormat _toIdCurrency =
      NumberFormat.currency(locale: "id_ID", symbol: "");

  Future<void> _editData(
      {required TextEditingController controller,
      required oldValue,
      required String field,
      required bool isNumeric,
      required int maxLength}) async {
    String newValue = '';

    // Set current input value as old data value
    controller.text = "$oldValue";

    bool showError = false;

    // Function to show various error messages
    String? errorText() {
      dynamic text = controller.value.text;

      if (text.isEmpty) {
        return "$field harus diisi";
      }

      if (isNumeric && text.isNotEmpty) {
        text = int.parse(text);

        // If is Uang Kost/Bln
        if (controller == _uangKostController && text < 50000) {
          return "$field minimum Rp. 50.000,00";
        }
        // If is Bayar Uang Kost/Tgl
        else if (controller == _bayarUangKostController &&
            (text < 1 || text > 28)) {
          return "Tanggal yang tersedia 1-28";
        }
        // If is Uang Sekali Makan
        else if (controller == _uangMakanController &&
            text != 0 &&
            text < 10000) {
          return "$field minimum Rp. 10.000,00";
        }
      }

      return null;
    }

    await showDialog(
        context: context,
        builder: (context) => AlertDialog(
                title: Text("Edit $field"),
                content: ValueListenableBuilder(
                    valueListenable: controller,
                    builder: (context, TextEditingValue value, _) => TextField(
                        controller: controller,
                        autofocus: true,
                        maxLength: maxLength,
                        inputFormatters: [
                          if (isNumeric) FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration: InputDecoration(
                            prefixText: (isNumeric &&
                                    controller != _bayarUangKostController)
                                ? "Rp. "
                                : null,
                            counterText: '',
                            helperText: (controller == _uangMakanController)
                                ? "Ketik 0 jika tidak ada"
                                : null,
                            errorText: showError ? errorText() : null),
                        onChanged: (value) {
                          showError = true;

                          if (value.isNotEmpty) newValue = value;
                        })),
                actions: <Widget>[
                  // Cancel button
                  TextButton(
                    child: const Text("Batal",
                        style: TextStyle(color: Colors.red)),
                    onPressed: () {
                      Navigator.pop(context);

                      showError = false;
                    },
                  ),
                  // Save button
                  TextButton(
                      child: const Text("Simpan"),
                      onPressed: () {
                        // Input is valid
                        if (errorText() == null) {
                          Navigator.of(context).pop(newValue);

                          // Update config value in storage
                          setState(() {
                            // Update config class
                            _config = Config.update(
                                oldConfig: _config,
                                key: field.toLowerCase().replaceAll(" ", "_"),
                                value: (isNumeric)
                                    ? int.parse(newValue)
                                    : newValue);

                            // Save updated config into storage
                            _storage.put("config", _config.toJson());
                          });

                          // Call callback function
                          if (controller == _uangMakanController) {
                            // Check input value
                            if (int.parse(newValue) == 0) {
                              // Delete uang makan attr from storage
                              _storage.delete("uang_makan_attr");
                            } else {
                              // Check if uang makan attr not available in storage
                              if (_storage.get("uang_makan_attr") == null) {
                                final Map<String, dynamic> newUangMakanAttr =
                                    {};

                                final DateTime today = DateTime.now();

                                newUangMakanAttr["jatuh_tempo"] =
                                    DateFormat('yyyy-MM-dd').format(DateTime(
                                        today.year,
                                        today.month,
                                        today.day + (7 - today.weekday)));

                                newUangMakanAttr["status"] = false;

                                newUangMakanAttr["is_active"] = true;

                                // Save new uang makan attr into storage
                                _storage.put(
                                    "uang_makan_attr", newUangMakanAttr);
                              }
                            }

                            widget.callback();
                          }

                          showError = false;
                        } else {
                          showError = true;
                        }
                      })
                ]));
  }

  @override
  void initState() {
    super.initState();

    // Retrieve old config data
    _config = Config.fromJson(_storage.get("config"));
  }

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
    return Container(
        color: Colors.blue,
        child: SafeArea(
            child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Title(
                          color: Colors.white,
                          child: const Text("Profil",
                              style: TextStyle(
                                  color: Colors.white, fontSize: 24))),
                      SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(vertical: 30),
                          child: Column(children: <Widget>[
                            // Nama
                            DataField(title: "Nama", widgets: <Widget>[
                              Data(
                                  icon: Icons.person,
                                  content: _config.nama,
                                  onPressed: () {
                                    _editData(
                                        controller: _namaController,
                                        oldValue: _config.nama,
                                        field: "Nama",
                                        isNumeric: false,
                                        maxLength: 100);
                                  })
                            ]),
                            const SizedBox(height: 20),
                            // Uang Kost
                            DataField(title: "Uang Kost", widgets: <Widget>[
                              Data(
                                  icon: Icons.hotel,
                                  content:
                                      "Rp. ${_toIdCurrency.format(_config.uangKostPerBulan)}/bln",
                                  onPressed: () {
                                    _editData(
                                        controller: _uangKostController,
                                        oldValue: _config.uangKostPerBulan,
                                        field: "Uang Kost/Bln",
                                        isNumeric: true,
                                        maxLength: 100);
                                  }),
                              Data(
                                  icon: Icons.date_range,
                                  content: "${_config.bayarUangKostPerTanggal}",
                                  onPressed: () {
                                    _editData(
                                        controller: _bayarUangKostController,
                                        oldValue:
                                            _config.bayarUangKostPerTanggal,
                                        field: "Bayar Uang Kost/Tgl",
                                        isNumeric: true,
                                        maxLength: 2);
                                  }),
                            ]),
                            const SizedBox(height: 10),
                            // Uang Makan
                            DataField(title: "Uang Makan", widgets: <Widget>[
                              Data(
                                  icon: Icons.fastfood,
                                  content:
                                      "Rp. ${_toIdCurrency.format(_config.uangSekaliMakan)}/mkn",
                                  onPressed: () {
                                    _editData(
                                        controller: _uangMakanController,
                                        oldValue: _config.uangSekaliMakan,
                                        field: "Uang Sekali Makan",
                                        isNumeric: true,
                                        maxLength: 100);
                                  })
                            ]),
                            const SizedBox(height: 10),
                            // Layanan aplikasi
                            Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 20, horizontal: 30),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(35)),
                                    boxShadow: [
                                      BoxShadow(
                                          offset: const Offset(4, 4),
                                          color: Colors.black.withOpacity(.2))
                                    ]),
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      const Text("Layanan Aplikasi",
                                          style: TextStyle(fontSize: 18)),
                                      Switch(
                                          value: _config.layananAplikasi,
                                          onChanged: (bool value) {
                                            // Change layanan aplikasi value
                                            setState(() {
                                              // Update layanan aplikasi
                                              _config.layananAplikasi = value;

                                              // Save updated config into storage
                                              _storage.put(
                                                  "config", _config.toJson());
                                            });
                                          },
                                          activeTrackColor:
                                              Colors.lightGreenAccent,
                                          activeColor: Colors.green)
                                    ]))
                          ]))
                    ]))));
  }
}
