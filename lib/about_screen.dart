import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A237E),
      
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'ScriptAI',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'About',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 40),
            
            const Text(
              'App version',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontStyle: FontStyle.italic,
              ),
            ),
            
            const SizedBox(height: 20),
            
            const Text(
              '0.1',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontStyle: FontStyle.italic,
              ),
            ),
            
            const SizedBox(height: 40),
            
            _buildLine(),
            const SizedBox(height: 30),
            _buildLine(),
            const SizedBox(height: 30),
            _buildLine(),
            const SizedBox(height: 30),
            _buildLine(),
            const SizedBox(height: 30),
            _buildLine(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLine() {
    return Container(
      height: 1,
      width: double.infinity,
      color: Colors.white.withOpacity(0.3),
    );
  }
}
