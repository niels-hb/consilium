import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../models/category.dart';
import '../models/schedule_model.dart';
import '../util/custom_theme.dart';

class ScheduleListTile extends StatelessWidget {
  ScheduleListTile({
    required this.schedule,
    this.compact = true,
    Key? key,
  })  : data = schedule.data(),
        super(key: key);

  final QueryDocumentSnapshot<ScheduleModel> schedule;
  final ScheduleModel data;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations loc = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Flexible(
            child: Row(
              children: <Widget>[
                Icon(data.category.icon()),
                const SizedBox(width: 16.0),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        data.name,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4.0),
                      _buildCaptionText(
                        context,
                        _formatDateWithPrefix(
                          prefix: loc.nextPayment,
                          date: data.nextPaymentOn,
                        ),
                      ),
                      if (!compact) ...<Widget>[
                        _buildCaptionText(
                          context,
                          _formatDateWithPrefix(
                            prefix: loc.startedOn,
                            date: data.startedOn,
                          ),
                        ),
                        _buildCaptionText(
                          context,
                          _formatDateWithPrefix(
                            prefix: loc.createdOn,
                            date: data.createdOn,
                          ),
                        ),
                        if (data.canceledOn != null)
                          _buildCaptionText(
                            context,
                            _formatDateWithPrefix(
                              prefix: loc.canceledOn,
                              date: data.canceledOn!,
                            ),
                          ),
                      ]
                    ],
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              _buildAmountText(
                context,
                amount: data.signedAmountCents / 100,
                interval: data.frequencyMonths,
              ),
              if (!compact) ...<Widget>[
                const SizedBox(height: 4.0),
                _buildAmountText(
                  context,
                  amount: data.signedMonthlyAmountCents / 100,
                ),
              ]
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCaptionText(BuildContext context, String text) => Text(
        text,
        style: Theme.of(context).textTheme.caption,
      );

  String _formatDateWithPrefix({
    required String prefix,
    required DateTime date,
  }) =>
      '$prefix: ${getDefaultDateFormat().format(date)}';

  Widget _buildAmountText(
    BuildContext context, {
    required double amount,
    int interval = 1,
  }) =>
      Text(
        _formatCurrencyWithInterval(
          amount: amount,
          interval: interval,
          intervalName: AppLocalizations.of(context)!.monthAbbreviated,
        ),
        style: Theme.of(context).textTheme.bodyText1,
      );

  String _formatCurrencyWithInterval({
    required double amount,
    required String intervalName,
    int interval = 1,
  }) {
    String suffix = intervalName;

    if (interval > 1) {
      suffix = '$interval $intervalName';
    }

    return '${getDefaultNumberFormat().format(amount)}/$suffix';
  }
}
