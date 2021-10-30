import 'package:consilium/models/schedule_model.dart';
import 'package:consilium/util/custom_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ScheduleListTile extends StatelessWidget {
  final ScheduleModel schedule;

  const ScheduleListTile({
    required this.schedule,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _onClick(context),
      child: Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  CustomTheme.getIconForCategory(schedule.category),
                ),
                const SizedBox(width: 16.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(schedule.name),
                    Text(
                      DateFormat('yyyy-MM-dd').format(schedule.nextPaymentOn),
                      style: Theme.of(context).textTheme.caption,
                    ),
                  ],
                ),
              ],
            ),
            Text(
              NumberFormat.currency(
                locale: 'de',
                symbol: '€',
              ).format(schedule.signedAmountCents / 100),
              style: Theme.of(context).textTheme.bodyText1,
            ),
          ],
        ),
      ),
    );
  }

  void _onClick(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('TODO'),
      ),
    );
  }
}
