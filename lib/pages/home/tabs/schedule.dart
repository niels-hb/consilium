import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../../../models/category.dart';
import '../../../models/schedule_model.dart';
import '../../../models/schedule_type.dart';
import '../../../services/firebase_service.dart';
import '../../../util/custom_theme.dart';
import '../../../widgets/add_schedule_dialog.dart';
import '../../../widgets/schedule_list_tile.dart';

Map<Category, double> getAmountPerCategory(
  List<QueryDocumentSnapshot<ScheduleModel>> data,
) {
  final Map<Category, double> categories = <Category, double>{};

  data
      .where(
        (QueryDocumentSnapshot<ScheduleModel> snapshot) =>
            snapshot.data().type == ScheduleType.outgoing,
      )
      .map((QueryDocumentSnapshot<ScheduleModel> snaphot) => snaphot.data())
      .forEach((ScheduleModel schedule) {
    categories.update(
      schedule.category,
      (double value) => value += schedule.monthlyAmount,
      ifAbsent: () => schedule.monthlyAmount,
    );
  });

  return categories;
}

Map<ScheduleType, double> getAmountPerType(
  List<QueryDocumentSnapshot<ScheduleModel>> data,
) {
  final Map<ScheduleType, double> types = <ScheduleType, double>{};

  data
      .map((QueryDocumentSnapshot<ScheduleModel> snaphot) => snaphot.data())
      .forEach((ScheduleModel schedule) {
    types.update(
      schedule.type,
      (double value) => value += schedule.monthlyAmount,
      ifAbsent: () => schedule.monthlyAmount,
    );
  });

  return types;
}

class ScheduleTab extends StatelessWidget {
  ScheduleTab({Key? key}) : super(key: key);

  final Query<ScheduleModel> _schedules = getSchedulesCollection()
      .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
      .orderBy('amount_cents', descending: true);

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
              const SizedBox(height: 16.0),
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

class _ChartsCard extends StatefulWidget {
  _ChartsCard({
    required List<QueryDocumentSnapshot<ScheduleModel>> data,
    Key? key,
  })  : data = data
            .where((QueryDocumentSnapshot<ScheduleModel> snapshot) =>
                snapshot.data().active)
            .toList(),
        super(key: key);

  final List<QueryDocumentSnapshot<ScheduleModel>> data;

  @override
  State<_ChartsCard> createState() => _ChartsCardState();
}

class _ChartsCardState extends State<_ChartsCard> {
  int _currentPage = 0;

  List<Widget> get _pages => <Widget>[
        _pieChartByCategory(),
        _pieChartByType(),
      ];

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
    return Column(
      children: <Widget>[
        AspectRatio(
          aspectRatio: 1,
          child: PageView(
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            children: _pages,
          ),
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 25.0),
          child: _PageViewIndicator(
            page: _currentPage,
            totalPages: _pages.length,
          ),
        ),
      ],
    );
  }

  Widget _pieChartByCategory() {
    final Map<Category, double> categories = getAmountPerCategory(widget.data);

    if (categories.isEmpty) {
      return Center(
        child: Text(AppLocalizations.of(context)!.emptyResultSet),
      );
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) => PieChart(
        PieChartData(
          centerSpaceRadius: 0,
          sections: <PieChartSectionData>[
            for (MapEntry<Category, double> mapEntry in categories.entries)
              PieChartSectionData(
                value: mapEntry.value,
                title: getDefaultNumberFormat().format(mapEntry.value),
                radius: (constraints.maxWidth / 2) - 32.0,
                color: mapEntry.key.color(),
                badgeWidget: DecoratedBox(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: <BoxShadow>[
                      BoxShadow(blurRadius: 4.0),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Icon(mapEntry.key.icon()),
                  ),
                ),
                badgePositionPercentageOffset: 1.0,
              ),
          ],
        ),
      ),
    );
  }

  Widget _pieChartByType() {
    final Map<ScheduleType, double> types = getAmountPerType(widget.data);

    if (types.length != 2) {
      return Center(
        child: Text(AppLocalizations.of(context)!.emptyResultSet),
      );
    }

    final double expenses = (types[ScheduleType.outgoing] ?? 0) /
        (types[ScheduleType.incoming] ?? 0);
    final double income = 1 - expenses;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) => PieChart(
        PieChartData(
          centerSpaceRadius: 0,
          sections: <PieChartSectionData>[
            _getPieChartSectionDataForType(
              value: types[ScheduleType.incoming] ?? 0,
              percentage: income,
              color: Colors.green,
              constraints: constraints,
            ),
            _getPieChartSectionDataForType(
              value: types[ScheduleType.outgoing] ?? 0,
              percentage: expenses,
              color: Colors.orange,
              constraints: constraints,
            ),
          ],
        ),
      ),
    );
  }

  PieChartSectionData _getPieChartSectionDataForType({
    required double value,
    required double percentage,
    required Color color,
    required BoxConstraints constraints,
  }) =>
      PieChartSectionData(
        value: percentage.clamp(0, 1),
        title:
            '${NumberFormat.percentPattern().format(percentage)} (${getDefaultNumberFormat().format(value)})',
        radius: (constraints.maxWidth / 2) - 32.0,
        color: color,
      );
}

class _PageViewIndicator extends StatelessWidget {
  const _PageViewIndicator({
    required this.page,
    required this.totalPages,
  });

  final int page;
  final int totalPages;

  double get _radius => 8.0;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        for (int i = 0; i < totalPages; i++)
          Container(
            width: _radius,
            height: _radius,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: page == i ? Colors.black : Colors.transparent,
              border: Border.all(),
            ),
          ),
      ],
    );
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
                const SizedBox(height: 8.0),
                _buildSummary(context),
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

  Widget _buildSummary(BuildContext context) {
    final Map<ScheduleType, double> types = getAmountPerType(data);

    final int activeSchedules = data
        .where(
          (QueryDocumentSnapshot<ScheduleModel> snapshot) =>
              snapshot.data().active,
        )
        .toList()
        .length;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(AppLocalizations.of(context)!.income),
            const SizedBox(height: 4.0),
            Text(AppLocalizations.of(context)!.expenses),
            const SizedBox(height: 4.0),
            Text(AppLocalizations.of(context)!.scheduledPayments),
            const SizedBox(height: 4.0),
            Text(AppLocalizations.of(context)!.activeToInactiveSchedules),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Text(
              getDefaultNumberFormat().format(
                types.containsKey(ScheduleType.incoming)
                    ? types[ScheduleType.incoming]
                    : 0,
              ),
            ),
            const SizedBox(height: 4.0),
            Text(
              getDefaultNumberFormat().format(
                types.containsKey(ScheduleType.outgoing)
                    ? types[ScheduleType.outgoing]
                    : 0,
              ),
            ),
            const SizedBox(height: 4.0),
            Text(data.length.toString()),
            const SizedBox(height: 4.0),
            Text('$activeSchedules/${data.length - activeSchedules}'),
          ],
        ),
      ],
    );
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
      physics: const NeverScrollableScrollPhysics(),
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
