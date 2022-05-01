import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../util/custom_theme.dart';
import '../../util/validators.dart';

class EmailPasswordSignInForm extends StatefulWidget {
  const EmailPasswordSignInForm({Key? key}) : super(key: key);

  @override
  State<EmailPasswordSignInForm> createState() =>
      _EmailPasswordSignInFormState();
}

class _EmailPasswordSignInFormState extends State<EmailPasswordSignInForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _active = true;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _buildTextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            labelText: AppLocalizations.of(context)!.email,
            validator: (String? email) => _validateEmail(email),
          ),
          const SizedBox(height: 8.0),
          _buildTextFormField(
            controller: _passwordController,
            obscureText: true,
            labelText: AppLocalizations.of(context)!.password,
            validator: (String? password) => _validatePassword(password),
          ),
          const SizedBox(height: 8.0),
          ElevatedButton(
            onPressed: _active ? _submit : null,
            child: Text(
              AppLocalizations.of(context)!.signIn.toUpperCase(),
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            AppLocalizations.of(context)!.registrationIfNoLoginFoundHint,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  TextFormField _buildTextFormField({
    required TextEditingController controller,
    required String? Function(String?) validator,
    required String labelText,
    bool obscureText = false,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: obscureText,
      keyboardType: keyboardType,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: getDefaultInputDecoration(
        labelText: labelText,
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _active = false;
    });

    try {
      FirebaseAuthException? loginResult = await _attemptLogin();

      if (loginResult != null && loginResult.code == 'user-not-found') {
        final FirebaseAuthException? registrationResult =
            await _attemptRegistration();

        if (registrationResult == null) {
          loginResult = await _attemptLogin();
        } else {
          throw registrationResult;
        }
      }

      if (loginResult == null) {
        if (mounted) {
          Navigator.of(context).pop();
        }
      } else {
        throw loginResult;
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.message ?? AppLocalizations.of(context)!.unknownError,
          ),
        ),
      );
    } finally {
      setState(() {
        _active = true;
      });
    }
  }

  Future<FirebaseAuthException?> _attemptLogin() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
    } on FirebaseAuthException catch (e) {
      return e;
    }

    return null;
  }

  Future<FirebaseAuthException?> _attemptRegistration() async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
    } on FirebaseAuthException catch (e) {
      return e;
    }

    return null;
  }

  String? _validateEmail(String? email) {
    switch (validateEmail(email)) {
      case ValidationError.emptyInput:
        return AppLocalizations.of(context)!.emptyInput;
      case ValidationError.invalidEmail:
        return AppLocalizations.of(context)!.invalidEmail;
      default:
        return null;
    }
  }

  String? _validatePassword(String? password) {
    switch (validatePassword(password)) {
      case ValidationError.emptyInput:
        return AppLocalizations.of(context)!.emptyInput;
      case ValidationError.invalidPassword:
        return AppLocalizations.of(context)!.invalidPassword;
      case ValidationError.weakPassword:
        return AppLocalizations.of(context)!.weakPassword;
      default:
        return null;
    }
  }
}
