import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:consilium/models/category.dart';
import 'package:consilium/models/schedule_type.dart';
import 'package:enum_to_string/enum_to_string.dart';

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
        'created_on': createdOn,
        'frequency_months': frequencyMonths,
        'name': name,
        'started_on': startedOn,
        'type': type,
        'uid': uid,
        'canceled_on': canceledOn,
        'note': note,
      };
}
