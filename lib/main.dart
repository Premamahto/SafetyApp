import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/emergency_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/role_selection_screen.dart';
import 'screens/women_dashboard_screen.dart';
import 'screens/police_dashboard_screen.dart';

/// Main entry point of the Women Safety App
/// Initializes Firebase and providers
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const WomenSafetyApp());
}

class WomenSafetyApp extends StatelessWidget {
  const WomenSafetyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => EmergencyProvider()),
      ],
      child: MaterialApp(
        title: 'Women Safety App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.red,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.red,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/role-selection': (context) => const RoleSelectionScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/women-dashboard': (context) => const WomenDashboardScreen(),
          '/police-dashboard': (context) => const PoliceDashboardScreen(),
        },
      ),
    );
  }
}
