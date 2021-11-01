import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../models/category.dart';
import '../models/transaction_model.dart';
import '../util/custom_theme.dart';
import 'add_transaction_dialog.dart';

class TransactionListTile extends StatelessWidget {
  const TransactionListTile({
    required this.transaction,
    Key? key,
  }) : super(key: key);

  final QueryDocumentSnapshot<TransactionModel> transaction;

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
                Icon(transaction.data().category.icon()),
                const SizedBox(width: 16.0),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        transaction.data().name,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        getDefaultDateFormat().format(
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
            children: <Widget>[
              Text(
                getDefaultNumberFormat().format(
                  transaction.data().amountCents / 100,
                ),
                style: Theme.of(context).textTheme.bodyText1,
              ),
              IconButton(
                onPressed: () => _edit(context),
                icon: const Icon(Icons.edit),
                tooltip: AppLocalizations.of(context)!.edit,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _edit(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) => AddTransactionDialog(
        documentSnapshot: transaction,
      ),
    );
  }
}
