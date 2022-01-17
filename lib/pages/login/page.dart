import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../util/custom_theme.dart';
import 'email_password_sign_in_form.dart';
import 'social_login_button.dart';

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
              const EmailPasswordSignInForm(),
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
        SocialLoginButton.google(context),
        SocialLoginButton.apple(context),
        SocialLoginButton.github(context),
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
