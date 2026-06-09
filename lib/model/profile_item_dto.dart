import 'package:flutter/material.dart';
import 'package:mandel_mobile_app/utility/common_custom_color.dart';

class ProfileItemDto {
  final int index;
  final IconData icon;
  Color? iconColor;
  final String itemName;
  Color? textColor;

  ProfileItemDto(
      {required this.index,
      required this.icon,
      this.iconColor = CommonCustomColor.menuItemColor,
      required this.itemName,
      this.textColor = CommonCustomColor.menuItemColor});
}
