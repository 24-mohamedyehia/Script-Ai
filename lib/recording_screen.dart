import 'package:flutter/material.dart';
import 'dart:async';

class RecordingScreen extends StatefulWidget {
  const RecordingScreen({super.key});

  @override
  State<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen> {
  int seconds = 0;
  Timer? timer;
  bool isRecording = true;
  bool isPaused = false;
  
  @override
  void initState() {
    super.initState();
    startTimer();
  }
  
  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!isPaused) {
        setState(() {
          seconds++;
        });
      }
    });
  }
  
  void stopTimer() {
    timer?.cancel();
    setState(() {
      isRecording = false;
    });
  }
  
  void pauseTimer() {
    setState(() {
      isPaused = !isPaused;
    });
  }
  
  String formatTime(int totalSeconds) {
    int hours = totalSeconds ~/ 3600;
    int minutes = (totalSeconds % 3600) ~/ 60;
    int secs = totalSeconds % 60;
    
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
  
  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

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
            stopTimer();
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
      
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildWaveform(),
            
            const SizedBox(height: 60),
            
            Text(
              formatTime(seconds),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 30),
            
            Text(
              isPaused ? 'Paused....' : 'Recording....',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 28,
                fontStyle: FontStyle.italic,
              ),
            ),
            
            const SizedBox(height: 100),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    stopTimer();
                  },
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Container(
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                  ),
                ),
                
                GestureDetector(
                  onTap: pauseTimer,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 8,
                            height: 30,
                            color: Colors.black,
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 8,
                            height: 30,
                            color: Colors.black,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildWaveform() {
    return SizedBox(
      height: 80,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(30, (index) {
          double height = (index % 3 == 0) ? 60.0 : 
                        (index % 2 == 0) ? 40.0 : 20.0;
          
          return Container(
            width: 3,
            height: height,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: isPaused 
                  ? Colors.white.withOpacity(0.3)
                  : Colors.pinkAccent.withOpacity(0.7),
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }),
      ),
    );
  }
}
