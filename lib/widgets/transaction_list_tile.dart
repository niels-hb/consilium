import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:consilium/models/category.dart';
import 'package:consilium/models/transaction_model.dart';
import 'package:consilium/util/custom_theme.dart';
import 'package:consilium/widgets/add_transaction_dialog.dart';
import 'package:flutter/material.dart';

class TransactionListTile extends StatelessWidget {
  final QueryDocumentSnapshot<TransactionModel> transaction;

  const TransactionListTile({
    required this.transaction,
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
                Icon(transaction.data().category.icon()),
                const SizedBox(width: 16.0),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.data().name,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        CustomTheme.getDefaultDateFormat().format(
                          transaction.data().createdOn,
                        ),
                        style: Theme.of(context).textTheme.caption,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Text(
                CustomTheme.getDefaultNumberFormat().format(
                  transaction.data().amountCents / 100,
                ),
                style: Theme.of(context).textTheme.bodyText1,
              ),
              IconButton(
                onPressed: () => _edit(context),
                icon: const Icon(Icons.edit),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _edit(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddTransactionDialog(
        documentSnapshot: transaction,
      ),
    );
  }
}
