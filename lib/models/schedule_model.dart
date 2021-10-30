import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:consilium/models/category.dart';
import 'package:consilium/models/schedule_type.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:jiffy/jiffy.dart';

class ScheduleModel {
  final int amountCents;
  final Category category;
  final DateTime createdOn;
  final int frequencyMonths;
  final String name;
  final DateTime startedOn;
  final ScheduleType type;
  final String uid;
  final DateTime? canceledOn;
  final String? note;

  int get signedAmountCents =>
      (type == ScheduleType.outgoing ? -1 : 1) * amountCents;

  DateTime get nextPaymentOn {
    DateTime nextPaymentOn = startedOn;

    do {
      nextPaymentOn =
          Jiffy(nextPaymentOn).add(months: frequencyMonths).dateTime;
    } while (nextPaymentOn.isBefore(DateTime.now()));

    return nextPaymentOn;
  }

  const ScheduleModel({
    required this.amountCents,
    required this.category,
    required this.createdOn,
    required this.frequencyMonths,
    required this.name,
    required this.startedOn,
    required this.type,
    required this.uid,
    this.canceledOn,
    this.note,
  });

  ScheduleModel.fromJson(Map<String, Object?> json)
      : this(
          amountCents: int.tryParse(
                json['amount_cents'].toString(),
              ) ??
              -1,
          category: EnumToString.fromString(
                Category.values,
                json['category'].toString(),
              ) ??
              Category.subscriptions,
          createdOn: (json['created_on'] as Timestamp).toDate(),
          frequencyMonths: int.tryParse(
                json['frequency_months'].toString(),
              ) ??
              -1,
          name: json['name'].toString(),
          startedOn: (json['started_on'] as Timestamp).toDate(),
          type: EnumToString.fromString(
                ScheduleType.values,
                json['type'].toString(),
              ) ??
              ScheduleType.outgoing,
          uid: json['uid'].toString(),
          canceledOn: json['canceled_on'] == null
              ? null
              : (json['canceled_on'] as Timestamp).toDate(),
          note: json['note']?.toString(),
        );

  Map<String, Object?> toJson() => {
        'amount_cents': amountCents,
        'category': category,
        'created_on': Timestamp.fromDate(createdOn),
        'frequency_months': frequencyMonths,
        'name': name,
        'started_on': Timestamp.fromDate(startedOn),
        'type': type,
        'uid': uid,
        'canceled_on':
            canceledOn == null ? null : Timestamp.fromDate(canceledOn!),
        'note': note,
      };
}
