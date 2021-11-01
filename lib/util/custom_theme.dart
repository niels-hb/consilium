import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const double _breakpointSmall = 600;
const double _breakpointMedium = 1200;

double getMaxWidth(BuildContext context) =>
    _getWidthMultiplier(context) * MediaQuery.of(context).size.width;

double _getWidthMultiplier(BuildContext context) {
  final double width = MediaQuery.of(context).size.width;

  if (width <= _breakpointSmall) {
    return 0.9;
  } else if (width <= _breakpointMedium) {
    return 0.8;
  } else {
    return 0.5;
  }
}

DateFormat getDefaultDateFormat() {
  return DateFormat.yMd('de');
}

NumberFormat getDefaultNumberFormat() {
  return NumberFormat.currency(
    locale: 'de',
    symbol: '€',
  );
}

InputDecoration getDefaultInputDecoration({
  String? labelText,
}) {
  return InputDecoration(
    labelText: labelText,
    border: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(8.0)),
    ),
  );
}
