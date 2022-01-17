import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'firebase_options.dart';
import 'pages/home/page.dart';
import 'pages/login/page.dart';

Future<void> main() async {
  if (!kIsWeb) {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Consilium',
      theme: ThemeData(),
      darkTheme: ThemeData.dark(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      initialRoute: HomePage.route,
      routes: <String, Widget Function(BuildContext)>{
        HomePage.route: (BuildContext context) => const HomePage(),
        LoginPage.route: (BuildContext context) => const LoginPage(),
      },
    );
  }
}
