import 'package:flutter/material.dart';

class SplashPage extends StatelessWidget {
  static const String route = '/splash';

  const SplashPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
