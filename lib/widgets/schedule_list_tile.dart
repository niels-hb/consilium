import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/category.dart';
import '../models/schedule_model.dart';
import '../util/custom_theme.dart';

class ScheduleListTile extends StatelessWidget {
  const ScheduleListTile({
    required this.schedule,
    Key? key,
  }) : super(key: key);

  final QueryDocumentSnapshot<ScheduleModel> schedule;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Flexible(
            child: Row(
              children: <Widget>[
                Icon(schedule.data().category.icon()),
                const SizedBox(width: 16.0),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        schedule.data().name,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        getDefaultDateFormat().format(
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
            getDefaultNumberFormat().format(
              schedule.data().signedAmountCents / 100,
            ),
            style: Theme.of(context).textTheme.bodyText1,
          ),
        ],
      ),
    );
  }
}
