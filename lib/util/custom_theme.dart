import 'package:consilium/models/category.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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

  static InputDecoration getDefaultInputDecoration({
    String? labelText,
  }) {
    return InputDecoration(
      labelText: labelText,
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
      ),
    );
  }

  static String getTranslationForCategory(
    BuildContext context,
    Category category,
  ) {
    switch (category) {
      case Category.fitness:
        return AppLocalizations.of(context)!.fitness;
      case Category.food:
        return AppLocalizations.of(context)!.food;
      case Category.housing:
        return AppLocalizations.of(context)!.housing;
      case Category.insurance:
        return AppLocalizations.of(context)!.insurance;
      case Category.medical:
        return AppLocalizations.of(context)!.medical;
      case Category.miscellaneous:
        return AppLocalizations.of(context)!.miscellaneous;
      case Category.hygiene:
        return AppLocalizations.of(context)!.hygiene;
      case Category.recreation:
        return AppLocalizations.of(context)!.recreation;
      case Category.subscriptions:
        return AppLocalizations.of(context)!.subscriptions;
      case Category.transportation:
        return AppLocalizations.of(context)!.transportation;
      case Category.utilities:
        return AppLocalizations.of(context)!.utilities;
    }
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
