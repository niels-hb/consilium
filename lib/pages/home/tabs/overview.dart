import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:consilium/models/transaction_model.dart';
import 'package:consilium/services/firebase_service.dart';
import 'package:consilium/util/custom_theme.dart';
import 'package:consilium/widgets/add_transaction_dialog.dart';
import 'package:consilium/widgets/transaction_list_tile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class OverviewTab extends StatelessWidget {
  const OverviewTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(height: 16.0),
        const _MonthToDateCard(),
        const SizedBox(height: 16.0),
        const _UpcomingPaymentsCard(),
        const SizedBox(height: 16.0),
        _LatestTransactionsCard(),
      ],
    );
  }
}

class _MonthToDateCard extends StatelessWidget {
  const _MonthToDateCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: CustomTheme.getMaxWidth(context),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.monthToDate,
                  style: Theme.of(context).textTheme.caption,
                ),
                const SizedBox(height: 8.0),
                Text(
                  'TODO',
                  style: Theme.of(context).textTheme.subtitle1,
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
  const _UpcomingPaymentsCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: SizedBox(
        width: CustomTheme.getMaxWidth(context),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
    return const Text('TODO');
  }
}

class _LatestTransactionsCard extends StatelessWidget {
  final Query<TransactionModel> _transactions =
      FirebaseService.getTransactionsCollection()
          .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .orderBy('created_on', descending: true)
          .limit(10);

  _LatestTransactionsCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: SizedBox(
        width: CustomTheme.getMaxWidth(context),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
      children: [
        Text(
          AppLocalizations.of(context)!.latestTransactions,
          style: Theme.of(context).textTheme.subtitle1,
        ),
        IconButton(
          onPressed: () => _addTransaction(context),
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }

  Widget _buildTransactionList() {
    return StreamBuilder<QuerySnapshot<TransactionModel>>(
      stream: _transactions.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(snapshot.error.toString()),
          );
        }

        if (snapshot.hasData) {
          List<QueryDocumentSnapshot<TransactionModel>> data =
              snapshot.data!.docs;

          return ListView.builder(
            shrinkWrap: true,
            itemCount: data.length,
            itemBuilder: (context, index) => TransactionListTile(
              transaction: data[index].data(),
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
    showDialog(
      context: context,
      builder: (context) => const AddTransactionDialog(),
    );
  }
}
