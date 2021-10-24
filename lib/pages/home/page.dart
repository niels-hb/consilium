import 'package:consilium/pages/home/tab_definition.dart';
import 'package:consilium/pages/home/tabs/details.dart';
import 'package:consilium/pages/home/tabs/overview.dart';
import 'package:consilium/pages/home/tabs/schedule.dart';
import 'package:consilium/pages/login/page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomePage extends StatefulWidget {
  static const String route = '/home';

  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentTab = 0;

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
            return _getTabs()[_currentTab].content;
          }

          return Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed(LoginPage.route);
              },
              child: Text(AppLocalizations.of(context)!.signIn.toUpperCase()),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTab,
        items: _getTabs().map((tab) => tab.bottomNavigationBarItem).toList(),
        onTap: (index) {
          setState(() {
            _currentTab = index;
          });
        },
      ),
    );
  }

  List<TabDefinition> _getTabs() {
    return [
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
  }
}
