import 'package:consilium/pages/home/tab_definition.dart';
import 'package:consilium/pages/home/tabs/details.dart';
import 'package:consilium/pages/home/tabs/overview.dart';
import 'package:consilium/pages/home/tabs/schedule.dart';
import 'package:consilium/pages/login/page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomePage extends StatelessWidget {
  static const String route = '/home';

  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
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

  List<TabDefinition> get _tabs => [
        TabDefinition(
          content: const OverviewTab(),
          bottomNavigationBarItem: BottomNavigationBarItem(
            icon: const Icon(Icons.dashboard),
            label: AppLocalizations.of(context)!.overview,
          ),
        ),
        TabDefinition(
          content: const ScheduleTab(),
          bottomNavigationBarItem: BottomNavigationBarItem(
            icon: const Icon(Icons.schedule),
            label: AppLocalizations.of(context)!.schedule,
          ),
        ),
        TabDefinition(
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
        actions: [
          IconButton(
            onPressed: _signOut,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: _tabs[_currentTab].content,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTab,
        items: _tabs.map((tab) => tab.bottomNavigationBarItem).toList(),
        onTap: (index) {
          setState(() {
            _currentTab = index;
          });
        },
      ),
    );
  }

  void _signOut() async {
    FirebaseAuth.instance.signOut();
    Navigator.of(context).pushNamed(LoginPage.route);
  }
}
