import 'package:flutter/cupertino.dart';

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
}
