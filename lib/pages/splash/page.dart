import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../home/page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  static const String route = '/';

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

    if (mounted) {
      Navigator.of(context).pushReplacementNamed(HomePage.route);
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
