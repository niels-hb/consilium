enum EmailValidationError { emptyInput, invalidEmail }
enum PasswordValidationError { emptyInput, invalidPassword, weakPassword }

class Validators {
  static EmailValidationError? email(String? string) {
    if (string == null || string.isEmpty) {
      return EmailValidationError.emptyInput;
    }

    final regExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regExp.hasMatch(string)) {
      return EmailValidationError.invalidEmail;
    }

    return null;
  }

  static PasswordValidationError? password(String? string) {
    if (string == null || string.isEmpty) {
      return PasswordValidationError.emptyInput;
    }

    final invalidRegExp = RegExp(r'[ ]');
    if (invalidRegExp.hasMatch(string)) {
      return PasswordValidationError.invalidPassword;
    }

    final weakRegExp = RegExp(r'^.{6,}$');
    if (!weakRegExp.hasMatch(string)) {
      return PasswordValidationError.weakPassword;
    }

    return null;
  }
}
