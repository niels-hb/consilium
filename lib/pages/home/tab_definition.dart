import 'package:flutter/material.dart';

class TabDefinition {
  final Widget content;
  final BottomNavigationBarItem bottomNavigationBarItem;

  const TabDefinition({
    required this.content,
    required this.bottomNavigationBarItem,
  });
}
