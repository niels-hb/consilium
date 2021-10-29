import 'package:flutter/cupertino.dart';

class CustomTheme {
  static double getMaxWidth(BuildContext context) =>
      0.8 * MediaQuery.of(context).size.width;
}
