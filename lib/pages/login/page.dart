import 'package:consilium/pages/home/page.dart';
import 'package:consilium/util/validators.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginPage extends StatelessWidget {
  static const String route = '/login';

  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.loginPageTitle),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 0.8 * MediaQuery.of(context).size.width,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
      children: [
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
  final dynamic authProvider;
  final IconData icon;
  final String tooltip;

  const _AuthProviderButton({
    required this.authProvider,
    required this.icon,
    required this.tooltip,
  });

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

  void _startAuth() async {
    setState(() {
      _active = false;
    });

    try {
      await FirebaseAuth.instance.signInWithPopup(widget.authProvider);

      Navigator.of(context).pushReplacementNamed(HomePage.route);
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
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _active = true;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTextFormField(
            controller: _emailController,
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
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: obscureText,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
      ),
    );
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _active = false;
    });

    // TODO
    await Future.delayed(const Duration(seconds: 1));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Not implemented yet!')),
    );

    setState(() {
      _active = true;
    });
  }

  String? _validateEmail(String? email) {
    switch (Validators.email(email)) {
      case EmailValidationError.emptyInput:
        return AppLocalizations.of(context)!.emptyInput;
      case EmailValidationError.invalidEmail:
        return AppLocalizations.of(context)!.invalidEmail;
      case null:
        break;
    }
  }

  String? _validatePassword(String? password) {
    switch (Validators.password(password)) {
      case PasswordValidationError.emptyInput:
        return AppLocalizations.of(context)!.emptyInput;
      case PasswordValidationError.invalidPassword:
        return AppLocalizations.of(context)!.invalidPassword;
      case PasswordValidationError.weakPassword:
        return AppLocalizations.of(context)!.weakPassword;
      case null:
        break;
    }
  }
}
