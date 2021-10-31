import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:consilium/models/category.dart';
import 'package:consilium/models/transaction_model.dart';
import 'package:consilium/util/custom_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionListTile extends StatelessWidget {
  final QueryDocumentSnapshot<TransactionModel> transaction;

  const TransactionListTile({
    required this.transaction,
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
                Icon(transaction.data().category.icon()),
                const SizedBox(width: 16.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(transaction.data().name),
                    Text(
                      CustomTheme.getDefaultDateFormat().format(
                        transaction.data().createdOn,
                      ),
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
              ).format(transaction.data().amountCents / 100),
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
