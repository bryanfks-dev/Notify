class UangMakanAttr {
  String jatuhTempo;
  bool status;
  bool isActive;

  // Construct variables
  UangMakanAttr(
      {this.jatuhTempo = '', this.status = false, this.isActive = true});

  // Convert json into class object
  factory UangMakanAttr.fromJson(Map<dynamic, dynamic> json) {
    return UangMakanAttr(
        jatuhTempo: json['jatuh_tempo'],
        status: json['status'],
        isActive: json['is_active']);
  }

  // Convert class object into json
  Map<dynamic, dynamic> toJson() {
    return {"jatuh_tempo": jatuhTempo, "status": status, "is_active": isActive};
  }
}
