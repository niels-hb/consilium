import 'package:consilium/pages/login/page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomePage extends StatelessWidget {
  static const String route = '/home';

  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.appName),
      ),
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasData) {
            return Center(
              child: Text(
                'Welcome ${snapshot.data!.email}!',
              ),
            );
          }

          return Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed(LoginPage.route);
              },
              child: Text(AppLocalizations.of(context)!.signIn),
            ),
          );
        },
      ),
    );
  }
}
