import 'package:flutter/material.dart';
import 'package:mandel_mobile_app/layout/common_custom_widget/custom_number_pad.dart';
import 'package:mandel_mobile_app/utility/common_custom_color.dart';

class CommonNumberPicker extends StatefulWidget {
  final double? height;
  final int defaultValue;
  final bool isLimit;
  final Function(int value) onChange;

  const CommonNumberPicker(
      {super.key,
      required this.onChange,
      required this.defaultValue,
      required this.isLimit,
      this.height = 48.0});

  @override
  State<CommonNumberPicker> createState() => _CommonNumberPickerState();
}

class _CommonNumberPickerState extends State<CommonNumberPicker> {
  /////
  int defaultValue = 1;
  /////

  @override
  void initState() {
    defaultValue = widget.defaultValue;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(
                color: CommonCustomColor.mandelPrimaryColor, width: 1),
            borderRadius: BorderRadius.circular(8)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  if (defaultValue > 1) {
                    defaultValue = defaultValue - 1;
                    widget.onChange(defaultValue);
                  }
                });
              },
              child: Container(
                margin: const EdgeInsets.all(10),
                alignment: Alignment.center,
                width: 28,
                height: 28,
                child: const Icon(
                  Icons.remove,
                  size: 22,
                  color: CommonCustomColor.menuItemColor,
                ),
              ),
            ),
            InkWell(
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
                          setState(() {
                            defaultValue = value;
                            widget.onChange(defaultValue);
                          });
                        },
                      ),
                    );
                  },
                );
              },
              child: Text(defaultValue.toString(),
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: CommonCustomColor.menuItemColor)),
            ),
            InkWell(
              onTap: () {
                if (widget.isLimit && defaultValue >= widget.defaultValue) {
                  return;
                }
                setState(() {
                  defaultValue = defaultValue + 1;
                  widget.onChange(defaultValue);
                });
              },
              child: Container(
                margin: const EdgeInsets.all(10),
                alignment: Alignment.center,
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: CommonCustomColor.mandelPrimaryColor,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(
                  Icons.add,
                  size: 22,
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
