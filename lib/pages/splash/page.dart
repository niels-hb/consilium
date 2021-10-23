import 'package:consilium/pages/home/page.dart';
import 'package:consilium/pages/login/page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

enum _LoginState { notLoggedIn, loggedIn }

class SplashPage extends StatefulWidget {
  static const String route = '/splash';

  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();

    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await Firebase.initializeApp();

    switch (_checkLoginState()) {
      case _LoginState.notLoggedIn:
        Navigator.of(context).pushReplacementNamed(LoginPage.route);
        break;
      case _LoginState.loggedIn:
        Navigator.of(context).pushReplacementNamed(HomePage.route);
        break;
    }
  }

  _LoginState _checkLoginState() {
    if (FirebaseAuth.instance.currentUser == null) {
      return _LoginState.notLoggedIn;
    } else {
      return _LoginState.loggedIn;
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
