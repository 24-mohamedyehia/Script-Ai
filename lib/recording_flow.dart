import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import 'app_strings.dart';
import 'services.dart';

class RecordingScreen extends StatefulWidget {
  final String collectionId;
  const RecordingScreen({super.key, required this.collectionId});

  @override
  State<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen> {
  late AudioRecorder _audioRecorder;
  bool _isRecording = false;
  String? _audioPath;
  
  Timer? _timer;
  int _seconds = 0;
  
  Timer? _amplitudeTimer;
  double _currentAmplitude = 0.0;

  @override
  void initState() {
    super.initState();
    _audioRecorder = AudioRecorder();
    _initRecorder();
  }

  Future<void> _initRecorder() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permission denied')),
        );
      }
    }
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final dir = await getApplicationDocumentsDirectory();
        final fileName = 'recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
        final path = '${dir.path}/$fileName';

        const config = RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        );

        await _audioRecorder.start(config, path: path);

        setState(() {
          _isRecording = true;
          _audioPath = path;
        });

        _startTimer();
        _startAmplitudeListener();
      }
    } catch (e) {
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      _timer?.cancel();
      _amplitudeTimer?.cancel();

      setState(() {
        _isRecording = false;
        _audioPath = path;
        _currentAmplitude = 0.0;
      });

      _finishRecording();

    } catch (e) {
    }
  }

  void _finishRecording() {
    if (_audioPath == null) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ProcessingScreen(
          collectionId: widget.collectionId,
          audioFilePath: _audioPath!,
        ),
      ),
    );
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() => _seconds++);
      }
    });
  }

  void _startAmplitudeListener() {
    _amplitudeTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) async {
      final amplitude = await _audioRecorder.getAmplitude();
      if (mounted) {
        setState(() {
          _currentAmplitude = (amplitude.current + 160) / 160; 
          if (_currentAmplitude < 0) _currentAmplitude = 0;
          if (_currentAmplitude > 1) _currentAmplitude = 1;
        });
      }
    });
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '00:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _amplitudeTimer?.cancel();
    _audioRecorder.dispose();
    super.dispose();
  }

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
            title: Text(AppStrings.get('welcome'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            centerTitle: true,
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: _isRecording ? _stopRecording : _startRecording,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    width: 150 + (_isRecording ? _currentAmplitude * 40 : 0), 
                    height: 150 + (_isRecording ? _currentAmplitude * 40 : 0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _isRecording 
                              ? Colors.red.withOpacity(0.5) 
                              : Colors.black.withOpacity(0.2), 
                          blurRadius: _isRecording ? 20 : 10, 
                          spreadRadius: _isRecording ? 5 : 2
                        )
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        _isRecording ? Icons.stop : Icons.mic,
                        color: const Color(0xFFE57373),
                        size: 60,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  _formatTime(_seconds),
                  style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  _isRecording ? AppStrings.get('recording') : "Tap to record",
                  style: const TextStyle(color: Colors.white70, fontSize: 18),
                ),
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    "Powered by Groq LPU™\nUltra-fast Transcription",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    );
  }
}

class ProcessingScreen extends StatefulWidget {
  final String collectionId;
  final String audioFilePath;

  const ProcessingScreen({super.key, required this.collectionId, required this.audioFilePath});

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> {
  @override
  void initState() {
    super.initState();
    _processAudio();
  }

  Future<void> _processAudio() async {
    try {
      final file = File(widget.audioFilePath);
      
      final transcript = await GroqService.transcribeAudioFile(file);

      if (transcript == null || transcript.isEmpty) {
        throw Exception("Empty");
      }

      final date = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());
      final title = "Meeting ${DateFormat('MM/dd HH:mm').format(DateTime.now())}";
      
      await SupabaseService.saveMeeting(
        collectionId: widget.collectionId,
        title: title,
        transcript: transcript,
        date: date,
      );

      if (mounted) {
         Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ProcessDoneScreen(collectionId: widget.collectionId)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppStrings.get('unexpectedError')), backgroundColor: Colors.red));
        Navigator.pop(context); 
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AppStrings.languageNotifier,
      builder: (context, value, child) {
        return Scaffold(
          backgroundColor: const Color(0xFF1A237E),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 150, height: 150, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 8)),
                const SizedBox(height: 40),
                Text(AppStrings.get('processing'), style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                const Text("Transcribing with Whisper V3...", style: TextStyle(color: Colors.white70, fontSize: 14)),
              ],
            ),
          ),
        );
      }
    );
  }
}

class ProcessDoneScreen extends StatelessWidget {
  final String collectionId;
  const ProcessDoneScreen({super.key, required this.collectionId});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AppStrings.languageNotifier,
      builder: (context, value, child) {
        return Scaffold(
          backgroundColor: const Color(0xFF1A237E),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 150, height: 150,
                  decoration: const BoxDecoration(color: Color(0xFF00C853), shape: BoxShape.circle),
                  child: const Icon(Icons.check, color: Colors.white, size: 80),
                ),
                const SizedBox(height: 30),
                Text(AppStrings.get('processDone'), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 50),
                TextButton(
                  onPressed: () {
                     Navigator.pop(context, true); 
                  },
                  child: Text(AppStrings.get('backHome'), style: const TextStyle(color: Colors.white, fontSize: 18, decoration: TextDecoration.underline)),
                ),
              ],
            ),
          ),
        );
      }
    );
  }
}