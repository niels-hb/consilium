import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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

  static NumberFormat getDefaultNumberFormat() {
    return NumberFormat.currency(
      locale: 'de',
      symbol: '€',
    );
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
}
