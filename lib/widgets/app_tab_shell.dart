import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../screens/case_management_screen.dart';
import '../screens/education_screen.dart';
import '../screens/emergency_response_screen.dart';
import '../screens/home_screen.dart';
import '../screens/medical_tracking_screen.dart';

class ImpactGuideTabScaffold extends StatelessWidget {
  const ImpactGuideTabScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    return defaultTargetPlatform == TargetPlatform.iOS ? const _IosTabScaffold() : const _MaterialTabScaffold();
  }
}

class _MaterialTabScaffold extends StatefulWidget {
  const _MaterialTabScaffold();

  @override
  State<_MaterialTabScaffold> createState() => _MaterialTabScaffoldState();
}

class _MaterialTabScaffoldState extends State<_MaterialTabScaffold> {
  int _index = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = const [
      HomePage(),
      EmergencyResponseScreen(),
      MedicalTrackingScreen(),
      CaseManagementScreen(),
      EducationScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.warning_amber_outlined), selectedIcon: Icon(Icons.warning_amber), label: 'Accident'),
          NavigationDestination(icon: Icon(Icons.medical_services_outlined), selectedIcon: Icon(Icons.medical_services), label: 'Medical'),
          NavigationDestination(icon: Icon(Icons.description_outlined), selectedIcon: Icon(Icons.description), label: 'Reports'),
          NavigationDestination(icon: Icon(Icons.school_outlined), selectedIcon: Icon(Icons.school), label: 'Education'),
        ],
      ),
    );
  }
}

class _IosTabScaffold extends StatelessWidget {
  const _IosTabScaffold();

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.house), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.exclamationmark_triangle), label: 'Accident'),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.heart), label: 'Medical'),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.doc_text), label: 'Reports'),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.book), label: 'Education'),
        ],
        backgroundColor: CupertinoColors.systemBackground,
        activeColor: CupertinoColors.activeBlue,
        inactiveColor: CupertinoColors.inactiveGray,
      ),
      tabBuilder: (context, index) {
        late final Widget page;
        switch (index) {
          case 0:
            page = const HomePage();
            break;
          case 1:
            page = const EmergencyResponseScreen();
            break;
          case 2:
            page = const MedicalTrackingScreen();
            break;
          case 3:
            page = const CaseManagementScreen();
            break;
          case 4:
          default:
            page = const EducationScreen();
            break;
        }
        return CupertinoTabView(builder: (context) => page);
      },
    );
  }
}
