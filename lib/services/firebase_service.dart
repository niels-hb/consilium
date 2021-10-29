import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:consilium/models/schedule_model.dart';
import 'package:consilium/models/transaction_model.dart';
import 'package:enum_to_string/enum_to_string.dart';

enum FirebaseCollection {
  schedules,
  transactions,
}

class FirebaseService {
  static Query<TransactionModel> getTransactionsCollection() => getCollection(
        collection: FirebaseCollection.transactions,
        fromFirestore: (snapshot, _) =>
            TransactionModel.fromJson(snapshot.data()!),
        toFirestore: (transaction, _) => transaction.toJson(),
      );

  static Query<ScheduleModel> getSchedulesCollection() => getCollection(
        collection: FirebaseCollection.schedules,
        fromFirestore: (snapshot, _) =>
            ScheduleModel.fromJson(snapshot.data()!),
        toFirestore: (schedule, _) => schedule.toJson(),
      );

  static Query<R> getCollection<R>({
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
}
