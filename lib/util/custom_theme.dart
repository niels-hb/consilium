import 'package:consilium/models/category.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class CustomTheme {
  static const double _breakpointSmall = 600;
  static const double _breakpointMedium = 1200;

  static double getMaxWidth(BuildContext context) =>
      _getWidthMultiplier(context) * MediaQuery.of(context).size.width;

  static double _getWidthMultiplier(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    if (width <= _breakpointSmall) {
      return 0.9;
    } else if (width <= _breakpointMedium) {
      return 0.8;
    } else {
      return 0.5;
    }
  }

  static DateFormat getDefaultDateFormat() {
    return DateFormat("yyyy-MM-dd");
  }

  static IconData getIconForCategory(Category category) {
    switch (category) {
      case Category.fitness:
        return Icons.fitness_center;
      case Category.food:
        return Icons.fastfood;
      case Category.housing:
        return Icons.house;
      case Category.insurance:
        return FontAwesomeIcons.umbrella;
      case Category.medical:
        return Icons.medication;
      case Category.miscellaneous:
        return Icons.miscellaneous_services;
      case Category.hygiene:
        return Icons.soap;
      case Category.recreation:
        return Icons.gamepad;
      case Category.subscriptions:
        return Icons.subscriptions;
      case Category.transportation:
        return Icons.train;
      case Category.utilities:
        return Icons.power;
    }
  }
}
