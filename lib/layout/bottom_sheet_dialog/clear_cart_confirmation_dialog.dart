import 'package:flutter/material.dart';
import 'package:mandel_mobile_app/utility/common_custom_color.dart';

class ClearCartConfirmationDialog {
  final BuildContext context;
  final bool clearOrder;
  final Function(bool confirmation) onSelect;
  final String masterClearTitle;
  final String masterClearDetail;
  final String itemClearTitle;
  final String itemCleatDetail;

  ClearCartConfirmationDialog({
    required this.context,
    required this.clearOrder,
    required this.onSelect,
    required this.masterClearTitle,
    required this.masterClearDetail,
    required this.itemClearTitle,
    required this.itemCleatDetail,
  });

  ///
  ///This method will return confirmation dialog instance
  void showClearCartConfirmation() {
    showModalBottomSheet(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.0))),
        isScrollControlled: true,
        backgroundColor: Colors.white,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (BuildContext context, setState) {
            return Wrap(
              children: [
                Visibility(visible: clearOrder, child: _buildClearCartPopUp()),
                Visibility(visible: !clearOrder, child: _buildClearItemPopUp())
              ],
            );
          });
        });
  }

  ///
  ///This method will return clear item confirmation dialog
  _buildClearItemPopUp() {
    return Container(
      margin: const EdgeInsets.only(top: 10, bottom: 20, left: 20, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 10),
            child: Text(
              itemClearTitle,
              style: const TextStyle(
                  color: CommonCustomColor.defaultTextColor,
                  fontSize: 25,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            child: Text(itemCleatDetail,
                style: const TextStyle(
                    color: CommonCustomColor.defaultTextColor, fontSize: 15)),
          ),
          Row(
            children: [
              SizedBox(
                width: 150.0,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15.0)),
                        ),
                        minimumSize: const Size.fromHeight(42)),
                    onPressed: () {
                      onSelect(true);
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Yes",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    )),
              ),
              const Spacer(),
              SizedBox(
                width: 150.0,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: CommonCustomColor.defaultTextColor,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15.0)),
                        ),
                        side: const BorderSide(
                          width: 1.0,
                        ),
                        minimumSize: const Size.fromHeight(42)),
                    onPressed: () {
                      onSelect(false);
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "No",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    )),
              )
            ],
          )
        ],
      ),
    );
  }

  ///
  ///This method will return clear cart confirmation dialog
  _buildClearCartPopUp() {
    return Container(
      margin: const EdgeInsets.only(top: 10, bottom: 20, left: 20, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 10),
            child: Text(
              masterClearTitle,
              style: const TextStyle(
                  color: CommonCustomColor.defaultTextColor,
                  fontSize: 25,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            child: Text(masterClearDetail,
                softWrap: true,
                style: const TextStyle(
                    color: CommonCustomColor.defaultTextColor, fontSize: 15)),
          ),
          Row(
            children: [
              SizedBox(
                width: 150.0,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: CommonCustomColor.defaultTextColor,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15.0)),
                          side: BorderSide(
                            width: 1.0,
                          ),
                        ),
                        minimumSize: const Size.fromHeight(42)),
                    onPressed: () {
                      onSelect(true);
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Clear",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    )),
              ),
              const Spacer(),
              SizedBox(
                width: 150.0,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15.0)),
                        ),
                        minimumSize: const Size.fromHeight(42)),
                    onPressed: () {
                      onSelect(false);
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Save",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    )),
              )
            ],
          )
        ],
      ),
    );
  }
}
