import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:impactguide/screens/auth_gate.dart';
import 'package:impactguide/services/document_service.dart';
import 'package:impactguide/services/identity_service.dart';
import 'package:impactguide/services/supabase_auth_service.dart';
import 'package:impactguide/supabase/supabase_config.dart';
import 'package:impactguide/theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Supabase initialization (provided via Dreamflow/Supabase connection).
  var supabaseInitialized = false;
  try {
    await SupabaseConfig.initialize();
    supabaseInitialized = true;
  } catch (e) {
    debugPrint('Supabase.initialize failed: $e');
  }

  SupabaseAuthService.setSupabaseInitialized(supabaseInitialized);

  // Preload camera list to avoid first-use delays and init errors
  try {
    await DocumentService.initializeCameras();
  } catch (_) {}

  // Initialize local identity (anonymous ID and optional profile)
  try {
    await IdentityService.instance.init();
  } catch (e) {
    debugPrint('IdentityService.init failed: $e');
  }
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
      home: const AuthGate(),
    );
  }
}
