import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:consilium/models/category.dart';
import 'package:consilium/models/schedule_model.dart';
import 'package:consilium/util/custom_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ScheduleListTile extends StatelessWidget {
  final QueryDocumentSnapshot<ScheduleModel> schedule;

  const ScheduleListTile({
    required this.schedule,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Row(
              children: [
                Icon(schedule.data().category.icon()),
                const SizedBox(width: 16.0),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        schedule.data().name,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        CustomTheme.getDefaultDateFormat().format(
                          schedule.data().nextPaymentOn,
                        ),
                        style: Theme.of(context).textTheme.caption,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Text(
            NumberFormat.currency(
              locale: 'de',
              symbol: '€',
            ).format(schedule.data().signedAmountCents / 100),
            style: Theme.of(context).textTheme.bodyText1,
          ),
        ],
      ),
    );
  }
}
