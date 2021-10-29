enum ValidationError { emptyInput, invalidEmail, invalidPassword, weakPassword }

class Validators {
  static ValidationError? required(String? string) {
    if (string == null || string.isEmpty) {
      return ValidationError.emptyInput;
    }

    return null;
  }

  static ValidationError? email(String? string) {
    if (string == null || string.isEmpty) {
      return ValidationError.emptyInput;
    }

    final regExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regExp.hasMatch(string)) {
      return ValidationError.invalidEmail;
    }

    return null;
  }

  static ValidationError? password(String? string) {
    if (string == null || string.isEmpty) {
      return ValidationError.emptyInput;
    }

    final invalidRegExp = RegExp(r'[ ]');
    if (invalidRegExp.hasMatch(string)) {
      return ValidationError.invalidPassword;
    }

    final weakRegExp = RegExp(r'^.{6,}$');
    if (!weakRegExp.hasMatch(string)) {
      return ValidationError.weakPassword;
    }

    return null;
  }
}
