import 'package:flutter/material.dart';

class MultiActionConfirmationWidget extends StatelessWidget {
  final String title;
  final List<ConfirmationAction> actions;
  final String? description;

  const MultiActionConfirmationWidget(
      {super.key,
      required this.title,
      required this.actions,
      this.description});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Wrap(
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          Container(
              margin: const EdgeInsets.only(top: 20, bottom: 30),
              child: Text(description ?? '',
                  style: const TextStyle(fontSize: 16))),
          ..._buildActions()
        ],
      ),
    );
  }

  List<Widget> _buildActions() {
    return actions.map((ConfirmationAction a) {
      return Container(
        margin: const EdgeInsets.only(bottom: 20),
        child: ElevatedButton(
            onPressed: () {
              a.onSelect();
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: a.buttonColor,
                minimumSize: const Size.fromHeight(50)),
            child: Text(
              a.text,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            )),
      );
    }).toList();
  }
}

class ConfirmationAction {
  final String text;
  final Function() onSelect;
  final Color? buttonColor;

  const ConfirmationAction(
      {required this.text, required this.onSelect, this.buttonColor});
}
