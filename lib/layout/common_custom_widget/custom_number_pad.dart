import 'dart:async';

import 'package:flutter/material.dart';

class CustomNumberPad extends StatefulWidget {
  final int? initValue;
  final int? limit;
  final Function(int value) onChange;

  const CustomNumberPad(
      {super.key, this.initValue = 0, this.limit = 3, required this.onChange});

  @override
  State<CustomNumberPad> createState() => _CustomNumberPadState();
}

class _CustomNumberPadState extends State<CustomNumberPad> {
  final StreamController<String> _streamController =
      StreamController.broadcast();

  String value = "";

  List<String> keys = [
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
    "8",
    "9",
    "0",
    "clear",
    "done"
  ];

  @override
  void initState() {
    if (widget.initValue! > 0) {
      value = widget.initValue.toString();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: Colors.white,
      ),
      child: Column(
        children: [_buildIndicator(), _buildPad()],
      ),
    );
  }

  _buildIndicator() {
    return Container(
        margin: const EdgeInsets.only(top: 20),
        decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(width: 1, color: Colors.black))),
        height: 100,
        child: Center(
          child: StreamBuilder(
            initialData: widget.initValue.toString(),
            stream: _streamController.stream,
            builder: (context, snapshot) {
              return Text(
                '${snapshot.data}',
                style:
                    const TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
              );
            },
          ),
        ));
  }

  _buildPad() {
    return Expanded(
      child: GridView.count(
          crossAxisCount: 3,
          padding: const EdgeInsets.all(30),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: [
            ..._buildNumberKey(),
          ]),
    );
  }

  List<Widget> _buildNumberKey() {
    List<Widget> numberKeys = [];

    for (var element in keys) {
      if (element == "clear") {
        numberKeys.add(IconButton(
            onPressed: () {
              if (value.isNotEmpty) {
                value = value.substring(0, value.length - 1);
              }
              _streamController.sink.add(value.isEmpty ? "0" : value);
            },
            icon: const Icon(
              Icons.backspace,
              size: 50,
            )));
      } else if (element == "done") {
        numberKeys.add(IconButton(
            onPressed: () {
              widget.onChange(int.parse(value));
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.done_sharp,
              size: 50,
            )));
      } else {
        numberKeys.add(TextButton(
          onPressed: () {
            if (value.length < 3) {
              value += element;
              _streamController.sink.add(value);
            }
          },
          style: TextButton.styleFrom(
            side: const BorderSide(color: Colors.black, width: 1),
          ),
          child: Text(
            element,
            style: const TextStyle(
                fontSize: 28, color: Colors.black, fontWeight: FontWeight.w500),
          ),
        ));
      }
    }

    return numberKeys;
  }
}
