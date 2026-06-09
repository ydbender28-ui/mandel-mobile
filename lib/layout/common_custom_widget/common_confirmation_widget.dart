import 'package:flutter/material.dart';

class CommonConfirmationWidget extends StatelessWidget {
  final Function(bool selected) onSelect;
  final String title;
  final String description;

  const CommonConfirmationWidget(
      {super.key,
      required this.onSelect,
      required this.title,
      required this.description});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Wrap(
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w700),
          ),
          Container(
              margin: const EdgeInsets.only(top: 20, bottom: 30),
              child: Text(description, style: const TextStyle(fontSize: 16))),
          Container(
            margin: const EdgeInsets.only(bottom: 30),
            child: ElevatedButton(
              onPressed: () {
                onSelect(true);
              },
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(60)),
              child: const Text(
                'Yes, Go Ahead',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          Center(
            child: TextButton(
              style: TextButton.styleFrom(
                textStyle:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              onPressed: () {
                onSelect(false);
              },
              child: const Text('Skip'),
            ),
          )
        ],
      ),
    );
  }
}
