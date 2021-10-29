import 'package:consilium/models/category.dart';
import 'package:consilium/models/transaction_model.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class TransactionListTile extends StatelessWidget {
  final TransactionModel transaction;

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
                Icon(_getIconForCategory()),
                const SizedBox(width: 16.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(transaction.name),
                    Text(
                      DateFormat('yyyy-MM-dd').format(transaction.createdOn),
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
              ).format(transaction.amountCents / 100),
              style: Theme.of(context).textTheme.bodyText1,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForCategory() {
    switch (transaction.category) {
      case Category.fitness:
        return Icons.fitness_center;
      case Category.food:
        return Icons.fastfood;
      case Category.housing:
        return Icons.house;
      case Category.insurance:
        return FontAwesomeIcons.umbrella;
      case Category.medical:
        return Icons.medication;
      case Category.miscellaneous:
        return Icons.miscellaneous_services;
      case Category.hygiene:
        return Icons.soap;
      case Category.recreation:
        return Icons.gamepad;
      case Category.subscriptions:
        return Icons.subscriptions;
      case Category.transportation:
        return Icons.train;
      case Category.utilities:
        return Icons.power;
    }
  }

  void _onClick(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('TODO'),
      ),
    );
  }
}
