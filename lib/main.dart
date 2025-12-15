import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home_screen.dart';
import 'app_strings.dart';
import 'login_screen.dart';
import 'welcome_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  await AppStrings.loadLanguage();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AppStrings.languageNotifier,
      builder: (context, value, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'ScriptAI',
          theme: ThemeData(
            primaryColor: const Color(0xFF1A237E),
            scaffoldBackgroundColor: const Color(0xFF1A237E),
            fontFamily: AppStrings.isArabic ? 'Cairo' : 'Roboto',
          ),
          home: const AuthWrapper(),
          builder: (context, child) {
            return Directionality(
              textDirection: AppStrings.isArabic ? TextDirection.rtl : TextDirection.ltr,
              child: child!,
            );
          },
        );
      }
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator(color: Colors.white)));
        }

        final session = snapshot.data?.session;

        if (session != null) {
          return const HomeScreen();
        } else {
          if (AppStrings.isFirstTime) {
            return const WelcomeScreen();
          } else {
            return const LoginScreen();
          }
        }
      },
    );
  }
}