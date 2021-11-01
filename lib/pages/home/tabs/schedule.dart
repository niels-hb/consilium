import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../models/schedule_model.dart';
import '../../../services/firebase_service.dart';
import '../../../util/custom_theme.dart';
import '../../../widgets/add_schedule_dialog.dart';
import '../../../widgets/schedule_list_tile.dart';

class ScheduleTab extends StatelessWidget {
  ScheduleTab({Key? key}) : super(key: key);

  final Query<ScheduleModel> _schedules = getSchedulesCollection()
      .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid);

  @override
  Widget build(BuildContext context) {
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
              _ScheduleListCard(
                data: snapshot.data!.docs,
              ),
            ],
          );
        }

        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}

class _ChartsCard extends StatelessWidget {
  const _ChartsCard({
    required this.data,
    Key? key,
  }) : super(key: key);

  final List<QueryDocumentSnapshot<ScheduleModel>> data;

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

  final List<QueryDocumentSnapshot<ScheduleModel>> data;

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

class _ScheduleListCard extends StatelessWidget {
  const _ScheduleListCard({
    required this.data,
    Key? key,
  }) : super(key: key);

  final List<QueryDocumentSnapshot<ScheduleModel>> data;

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
                _buildScheduleList(context),
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
          AppLocalizations.of(context)!.scheduledPayments,
          style: Theme.of(context).textTheme.subtitle1,
        ),
        IconButton(
          onPressed: () => _addSchedule(context),
          icon: const Icon(Icons.add),
          tooltip: AppLocalizations.of(context)!.addTransaction,
        ),
      ],
    );
  }

  Widget _buildScheduleList(BuildContext context) {
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
        compact: false,
      ),
    );
  }

  void _addSchedule(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) => const AddScheduleDialog(),
    );
  }
}
