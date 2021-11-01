import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../login/page.dart';
import 'tabs/details.dart';
import 'tabs/overview.dart';
import 'tabs/schedule.dart';

class _TabDefinition {
  const _TabDefinition({
    required this.content,
    required this.bottomNavigationBarItem,
  });

  final Widget content;
  final BottomNavigationBarItem bottomNavigationBarItem;
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  static const String route = '/home';

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: Text(AppLocalizations.of(context)!.appName),
            ),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasData) {
          return const _LoggedInPage();
        }

        return const _LoggedOutPage();
      },
    );
  }
}

class _LoggedOutPage extends StatelessWidget {
  const _LoggedOutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.appName),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _signIn(context),
          child: Text(AppLocalizations.of(context)!.signIn.toUpperCase()),
        ),
      ),
    );
  }

  void _signIn(BuildContext context) {
    Navigator.of(context).pushNamed(LoginPage.route);
  }
}

class _LoggedInPage extends StatefulWidget {
  const _LoggedInPage({Key? key}) : super(key: key);

  @override
  State<_LoggedInPage> createState() => _LoggedInPageState();
}

class _LoggedInPageState extends State<_LoggedInPage> {
  int _currentTab = 0;

  List<_TabDefinition> get _tabs => <_TabDefinition>[
        _TabDefinition(
          content: const OverviewTab(),
          bottomNavigationBarItem: BottomNavigationBarItem(
            icon: const Icon(Icons.dashboard),
            label: AppLocalizations.of(context)!.overview,
          ),
        ),
        _TabDefinition(
          content: ScheduleTab(),
          bottomNavigationBarItem: BottomNavigationBarItem(
            icon: const Icon(Icons.schedule),
            label: AppLocalizations.of(context)!.schedule,
          ),
        ),
        _TabDefinition(
          content: const DetailsTab(),
          bottomNavigationBarItem: BottomNavigationBarItem(
            icon: const Icon(FontAwesomeIcons.chartArea),
            label: AppLocalizations.of(context)!.details,
          ),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.appName),
        actions: <Widget>[
          IconButton(
            onPressed: _signOut,
            icon: const Icon(Icons.logout),
            tooltip: AppLocalizations.of(context)!.signOut,
          ),
        ],
      ),
      body: _tabs[_currentTab].content,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTab,
        items: _tabs
            .map((_TabDefinition tab) => tab.bottomNavigationBarItem)
            .toList(),
        onTap: (int index) {
          setState(() {
            _currentTab = index;
          });
        },
      ),
    );
  }

  Future<void> _signOut() async {
    FirebaseAuth.instance.signOut();
    Navigator.of(context).pushNamed(LoginPage.route);
  }
}
