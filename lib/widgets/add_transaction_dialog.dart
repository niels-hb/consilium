import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:consilium/models/category.dart';
import 'package:consilium/models/transaction_model.dart';
import 'package:consilium/services/firebase_service.dart';
import 'package:consilium/util/custom_theme.dart';
import 'package:consilium/util/validators.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class AddTransactionDialog extends StatefulWidget {
  const AddTransactionDialog({Key? key}) : super(key: key);

  @override
  State<AddTransactionDialog> createState() => AddTransactionDialogState();
}

class AddTransactionDialogState extends State<AddTransactionDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  Category? _category;
  final TextEditingController _categoryController = TextEditingController();
  DateTime _createdOn = DateTime.now();
  final TextEditingController _createdOnController = TextEditingController(
    text: CustomTheme.getDefaultDateFormat().format(DateTime.now()),
  );
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  bool _active = true;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.addTransaction),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _createdOnController,
              decoration: CustomTheme.getDefaultInputDecoration(
                labelText: AppLocalizations.of(context)!.createdOn,
              ),
              onTap: _showDatePicker,
              readOnly: true,
            ),
            const SizedBox(height: 8.0),
            TextFormField(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              controller: _nameController,
              decoration: CustomTheme.getDefaultInputDecoration(
                labelText: AppLocalizations.of(context)!.name,
              ),
              keyboardType: TextInputType.text,
              validator: _validateName,
            ),
            const SizedBox(height: 8.0),
            _buildCategoryFormField(),
            const SizedBox(height: 8.0),
            TextFormField(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              controller: _amountController,
              decoration: CustomTheme.getDefaultInputDecoration(
                labelText: AppLocalizations.of(context)!.amount,
              ),
              keyboardType: const TextInputType.numberWithOptions(
                signed: false,
                decimal: true,
              ),
              validator: _validateName,
            ),
            const SizedBox(height: 8.0),
            TextFormField(
              controller: _noteController,
              decoration: CustomTheme.getDefaultInputDecoration(
                labelText: AppLocalizations.of(context)!.note,
              ),
              keyboardType: TextInputType.text,
              maxLines: 4,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _cancel,
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        TextButton(
          onPressed: _active ? _submit : null,
          child: Text(AppLocalizations.of(context)!.add),
        ),
      ],
    );
  }

  TypeAheadFormField _buildCategoryFormField() {
    return TypeAheadFormField<Category>(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      itemBuilder: (BuildContext context, Category suggestion) => ListTile(
        title: Text(suggestion.translation(context)),
      ),
      onSuggestionSelected: (Category suggestion) {
        _category = suggestion;
        _categoryController.text = suggestion.translation(context);
      },
      suggestionsCallback: (pattern) => Category.values.where(
        (category) => category
            .translation(context)
            .toLowerCase()
            .contains(pattern.trim().toLowerCase()),
      ),
      textFieldConfiguration: TextFieldConfiguration(
        controller: _categoryController,
        decoration: CustomTheme.getDefaultInputDecoration(
          labelText: AppLocalizations.of(context)!.category,
        ),
        keyboardType: TextInputType.text,
      ),
      validator: _validateCategory,
    );
  }

  void _showDatePicker() async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: _createdOn,
      firstDate: DateTime(1900),
      lastDate: DateTime(2900),
    );

    _createdOn = date ?? DateTime.now();
    _createdOnController.text = CustomTheme.getDefaultDateFormat().format(
      _createdOn,
    );
  }

  void _cancel() {
    Navigator.of(context).pop();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _active = false;
    });

    try {
      await FirebaseService.getTransactionsCollection().add(
        TransactionModel(
          amountCents: (double.parse(_amountController.text) * 100).round(),
          category: _category ?? Category.miscellaneous,
          createdOn: _createdOn,
          name: _nameController.text,
          uid: FirebaseAuth.instance.currentUser!.uid,
          note: _noteController.text.isEmpty ? null : _noteController.text,
        ),
      );
    } on FirebaseException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message.toString()),
        ),
      );
    }

    setState(() {
      _active = true;
    });

    Navigator.of(context).pop();
  }

  String? _validateName(String? name) {
    switch (Validators.required(name)) {
      case ValidationError.emptyInput:
        return AppLocalizations.of(context)!.emptyInput;
      default:
        break;
    }
  }

  String? _validateCategory(String? category) {
    switch (Validators.required(category)) {
      case ValidationError.emptyInput:
        return AppLocalizations.of(context)!.emptyInput;
      default:
        break;
    }

    if (CategoryHelper.fromTranslation(context, category) == null) {
      return AppLocalizations.of(context)!.invalidCategory;
    }
  }
}
