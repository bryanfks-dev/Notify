import 'package:flutter/material.dart';

// Data widget
class Data extends StatefulWidget {
  final String left;
  final dynamic right;

  const Data({super.key, required this.left, required this.right});

  @override
  State<Data> createState() => _Data();
}

class _Data extends State<Data> {
  @override
  Widget build(BuildContext context) =>
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(widget.left, style: const TextStyle(fontSize: 15)),
        widget.right
      ]);
}

// Data field widget
class DataField extends StatefulWidget {
  final String title;
  final List<Widget> widgets;
  final bool needFooter;

  const DataField(
      {super.key,
      required this.title,
      required this.widgets,
      required this.needFooter});

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
              Text(widget.title, style: const TextStyle(fontSize: 17)),
              const SizedBox(height: 15),
              // Content
              for (int idx = 0;
                  (widget.needFooter) ? idx < listLength - 1 : idx < listLength;
                  idx++) ...[
                widget.widgets[idx],
                if ((widget.needFooter)
                    ? idx + 2 < listLength
                    : idx + 1 < listLength)
                  const SizedBox(height: 15),
              ],
              if (widget.needFooter) ...[
                const SizedBox(height: 3),
                const Divider(color: Colors.black, thickness: 1),
                const SizedBox(height: 3),
                widget.widgets[listLength - 1]
              ]
            ]));
  }
}
