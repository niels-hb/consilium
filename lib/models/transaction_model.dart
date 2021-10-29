import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:consilium/models/category.dart';
import 'package:enum_to_string/enum_to_string.dart';

class TransactionModel {
  final int amountCents;
  final Category category;
  final DateTime createdOn;
  final String name;
  final String uid;
  final String? note;
  final DocumentReference? linkedSchedule;

  const TransactionModel({
    required this.amountCents,
    required this.category,
    required this.createdOn,
    required this.name,
    required this.uid,
    this.note,
    this.linkedSchedule,
  });

  TransactionModel.fromJson(Map<String, Object?> json)
      : this(
          amountCents: int.tryParse(
                json['amount_cents'].toString(),
              ) ??
              -1,
          category: EnumToString.fromString(
                Category.values,
                json['category'].toString(),
              ) ??
              Category.miscellaneous,
          createdOn: (json['created_on'] as Timestamp).toDate(),
          name: json['name'].toString(),
          uid: json['uid'].toString(),
          note: json['note']?.toString(),
          linkedSchedule: json['linked_schedule'] == null
              ? null
              : json['linked_schedule'] as DocumentReference,
        );

  Map<String, Object?> toJson() => {
        'amount_cents': amountCents,
        'category': EnumToString.convertToString(category),
        'created_on': createdOn,
        'name': name,
        'uid': uid,
        'note': note,
        'linked_schedule':
            linkedSchedule == null ? null : 'schedules/${linkedSchedule!.id}',
      };
}
