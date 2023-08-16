class UangKostAttr {
  String jatuhTempo;
  bool status;

  // Construct variables
  UangKostAttr(
      {this.jatuhTempo = '',
      this.status = false});

  // Convert json into class object
  factory UangKostAttr.fromJson(Map<dynamic, dynamic> json) {
    return UangKostAttr(
        jatuhTempo: json['jatuh_tempo'],
        status: json['status']);
  }

  // Convert class object into json
  Map<dynamic, dynamic> toJson() {
    return {
      "jatuh_tempo": jatuhTempo,
      "status": status
    };
  }
}
