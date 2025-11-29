import 'package:flutter/material.dart';
import 'dart:async'; // For using Timer

// Audio Recording Screen
class RecordingScreen extends StatefulWidget {
  const RecordingScreen({super.key});

  @override
  State<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen> {
  // Timer variables
  int seconds = 0;
  Timer? timer;
  bool isRecording = true; // Is recording active?
  bool isPaused = false; // Is recording paused?
  
  @override
  void initState() {
    super.initState();
    startTimer(); // Start timer when screen opens
  }
  
  // Function to start the timer
  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!isPaused) {
        setState(() {
          seconds++; // Increment seconds each time
        });
      }
    });
  }
  
  // Function to stop the timer completely
  void stopTimer() {
    timer?.cancel();
    setState(() {
      isRecording = false;
    });
  }
  
  // Function to pause/resume recording temporarily
  void pauseTimer() {
    setState(() {
      isPaused = !isPaused;
    });
  }
  
  // Convert seconds to 00:00:25 format
  String formatTime(int totalSeconds) {
    int hours = totalSeconds ~/ 3600;
    int minutes = (totalSeconds % 3600) ~/ 60;
    int secs = totalSeconds % 60;
    
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
  
  @override
  void dispose() {
    timer?.cancel(); // Stop timer when exiting the screen
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Dark blue background
      backgroundColor: const Color(0xFF1A237E),
      
      // App Bar
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            stopTimer(); // Stop timer before going back
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
      
      // Page content
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Waveform (animated lines)
            _buildWaveform(),
            
            const SizedBox(height: 60),
            
            // Timer
            Text(
              formatTime(seconds),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Recording text
            Text(
              isPaused ? 'Paused....' : 'Recording....',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 28,
                fontStyle: FontStyle.italic,
              ),
            ),
            
            const SizedBox(height: 100),
            
            // Control buttons (Stop and Pause)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Stop button
                GestureDetector(
                  onTap: () {
                    stopTimer();
                    // Can add code here to save the recording
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
                
                // Pause button
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
  
  // Function to draw the audio waveform
  Widget _buildWaveform() {
    return SizedBox(
      height: 80,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(30, (index) {
          // Random height for each line
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
