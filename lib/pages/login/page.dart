import 'package:firebase_auth/firebase_auth.dart';
// ignore: implementation_imports
import 'package:firebase_auth_platform_interface/src/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../util/custom_theme.dart';
import '../../util/validators.dart';
import '../home/page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  static const String route = '/login';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.loginPageTitle),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: getMaxWidth(context),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _buildAuthProviderRow(context),
              const SizedBox(height: 16.0),
              _buildDivider(context),
              const SizedBox(height: 16.0),
              _SignInForm()
            ],
          ),
        ),
      ),
    );
  }

  Row _buildAuthProviderRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        _AuthProviderButton(
          authProvider: GoogleAuthProvider(),
          icon: FontAwesomeIcons.google,
          tooltip: AppLocalizations.of(context)!.signInWithGoogle,
        ),
        _AuthProviderButton(
          authProvider: GithubAuthProvider(),
          icon: FontAwesomeIcons.github,
          tooltip: AppLocalizations.of(context)!.signInWithGitHub,
        ),
      ],
    );
  }

  Row _buildDivider(BuildContext context) {
    return Row(
      children: <Widget>[
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            AppLocalizations.of(context)!.or.toUpperCase(),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}

class _AuthProviderButton extends StatefulWidget {
  const _AuthProviderButton({
    required this.authProvider,
    required this.icon,
    required this.tooltip,
  });

  final AuthProvider authProvider;
  final IconData icon;
  final String tooltip;

  @override
  State<_AuthProviderButton> createState() => _AuthProviderButtonState();
}

class _AuthProviderButtonState extends State<_AuthProviderButton> {
  bool _active = true;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: _active ? _startAuth : null,
      icon: Icon(widget.icon),
      tooltip: widget.tooltip,
    );
  }

  Future<void> _startAuth() async {
    setState(() {
      _active = false;
    });

    try {
      await FirebaseAuth.instance.signInWithPopup(widget.authProvider);

      if (mounted) {
        Navigator.of(context).pushReplacementNamed(HomePage.route);
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.message ?? AppLocalizations.of(context)!.unknownError,
          ),
        ),
      );
    }

    setState(() {
      _active = true;
    });
  }
}

class _SignInForm extends StatefulWidget {
  @override
  State<_SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<_SignInForm> {
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
    }

    setState(() {
      _active = true;
    });
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
        break;
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
        break;
    }
  }
}
