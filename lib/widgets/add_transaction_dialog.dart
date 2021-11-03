import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import '../models/category.dart';
import '../models/transaction_model.dart';
import '../services/firebase_service.dart';
import '../util/custom_theme.dart';
import '../util/validators.dart';
import 'confirmation_dialog.dart';

class AddTransactionDialog extends StatefulWidget {
  const AddTransactionDialog({
    this.documentSnapshot,
    Key? key,
  })  : editMode = documentSnapshot != null,
        super(key: key);

  final bool editMode;
  final QueryDocumentSnapshot<TransactionModel>? documentSnapshot;

  @override
  State<AddTransactionDialog> createState() => AddTransactionDialogState();
}

class AddTransactionDialogState extends State<AddTransactionDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController? _amountController;
  Category? _category;
  TextEditingController? _categoryController;
  late DateTime? _createdOn;
  TextEditingController? _createdOnController;
  TextEditingController? _nameController;
  TextEditingController? _noteController;

  bool _active = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (widget.editMode) {
      _initializeWithExistingValues();
    } else {
      _initializeWithEmptyValues();
    }
  }

  void _initializeWithEmptyValues() {
    _amountController = TextEditingController();
    _categoryController = TextEditingController();
    _createdOn = DateTime.now();
    _createdOnController = TextEditingController(
      text: getDefaultDateFormat().format(DateTime.now()),
    );
    _nameController = TextEditingController();
    _noteController = TextEditingController();
  }

  void _initializeWithExistingValues() {
    final TransactionModel data = widget.documentSnapshot!.data();

    _amountController = TextEditingController(
      text: data.amount.toString(),
    );
    _category = data.category;
    _categoryController = TextEditingController(
      text: data.category.translation(context),
    );
    _createdOn = data.createdOn;
    _createdOnController = TextEditingController(
      text: getDefaultDateFormat().format(data.createdOn),
    );
    _nameController = TextEditingController(text: data.name);
    _noteController = TextEditingController(text: data.note);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.editMode
          ? AppLocalizations.of(context)!.editTransaction
          : AppLocalizations.of(context)!.addTransaction),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                controller: _createdOnController,
                decoration: getDefaultInputDecoration(
                  labelText: AppLocalizations.of(context)!.createdOn,
                ),
                onTap: _showDatePicker,
                readOnly: true,
              ),
              const SizedBox(height: 8.0),
              TextFormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                controller: _nameController,
                decoration: getDefaultInputDecoration(
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
                decoration: getDefaultInputDecoration(
                  labelText: AppLocalizations.of(context)!.amount,
                ),
                keyboardType: TextInputType.text,
                validator: _validateAmount,
              ),
              const SizedBox(height: 8.0),
              TextFormField(
                controller: _noteController,
                decoration: getDefaultInputDecoration(
                  labelText: AppLocalizations.of(context)!.note,
                ),
                keyboardType: TextInputType.text,
                maxLines: 4,
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: _cancel,
          child: Text(AppLocalizations.of(context)!.cancel.toUpperCase()),
        ),
        if (widget.editMode)
          TextButton(
            onPressed: _active ? _delete : null,
            child: Text(AppLocalizations.of(context)!.delete.toUpperCase()),
          ),
        TextButton(
          onPressed: _active ? _submit : null,
          child: Text((widget.editMode
                  ? AppLocalizations.of(context)!.edit
                  : AppLocalizations.of(context)!.add)
              .toUpperCase()),
        ),
      ],
    );
  }

  TypeAheadFormField<Category> _buildCategoryFormField() {
    return TypeAheadFormField<Category>(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      itemBuilder: (BuildContext context, Category suggestion) => ListTile(
        title: Text(suggestion.translation(context)),
      ),
      onSuggestionSelected: (Category suggestion) {
        _category = suggestion;
        _categoryController!.text = suggestion.translation(context);
      },
      suggestionsCallback: (String pattern) => Category.values.where(
        (Category category) => category
            .translation(context)
            .toLowerCase()
            .contains(pattern.trim().toLowerCase()),
      ),
      textFieldConfiguration: TextFieldConfiguration(
        controller: _categoryController,
        decoration: getDefaultInputDecoration(
          labelText: AppLocalizations.of(context)!.category,
        ),
      ),
      validator: _validateCategory,
    );
  }

  Future<void> _showDatePicker() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: _createdOn!,
      firstDate: DateTime(1900),
      lastDate: DateTime(2900),
    );

    _createdOn = date ?? DateTime.now();
    _createdOnController!.text = getDefaultDateFormat().format(
      _createdOn!,
    );
  }

  void _cancel() {
    Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final bool? deleteConfirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => ConfirmationDialog(
        title: AppLocalizations.of(context)!.confirmDeleteTransaction,
      ),
    );

    if (deleteConfirmed == null || !deleteConfirmed) {
      return;
    }

    setState(() {
      _active = false;
    });

    try {
      await getTransactionsCollection()
          .doc(widget.documentSnapshot!.id)
          .delete();
    } on FirebaseException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message.toString()),
          ),
        );
      }
    }

    setState(() {
      _active = true;
    });

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _active = false;
    });

    try {
      final TransactionModel data = TransactionModel(
        amount: double.parse(_amountController!.text),
        category: _category ?? Category.miscellaneous,
        createdOn: _createdOn!,
        name: _nameController!.text,
        uid: FirebaseAuth.instance.currentUser!.uid,
        note: _noteController!.text.isEmpty ? null : _noteController!.text,
      );

      if (widget.editMode) {
        await getTransactionsCollection()
            .doc(widget.documentSnapshot!.id)
            .update(data.toJson());
      } else {
        await getTransactionsCollection().add(data);
      }
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

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  String? _validateName(String? name) {
    switch (validateRequired(name)) {
      case ValidationError.emptyInput:
        return AppLocalizations.of(context)!.emptyInput;
      default:
        break;
    }
  }

  String? _validateCategory(String? category) {
    switch (validateRequired(category)) {
      case ValidationError.emptyInput:
        return AppLocalizations.of(context)!.emptyInput;
      default:
        break;
    }

    if (categoryFromTranslation(context, category) == null) {
      return AppLocalizations.of(context)!.invalidCategory;
    }
  }

  String? _validateAmount(String? amount) {
    switch (validateDouble(amount, signed: false)) {
      case ValidationError.emptyInput:
        return AppLocalizations.of(context)!.emptyInput;
      case ValidationError.notANumber:
        return AppLocalizations.of(context)!.notANumber;
      case ValidationError.unsignedNumberExpected:
        return AppLocalizations.of(context)!.unsignedNumberExpected;
      default:
        break;
    }
  }
}
