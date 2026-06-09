import 'package:flutter/material.dart';
import 'package:mandel_mobile_app/layout/common_custom_widget/custom_number_pad.dart';
import 'package:mandel_mobile_app/utility/common_custom_color.dart';

class CommonCartNumberPicker extends StatefulWidget {
  final double? height;
  final int defaultValue;
  final Function(int value) onChange;

  const CommonCartNumberPicker(
      {super.key,
      required this.onChange,
      required this.defaultValue,
      this.height = 48.0});

  @override
  State<CommonCartNumberPicker> createState() => _CommonCartNumberPickerState();
}

class _CommonCartNumberPickerState extends State<CommonCartNumberPicker> {
  /////
  int defaultValue = 0;
//////

  @override
  void initState() {
    defaultValue = widget.defaultValue;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant CommonCartNumberPicker oldWidget) {
    defaultValue = widget.defaultValue;
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () {
              setState(() {
                if (defaultValue > 0) {
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
              decoration: BoxDecoration(
                border: Border.all(
                  color: CommonCustomColor.menuItemColor,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
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
            child: SizedBox(
              width: 35,
              child: Text(defaultValue.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: CommonCustomColor.menuItemColor)),
            ),
          ),
          InkWell(
            onTap: () {
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
                  color: CommonCustomColor.menuItemColor,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(
                Icons.add,
                size: 22,
                color: CommonCustomColor.menuItemColor,
              ),
            ),
          )
        ],
      ),
    );
  }
}
