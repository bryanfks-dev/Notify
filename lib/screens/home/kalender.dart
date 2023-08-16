import 'package:collection/collection.dart';

// Import flutter packages
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

// Import model
import 'package:notify/model/calendar_event.dart';

class KalenderPage extends StatefulWidget {
  const KalenderPage({Key? key}) : super(key: key);

  @override
  State<KalenderPage> createState() => _KalenderPage();
}

class _KalenderPage extends State<KalenderPage> {
  final Box<dynamic> _storage = Hive.box("storage");

  final TextEditingController _controller = TextEditingController();

  DateTime _focusedDate = DateTime.now();
  DateTime? _selectedDate;

  final Map<String, List<CalendarEvent>> _events = {};

  // Function to retrieve selected date events
  List _listOfDayEvents(DateTime dateTime) {
    if (_events[DateFormat('yyyy-MM-dd').format(dateTime)] != null) {
      return _events[DateFormat('yyyy-MM-dd').format(dateTime)]!;
    } else {
      return [];
    }
  }

  // Function to edit field
  Future<void> _editField(
      {required CalendarEvent thisClass, required DateTime? thisDate}) async {
    String newValue = '';

    _controller.text = thisClass.subtitle;

    bool showError = false;

    String? errorText() {
      String? text = _controller.value.text;

      if (text.isEmpty) {
        return "Nilai harus diisi";
      } else if (int.parse(text) <= 0) {
        return "Nilai tidak boleh lebih kecil dari 0";
      }

      return null;
    }

    await showDialog(
        context: context,
        builder: (context) => AlertDialog(
                title: const Text("Edit Makan di kost"),
                content: ValueListenableBuilder(
                    valueListenable: _controller,
                    builder: (context, TextEditingValue value, _) => TextField(
                        controller: _controller,
                        autofocus: true,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration: InputDecoration(
                            helperText: "Ketik 0 jika tidak ada",
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

                          setState(() {
                            // Update calendar event class
                            thisClass.subtitle = newValue;

                            dynamic oldEvents = _storage.get("calendar_events");

                            List values = oldEvents[
                                    DateFormat('yyyy-MM-dd').format(thisDate!)];
                            
                            dynamic foundObj = values.firstWhereOrNull(
                                    (event) => event["title"] == "Makan di kost");

                            foundObj["subtitle"] = newValue;

                            // Save updated value into storage
                            _storage.put("calendar_events", oldEvents);
                          });

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

    _selectedDate = _focusedDate;

    // Retrieve old calendar event data
    dynamic events = _storage.get("calendar_events");

    if (events != null) {
      // Calendar events should be looks like this:
      // "2023-08-15" : [
      // {"title": "Bayar uang makan", "number": 2},
      // ...
      // ]

      events.forEach((dynamic key, dynamic value) {
        List<CalendarEvent> newValues = [];

        // Convert event json into class object
        for (var item in value) {
          newValues.add(CalendarEvent.fromJson(item));
        }

        _events[key] = newValues;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();

    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(children: [
              // Calendar
              TableCalendar(
                  locale: "en_US",
                  headerStyle: const HeaderStyle(
                      formatButtonVisible: false, titleCentered: true),
                  focusedDay: _focusedDate,
                  firstDay: DateTime.utc(_focusedDate.year - 10, 10, 16),
                  lastDay: DateTime.utc(_focusedDate.year + 10, 10, 16),
                  calendarStyle: const CalendarStyle(
                    selectedDecoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle
                    ),
                    todayDecoration: BoxDecoration(
                      color: Colors.lightBlueAccent,
                      shape: BoxShape.circle
                    ),
                    markerDecoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.deepOrange
                    )
                  ),
                  selectedDayPredicate: (day) {
                    return isSameDay(day, _selectedDate);
                  },
                  onDaySelected: (DateTime selectedDate, DateTime focusedDate) {
                    if (!isSameDay(_selectedDate, selectedDate)) {
                      setState(() {
                        _selectedDate = selectedDate;
                        _focusedDate = focusedDate;
                      });
                    }
                  },
                  onPageChanged: (focusedDate) {
                    _focusedDate = focusedDate;
                  },
                  eventLoader: _listOfDayEvents),
              // Mapping events
              SingleChildScrollView(
                  child: Column(children: [
                ..._listOfDayEvents(_selectedDate!).map((event) => ListTile(
                      leading: Icon(
                          (event.title == 'Makan di kost')
                              ? Icons.fastfood
                              : Icons.payment,
                          color: Colors.blue),
                      title: Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(event.title)),
                      subtitle: Text("${event.subtitle}"),
                      onTap: () {
                        (event.title == "Makan di kost")
                            ? _editField(
                                thisClass: event, thisDate: _selectedDate)
                            : null;
                      },
                    ))
              ]))
            ])));
  }
}
