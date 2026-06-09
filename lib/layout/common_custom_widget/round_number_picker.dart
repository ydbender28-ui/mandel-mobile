import 'package:flutter/material.dart';
import 'package:mandel_mobile_app/layout/common_custom_widget/custom_number_pad.dart';
import 'package:mandel_mobile_app/utility/common_custom_color.dart';
import 'package:mandel_mobile_app/utility/message_utility.dart';

class RoundNumberPicker extends StatefulWidget {
  final double? height;
  final double? width;
  final int defaultValue;
  final bool fromOrder;
  final bool isLimit;
  final Function(int value) onChange;

  const RoundNumberPicker(
      {super.key,
      this.height = 80.0,
      this.width = 250.0,
      required this.defaultValue,
      required this.isLimit,
      required this.fromOrder,
      required this.onChange});

  @override
  State<RoundNumberPicker> createState() => _RoundNumberPickerState();
}

class _RoundNumberPickerState extends State<RoundNumberPicker>
    with MessageUtility {
  final _numberController = TextEditingController();
  /////
  int defaultValue = 1;
  /////

  @override
  void initState() {
    defaultValue = widget.defaultValue;
    _numberController.text = defaultValue.toString();
    super.initState();
  }

  @override
  void dispose() {
    _numberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: widget.width,
      child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  if (defaultValue > 1) {
                    defaultValue = defaultValue - 1;
                    _numberController.text = defaultValue.toString();
                    widget.onChange(defaultValue);
                  }
                });
              },
              child: Container(
                margin: const EdgeInsets.all(10),
                width: 54,
                height: 54,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: CommonCustomColor.menuItemColor,
                  ),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: const Icon(
                  Icons.remove,
                  color: CommonCustomColor.menuItemColor,
                ),
              ),
            ),
            SizedBox(
              width: 80,
              child: TextFormField(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return Dialog(
                        insetPadding: const EdgeInsets.only(
                            top: 85, bottom: 85, left: 30, right: 30),
                        child: CustomNumberPad(
                          initValue: defaultValue,
                          onChange: (value) {
                            if (!widget.fromOrder ||
                                (widget.isLimit &&
                                    widget.defaultValue >= value)) {
                              defaultValue = value;
                              _numberController.text = defaultValue.toString();
                              widget.onChange(defaultValue);
                            } else {
                              showErrorMessage(
                                  duration: const Duration(seconds: 5),
                                  message:
                                      "Oops! It looks like you've entered more than the allowed quantity !",
                                  context: context);
                            }
                          },
                        ),
                      );
                    },
                  );
                },
                readOnly: true,
                controller: _numberController,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 30, fontWeight: FontWeight.w600),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  fillColor: Colors.transparent,
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                ),
              ),
            ),
            InkWell(
              onTap: () {
                if (widget.isLimit && defaultValue >= widget.defaultValue) {
                  return;
                }
                setState(() {
                  defaultValue = defaultValue + 1;
                  _numberController.text = defaultValue.toString();
                  widget.onChange(defaultValue);
                });
              },
              child: Container(
                margin: const EdgeInsets.all(10),
                alignment: Alignment.center,
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: CommonCustomColor.mandelPrimaryColor,
                  ),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: const Icon(
                  Icons.add,
                  color: CommonCustomColor.mandelPrimaryColor,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
