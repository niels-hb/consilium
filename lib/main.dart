import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'pages/home/page.dart';
import 'pages/login/page.dart';
import 'pages/splash/page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Consilium',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      initialRoute: SplashPage.route,
      routes: <String, Widget Function(BuildContext)>{
        SplashPage.route: (BuildContext context) => const SplashPage(),
        HomePage.route: (BuildContext context) => const HomePage(),
        LoginPage.route: (BuildContext context) => const LoginPage(),
      },
    );
  }
}
