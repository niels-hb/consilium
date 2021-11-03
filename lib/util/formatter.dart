import 'package:intl/intl.dart';

extension ParsingExtension on NumberFormat {
  double? tryParse(String source) {
    try {
      return NumberFormat().parse(source).toDouble();
    } on FormatException catch (_) {
      return null;
    }
  }
}
