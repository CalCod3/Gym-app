// models/menu_modal.dart
import 'package:flutter/material.dart';

class MenuModel {
  final IconData icon;
  final String title;
  final Widget route;
  final List<MenuModel>? children;

  MenuModel({
    required this.icon,
    required this.title,
    required this.route,
    this.children,
  });
}
