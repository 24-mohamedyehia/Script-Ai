import 'package:flutter/material.dart';
import 'app_strings.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AppStrings.languageNotifier,
      builder: (context, value, child) {
        return Scaffold(
          backgroundColor: const Color(0xFF1A237E),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(AppStrings.get('aboutUs'),
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            centerTitle: true,
          ),
          body: Column(
            children: [
              const SizedBox(height: 20),
              const Center(
                child: Icon(
                  Icons.auto_awesome, 
                  size: 80,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "ScriptAI", 
                style: TextStyle(
                  fontSize: 24, 
                  fontWeight: FontWeight.bold, 
                  color: Colors.white,
                  letterSpacing: 1.5
                ),
              ),
              const SizedBox(height: 40),
              
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(25.0),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle(AppStrings.get('ourMission')),
                        const SizedBox(height: 10),
                        Text(
                          AppStrings.get('missionText'),
                          style: const TextStyle(color: Colors.grey, height: 1.5, fontSize: 15),
                        ),
                        const SizedBox(height: 25),
                        
                        _buildSectionTitle(AppStrings.get('version')),
                        const SizedBox(height: 10),
                        const Text(
                          "v1.0.0",
                          style: TextStyle(color: Color(0xFF1A237E), fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 25),

                        _buildSectionTitle(AppStrings.get('contactUs')),
                        const SizedBox(height: 10),
                        _buildContactRow(Icons.email, "support@scriptai.com"),
                        const SizedBox(height: 10),
                        _buildContactRow(Icons.language, "www.scriptai.com"),

                        const SizedBox(height: 40),
                        Center(
                          child: Text(
                            AppStrings.get('rights'),
                            style: TextStyle(color: Colors.grey[400], fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1A237E),
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF1A237E)),
        const SizedBox(width: 10),
        Text(
          text,
          style: const TextStyle(color: Colors.grey, fontSize: 15),
        ),
      ],
    );
  }
}