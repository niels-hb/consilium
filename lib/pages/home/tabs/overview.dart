import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:jiffy/jiffy.dart';

import '../../../models/schedule_model.dart';
import '../../../models/transaction_model.dart';
import '../../../services/firebase_service.dart';
import '../../../util/custom_theme.dart';
import '../../../widgets/add_transaction_dialog.dart';
import '../../../widgets/schedule_list_tile.dart';
import '../../../widgets/transaction_list_tile.dart';

class OverviewTab extends StatelessWidget {
  const OverviewTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        const SizedBox(height: 16.0),
        _MonthToDateCard(),
        const SizedBox(height: 16.0),
        _UpcomingPaymentsCard(),
        const SizedBox(height: 16.0),
        _LatestTransactionsCard(),
      ],
    );
  }
}

class _MonthToDateCard extends StatelessWidget {
  _MonthToDateCard({Key? key}) : super(key: key);

  final Query<TransactionModel> _transactions = getTransactionsCollection()
      .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
      .where(
        'created_on',
        isGreaterThanOrEqualTo: Timestamp.fromDate(
          Jiffy().startOf(Units.MONTH).dateTime,
        ),
      )
      .orderBy('created_on', descending: true);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: getMaxWidth(context),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  AppLocalizations.of(context)!.monthToDate,
                  style: Theme.of(context).textTheme.caption,
                ),
                const SizedBox(height: 8.0),
                StreamBuilder<QuerySnapshot<TransactionModel>>(
                  stream: _transactions.snapshots(),
                  builder: (
                    BuildContext context,
                    AsyncSnapshot<QuerySnapshot<TransactionModel>> snapshot,
                  ) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(snapshot.error.toString()),
                      );
                    }

                    if (snapshot.hasData) {
                      double sum = 0;

                      for (final QueryDocumentSnapshot<
                              TransactionModel> transaction
                          in snapshot.data!.docs) {
                        sum += transaction.data().amount;
                      }

                      return Text(
                        getDefaultNumberFormat().format(sum),
                        style: Theme.of(context).textTheme.subtitle1,
                      );
                    }

                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _UpcomingPaymentsCard extends StatelessWidget {
  _UpcomingPaymentsCard({Key? key}) : super(key: key);

  final Query<ScheduleModel> _schedules = getSchedulesCollection()
      .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: SizedBox(
        width: getMaxWidth(context),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildHeader(context),
                _buildScheduleList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Text(
      AppLocalizations.of(context)!.upcomingPayments,
      style: Theme.of(context).textTheme.subtitle1,
    );
  }

  Widget _buildScheduleList() {
    return StreamBuilder<QuerySnapshot<ScheduleModel>>(
      stream: _schedules.snapshots(),
      builder: (
        BuildContext context,
        AsyncSnapshot<QuerySnapshot<ScheduleModel>> snapshot,
      ) {
        if (snapshot.hasError) {
          return Center(
            child: Text(snapshot.error.toString()),
          );
        }

        if (snapshot.hasData) {
          final List<QueryDocumentSnapshot<ScheduleModel>> data = snapshot
              .data!.docs
              .where((QueryDocumentSnapshot<ScheduleModel> schedule) =>
                  schedule.data().nextPaymentOn.difference(DateTime.now()) <=
                  const Duration(days: 14))
              .where((QueryDocumentSnapshot<ScheduleModel> schedule) =>
                  schedule.data().canceledOn?.isAfter(DateTime.now()) ?? true)
              .toList();
          data.sort(
            (
              QueryDocumentSnapshot<ScheduleModel> a,
              QueryDocumentSnapshot<ScheduleModel> b,
            ) =>
                b.data().nextPaymentOn.compareTo(a.data().nextPaymentOn),
          );

          if (data.isEmpty) {
            return Center(
              child: Text(AppLocalizations.of(context)!.emptyResultSet),
            );
          }

          return ListView.builder(
            shrinkWrap: true,
            itemCount: data.length,
            itemBuilder: (BuildContext context, int index) => ScheduleListTile(
              schedule: data[index],
            ),
          );
        }

        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}

class _LatestTransactionsCard extends StatelessWidget {
  _LatestTransactionsCard({Key? key}) : super(key: key);

  final Query<TransactionModel> _transactions = getTransactionsCollection()
      .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
      .orderBy('created_on', descending: true)
      .limit(10);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: SizedBox(
        width: getMaxWidth(context),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildHeader(context),
                _buildTransactionList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          AppLocalizations.of(context)!.latestTransactions,
          style: Theme.of(context).textTheme.subtitle1,
        ),
        IconButton(
          onPressed: () => _addTransaction(context),
          icon: const Icon(Icons.add),
          tooltip: AppLocalizations.of(context)!.addTransaction,
        ),
      ],
    );
  }

  Widget _buildTransactionList() {
    return StreamBuilder<QuerySnapshot<TransactionModel>>(
      stream: _transactions.snapshots(),
      builder: (
        BuildContext context,
        AsyncSnapshot<QuerySnapshot<TransactionModel>> snapshot,
      ) {
        if (snapshot.hasError) {
          return Center(
            child: Text(snapshot.error.toString()),
          );
        }

        if (snapshot.hasData) {
          final List<QueryDocumentSnapshot<TransactionModel>> data =
              snapshot.data!.docs;

          if (data.isEmpty) {
            return Center(
              child: Text(AppLocalizations.of(context)!.emptyResultSet),
            );
          }

          return ListView.builder(
            shrinkWrap: true,
            itemCount: data.length,
            itemBuilder: (
              BuildContext context,
              int index,
            ) =>
                TransactionListTile(
              transaction: data[index],
            ),
          );
        }

        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  void _addTransaction(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) => const AddTransactionDialog(),
    );
  }
}
