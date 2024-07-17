// models/menu_modal.dart
import 'package:flutter/material.dart';

class MenuModel {
  final String icon;
  final String title;
  final Widget route;

  MenuModel({
    required this.icon,
    required this.title,
    required this.route,
  });
}
