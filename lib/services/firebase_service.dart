import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enum_to_string/enum_to_string.dart';

import '../models/schedule_model.dart';
import '../models/transaction_model.dart';

enum FirebaseCollection {
  schedules,
  transactions,
}

CollectionReference<TransactionModel> getTransactionsCollection() =>
    getCollection(
      collection: FirebaseCollection.transactions,
      fromFirestore: (
        DocumentSnapshot<Map<String, dynamic>> snapshot,
        _,
      ) =>
          TransactionModel.fromJson(snapshot.data()!),
      toFirestore: (TransactionModel transaction, _) => transaction.toJson(),
    );

CollectionReference<ScheduleModel> getSchedulesCollection() => getCollection(
      collection: FirebaseCollection.schedules,
      fromFirestore: (
        DocumentSnapshot<Map<String, dynamic>> snapshot,
        _,
      ) =>
          ScheduleModel.fromJson(snapshot.data()!),
      toFirestore: (ScheduleModel schedule, _) => schedule.toJson(),
    );

CollectionReference<R> getCollection<R>({
  required FirebaseCollection collection,
  required R Function(
    DocumentSnapshot<Map<String, dynamic>>,
    SnapshotOptions?,
  )
      fromFirestore,
  required Map<String, Object?> Function(
    R,
    SetOptions?,
  )
      toFirestore,
}) =>
    FirebaseFirestore.instance
        .collection(EnumToString.convertToString(collection))
        .withConverter<R>(
          fromFirestore: fromFirestore,
          toFirestore: toFirestore,
        );
