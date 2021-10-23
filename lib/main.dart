import 'package:consilium/pages/home/page.dart';
import 'package:consilium/pages/login/page.dart';
import 'package:consilium/pages/splash/page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      initialRoute: SplashPage.route,
      routes: {
        SplashPage.route: (context) => const SplashPage(),
        HomePage.route: (context) => const HomePage(),
        LoginPage.route: (context) => const LoginPage(),
      },
    );
  }
}
