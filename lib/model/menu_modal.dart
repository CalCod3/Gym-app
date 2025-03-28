// models/menu_modal.dart
import 'package:flutter/material.dart';

class MenuModel {
  final IconData icon;
  final String title;
  final Widget? route;
  final List<MenuModel>? children;
  final bool isDashboard;

  MenuModel({
    required this.icon,
    required this.title,
    this.route,
    this.children,
    this.isDashboard = false,
  });
}
