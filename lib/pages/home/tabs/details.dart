import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../models/transaction_model.dart';
import '../../../services/firebase_service.dart';
import '../../../util/custom_theme.dart';
import '../../../widgets/transaction_list_tile.dart';

class DetailsTab extends StatelessWidget {
  DetailsTab({Key? key}) : super(key: key);

  final Query<TransactionModel> _transactions = getTransactionsCollection()
      .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
      .orderBy('created_on', descending: true);

  @override
  Widget build(BuildContext context) {
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
            return ListView(
              children: <Widget>[
                const SizedBox(height: 16.0),
                _ChartsCard(
                  data: snapshot.data!.docs,
                ),
                const SizedBox(height: 16.0),
                _SummaryCard(
                  data: snapshot.data!.docs,
                ),
                const SizedBox(height: 16.0),
                _TransactionsCard(
                  data: snapshot.data!.docs,
                ),
                const SizedBox(height: 16.0),
              ],
            );
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        });
  }
}

class _ChartsCard extends StatelessWidget {
  const _ChartsCard({
    required this.data,
    Key? key,
  }) : super(key: key);

  final List<QueryDocumentSnapshot<TransactionModel>> data;

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
                _buildCharts(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Text(
      AppLocalizations.of(context)!.charts,
      style: Theme.of(context).textTheme.subtitle1,
    );
  }

  Widget _buildCharts() {
    return const Text('TODO');
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.data,
    Key? key,
  }) : super(key: key);

  final List<QueryDocumentSnapshot<TransactionModel>> data;

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
                _buildSummary(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Text(
      AppLocalizations.of(context)!.summary,
      style: Theme.of(context).textTheme.subtitle1,
    );
  }

  Widget _buildSummary() {
    return const Text('TODO');
  }
}

class _TransactionsCard extends StatelessWidget {
  const _TransactionsCard({
    required this.data,
    Key? key,
  }) : super(key: key);

  final List<QueryDocumentSnapshot<TransactionModel>> data;

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
                _buildTransactionList(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Text(
      AppLocalizations.of(context)!.transactions,
      style: Theme.of(context).textTheme.subtitle1,
    );
  }

  Widget _buildTransactionList(BuildContext context) {
    if (data.isEmpty) {
      return Center(
        child: Text(AppLocalizations.of(context)!.emptyResultSet),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: data.length,
      itemBuilder: (BuildContext context, int index) => TransactionListTile(
        transaction: data[index],
      ),
    );
  }
}
