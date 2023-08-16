// Import flutter packages
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ServiceStoppedPage extends StatelessWidget {
  const ServiceStoppedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        SvgPicture.asset('assets/stop.svg', width: 500),
        Title(
            color: Colors.black,
            child: const Text("Berhenti!!",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold))),
        const SizedBox(height: 20),
        const Text(
            "Layanan ini dinonaktifkan, silahkan mengaktifkan \"Layanan Aplikasi\" di menu Profil untuk menggunakan layanan ini",
            style: TextStyle(fontSize: 19),
            textAlign: TextAlign.center),
      ],
    ));
  }
}
