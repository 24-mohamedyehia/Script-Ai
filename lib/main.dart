import 'package:flutter/material.dart';
import 'welcome_screen.dart'; 
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print('Error loading .env file: $e');
  }
  runApp(const ScribeAIApp());
}

class ScribeAIApp extends StatelessWidget {
  const ScribeAIApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    
    return MaterialApp(
      title: 'ScriptAI',
      theme: ThemeData(
        primaryColor: const Color(0xFF1A237E),
        scaffoldBackgroundColor: Colors.white,
      ),
      debugShowCheckedModeBanner: false,
      home: const WelcomeScreen(),
    );
  }
}
