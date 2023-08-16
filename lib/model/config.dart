class Config {
  String nama;
  int uangKostPerBulan;
  int bayarUangKostPerTanggal;
  int uangSekaliMakan;
  bool layananAplikasi;

  // Construct variables
  Config(
      {this.nama = '',
      this.uangKostPerBulan = 0,
      this.bayarUangKostPerTanggal = 0,
      this.uangSekaliMakan = 0,
      this.layananAplikasi = true});

  // Convert json into class object
  factory Config.fromJson(Map<dynamic, dynamic> json) {
    return Config(
        nama: json['nama'],
        uangKostPerBulan: json['uang_kost/bln'],
        bayarUangKostPerTanggal: json['bayar_uang_kost/tgl'],
        uangSekaliMakan: json['uang_sekali_makan'],
        layananAplikasi: json['layanan_aplikasi']);
  }

  // Convert class object into json
  Map<dynamic, dynamic> toJson() {
    return {
      'nama': nama,
      'uang_kost/bln': uangKostPerBulan,
      'bayar_uang_kost/tgl': bayarUangKostPerTanggal,
      'uang_sekali_makan': uangSekaliMakan,
      'layanan_aplikasi': layananAplikasi
    };
  }

  // Update class variables value
  static Config update(
      {required Config oldConfig,
      required String key,
      required dynamic value}) {
    // Convert old config into json
    Map<dynamic, dynamic> configJson = oldConfig.toJson();

    // Update key
    configJson[key] = value;

    // Return new config class
    return Config.fromJson(configJson);
  }
}
