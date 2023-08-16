class CalendarEvent {
  String title;
  String subtitle;

  CalendarEvent({this.title = '', this.subtitle = ''});

  // Convert json into class object
  factory CalendarEvent.fromJson(Map<dynamic, dynamic> json) {
    return CalendarEvent(title: json['title'], subtitle: json['subtitle']);
  }

  // Convert class object into json
  Map<dynamic, dynamic> toJson() {
    return {"title": title, "subtitle": subtitle};
  }
}