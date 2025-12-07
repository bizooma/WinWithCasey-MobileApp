import 'package:flutter/material.dart';
import './theme.dart';
import './widgets/app_tab_shell.dart';
import './screens/onboarding_screen.dart';
import './services/document_service.dart';
import './services/identity_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Preload camera list to avoid first-use delays and init errors
  try {
    await DocumentService.initializeCameras();
  } catch (_) {}
    // Initialize local identity (anonymous ID and optional profile)
    try {
      await IdentityService.instance.init();
    } catch (_) {}
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Win With CASEY',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      home: const OnboardingFlow(),
    );
  }
}
