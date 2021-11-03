import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';

import '../models/category.dart';
import '../models/schedule_model.dart';
import '../models/schedule_type.dart';
import '../services/firebase_service.dart';
import '../util/custom_theme.dart';
import '../util/formatter.dart';
import '../util/validators.dart';
import 'confirmation_dialog.dart';

class AddScheduleDialog extends StatefulWidget {
  const AddScheduleDialog({
    this.documentSnapshot,
    Key? key,
  })  : editMode = documentSnapshot != null,
        super(key: key);

  final bool editMode;
  final QueryDocumentSnapshot<ScheduleModel>? documentSnapshot;

  @override
  State<AddScheduleDialog> createState() => AddScheduleDialogState();
}

class AddScheduleDialogState extends State<AddScheduleDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController? _amountController;
  Category? _category;
  TextEditingController? _categoryController;
  DateTime? _createdOn;
  TextEditingController? _createdOnController;
  TextEditingController? _frequencyMonthsController;
  TextEditingController? _nameController;
  DateTime? _startedOn;
  TextEditingController? _startedOnController;
  DateTime? _canceledOn;
  TextEditingController? _canceledOnController;
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
    _frequencyMonthsController = TextEditingController(text: '1');
    _nameController = TextEditingController();
    _startedOn = DateTime.now();
    _startedOnController = TextEditingController(
      text: getDefaultDateFormat().format(DateTime.now()),
    );
    _canceledOnController = TextEditingController();
    _noteController = TextEditingController();
  }

  void _initializeWithExistingValues() {
    final ScheduleModel data = widget.documentSnapshot!.data();

    _amountController = TextEditingController(
      text: data.signedAmount.toString(),
    );
    _category = data.category;
    _categoryController = TextEditingController(
      text: data.category.translation(context),
    );
    _createdOn = data.createdOn;
    _createdOnController = TextEditingController(
      text: getDefaultDateFormat().format(data.createdOn),
    );
    _frequencyMonthsController = TextEditingController(
      text: data.frequencyMonths.toString(),
    );
    _nameController = TextEditingController(
      text: data.name,
    );
    _startedOn = data.startedOn;
    _startedOnController = TextEditingController(
      text: getDefaultDateFormat().format(data.startedOn),
    );
    _canceledOn = data.canceledOn;
    _canceledOnController = TextEditingController(
      text: data.canceledOn == null
          ? ''
          : getDefaultDateFormat().format(data.canceledOn!),
    );
    _noteController = TextEditingController(
      text: data.note,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.editMode
          ? AppLocalizations.of(context)!.editSchedule
          : AppLocalizations.of(context)!.addSchedule),
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
                onTap: () => _showDatePicker(
                  initialDate: _createdOn,
                  onResult: (DateTime? date) {
                    _createdOn = date ?? DateTime.now();
                    _createdOnController!.text = getDefaultDateFormat().format(
                      _createdOn!,
                    );
                  },
                ),
                readOnly: true,
              ),
              const SizedBox(height: 8.0),
              TextFormField(
                controller: _startedOnController,
                decoration: getDefaultInputDecoration(
                  labelText: AppLocalizations.of(context)!.startedOn,
                ),
                onTap: () => _showDatePicker(
                  initialDate: _startedOn,
                  onResult: (DateTime? date) {
                    _startedOn = date ?? DateTime.now();
                    _startedOnController!.text = getDefaultDateFormat().format(
                      _startedOn!,
                    );
                  },
                ),
                readOnly: true,
              ),
              const SizedBox(height: 8.0),
              TextFormField(
                controller: _canceledOnController,
                decoration: getDefaultInputDecoration(
                  labelText: AppLocalizations.of(context)!.canceledOn,
                ),
                onTap: () => _showDatePicker(
                  initialDate: _canceledOn,
                  onResult: (DateTime? date) {
                    if (date == null) {
                      return;
                    }

                    _canceledOn = date;
                    _canceledOnController!.text = getDefaultDateFormat().format(
                      _canceledOn!,
                    );
                  },
                ),
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
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                validator: _validateAmount,
              ),
              const SizedBox(height: 8.0),
              TextFormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                controller: _frequencyMonthsController,
                decoration: getDefaultInputDecoration(
                  labelText: AppLocalizations.of(context)!.frequencyMonths,
                ),
                keyboardType: TextInputType.number,
                validator: _validateFrequencyMonths,
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

  Future<void> _showDatePicker({
    required DateTime? initialDate,
    required void Function(DateTime?) onResult,
  }) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2900),
    );

    onResult(date);
  }

  void _cancel() {
    Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final bool? deleteConfirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => ConfirmationDialog(
        title: AppLocalizations.of(context)!.confirmDeleteSchedule,
      ),
    );

    if (deleteConfirmed == null || !deleteConfirmed) {
      return;
    }

    setState(() {
      _active = false;
    });

    try {
      await getSchedulesCollection().doc(widget.documentSnapshot!.id).delete();
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
      final double _amount = NumberFormat().tryParse(_amountController!.text)!;

      final ScheduleModel data = ScheduleModel(
        amount: _amount.abs(),
        category: _category ?? Category.miscellaneous,
        createdOn: _createdOn!,
        frequencyMonths: int.parse(_frequencyMonthsController!.text),
        name: _nameController!.text,
        startedOn: _startedOn!,
        type: _amount < 0 ? ScheduleType.outgoing : ScheduleType.incoming,
        uid: FirebaseAuth.instance.currentUser!.uid,
        canceledOn: _canceledOn,
        note: _noteController!.text.isEmpty ? null : _noteController!.text,
      );

      if (widget.editMode) {
        await getSchedulesCollection()
            .doc(widget.documentSnapshot!.id)
            .update(data.toJson());
      } else {
        await getSchedulesCollection().add(data);
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
    switch (validateDouble(amount, min: 0.01)) {
      case ValidationError.emptyInput:
        return AppLocalizations.of(context)!.emptyInput;
      case ValidationError.notANumber:
        return AppLocalizations.of(context)!.notANumber;
      case ValidationError.unsignedNumberExpected:
        return AppLocalizations.of(context)!.unsignedNumberExpected;
      case ValidationError.numberLessThanMin:
        return AppLocalizations.of(context)!.numberNotGreaterThanZero;
      default:
        break;
    }
  }

  String? _validateFrequencyMonths(String? frequencyMonths) {
    switch (validateInt(frequencyMonths, signed: false, min: 1)) {
      case ValidationError.emptyInput:
        return AppLocalizations.of(context)!.emptyInput;
      case ValidationError.notANumber:
        return AppLocalizations.of(context)!.notANumber;
      case ValidationError.unsignedNumberExpected:
        return AppLocalizations.of(context)!.unsignedNumberExpected;
      case ValidationError.numberLessThanMin:
        return AppLocalizations.of(context)!.numberNotGreaterThanZero;
      default:
        break;
    }
  }
}
