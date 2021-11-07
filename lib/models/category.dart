import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

enum Category {
  fitness,
  food,
  housing,
  insurance,
  medical,
  miscellaneous,
  hygiene,
  recreation,
  savings,
  subscriptions,
  transportation,
  utilities
}

extension CategoryExtension on Category {
  String translation(BuildContext context) {
    switch (this) {
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
      case Category.savings:
        return AppLocalizations.of(context)!.savings;
      case Category.subscriptions:
        return AppLocalizations.of(context)!.subscriptions;
      case Category.transportation:
        return AppLocalizations.of(context)!.transportation;
      case Category.utilities:
        return AppLocalizations.of(context)!.utilities;
    }
  }

  IconData icon() {
    switch (this) {
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
      case Category.savings:
        return Icons.savings;
      case Category.subscriptions:
        return Icons.subscriptions;
      case Category.transportation:
        return Icons.train;
      case Category.utilities:
        return Icons.power;
    }
  }

  Color color() {
    switch (this) {
      case Category.fitness:
        return Colors.pink;
      case Category.food:
        return Colors.green;
      case Category.housing:
        return Colors.brown;
      case Category.insurance:
        return Colors.lime;
      case Category.medical:
        return Colors.red;
      case Category.miscellaneous:
        return Colors.blue;
      case Category.hygiene:
        return Colors.cyan;
      case Category.recreation:
        return Colors.teal;
      case Category.savings:
        return Colors.lightGreen;
      case Category.subscriptions:
        return Colors.amber;
      case Category.transportation:
        return Colors.orange;
      case Category.utilities:
        return Colors.yellow;
    }
  }
}

Category? categoryFromTranslation(
  BuildContext context,
  String? translation,
) {
  final AppLocalizations localizations = AppLocalizations.of(context)!;

  if (translation == localizations.fitness) {
    return Category.fitness;
  } else if (translation == localizations.food) {
    return Category.food;
  } else if (translation == localizations.housing) {
    return Category.housing;
  } else if (translation == localizations.insurance) {
    return Category.insurance;
  } else if (translation == localizations.medical) {
    return Category.medical;
  } else if (translation == localizations.miscellaneous) {
    return Category.miscellaneous;
  } else if (translation == localizations.hygiene) {
    return Category.hygiene;
  } else if (translation == localizations.recreation) {
    return Category.recreation;
  } else if (translation == localizations.savings) {
    return Category.savings;
  } else if (translation == localizations.subscriptions) {
    return Category.subscriptions;
  } else if (translation == localizations.transportation) {
    return Category.transportation;
  } else if (translation == localizations.utilities) {
    return Category.utilities;
  }
}
