enum ValidationError {
  emptyInput,
  invalidEmail,
  invalidPassword,
  weakPassword,
  notANumber,
  unsignedNumberExpected
}

ValidationError? validateRequired(String? string) {
  if (string == null || string.isEmpty) {
    return ValidationError.emptyInput;
  }

  return null;
}

ValidationError? validateDouble(
  String? string, {
  bool signed = true,
}) {
  if (string == null || string.isEmpty) {
    return ValidationError.emptyInput;
  }

  final double? number = double.tryParse(string);

  if (number == null) {
    return ValidationError.notANumber;
  }

  if (!signed && number < 0) {
    return ValidationError.unsignedNumberExpected;
  }

  return null;
}

ValidationError? validateEmail(String? string) {
  if (string == null || string.isEmpty) {
    return ValidationError.emptyInput;
  }

  final RegExp regExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  if (!regExp.hasMatch(string)) {
    return ValidationError.invalidEmail;
  }

  return null;
}

ValidationError? validatePassword(String? string) {
  if (string == null || string.isEmpty) {
    return ValidationError.emptyInput;
  }

  final RegExp invalidRegExp = RegExp(r'[ ]');
  if (invalidRegExp.hasMatch(string)) {
    return ValidationError.invalidPassword;
  }

  final RegExp weakRegExp = RegExp(r'^.{6,}$');
  if (!weakRegExp.hasMatch(string)) {
    return ValidationError.weakPassword;
  }

  return null;
}
