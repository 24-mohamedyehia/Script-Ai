import 'package:flutter/material.dart';
import 'welcome_screen.dart'; 
void main() {
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
