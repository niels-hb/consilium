import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:consilium/models/category.dart';

class TransactionModel {
  final int amountCents;
  final Category category;
  final DateTime createdOn;
  final String name;
  final String uid;
  final String? note;

  const TransactionModel({
    required this.amountCents,
    required this.category,
    required this.createdOn,
    required this.name,
    required this.uid,
    this.note,
  });

  TransactionModel.fromJson(Map<String, Object?> json)
      : this(
          amountCents: int.tryParse('${json['amount_cents']}') ?? -1,
          category: Category.values.firstWhere(
            (category) => category.toString() == 'Category.${json['category']}',
          ),
          createdOn: (json['created_on'] as Timestamp).toDate(),
          name: '${json['name']}',
          uid: '${json['uid']}',
          note: '${json['note']}',
        );

  Map<String, Object?> toJson() => {
        'amount_cents': amountCents,
        'category': category,
        'created_on': createdOn,
        'name': name,
        'uid': uid,
        'note': note,
      };
}