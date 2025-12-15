import 'package:flutter/material.dart';
import 'app_strings.dart';
import 'services.dart';

class MeetingDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> meetingData;

  const MeetingDetailsScreen({super.key, required this.meetingData});

  @override
  State<MeetingDetailsScreen> createState() => _MeetingDetailsScreenState();
}

class _MeetingDetailsScreenState extends State<MeetingDetailsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late String _summary;
  late String _transcript;
  bool _isSummarizing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });

    _transcript = widget.meetingData['transcript'] ?? '';
    _summary = widget.meetingData['summary'] ?? '';
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _generateSummary() async {
    if (_transcript.isEmpty) {
      _showErrorDialog(AppStrings.get('error'), AppStrings.get('unexpectedError'));
      return;
    }

    setState(() => _isSummarizing = true);
    
    try {
      final result = await GroqService.summarizeText(
        _transcript, 
        AppStrings.recordLanguageCode.split('-')[0]
      );
      
      if (result != null && result.isNotEmpty) {
        await SupabaseService.updateMeetingSummary(widget.meetingData['id'], result);
        
        setState(() {
          _summary = result;
        });
        
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text(AppStrings.get('success')), backgroundColor: Colors.green)
           );
        }
      }
    } catch (e) {
       if (mounted) {
         _showErrorDialog(AppStrings.get('error'), AppStrings.get('unexpectedError'));
       }
    } finally {
      if (mounted) setState(() => _isSummarizing = false);
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: const TextStyle(color: Colors.red)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.get('ok')),
          )
        ],
      ),
    );
  }

  Widget? _buildFloatingActionButton() {
    if (_tabController.index == 0) {
      return FloatingActionButton.extended(
        onPressed: () {
          PdfService.generatePdf(
            title: widget.meetingData['title'],
            content: _transcript,
            heading: AppStrings.get('transcript'),
          );
        },
        label: Text(AppStrings.get('exportPdf')),
        icon: const Icon(Icons.picture_as_pdf),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A237E),
      );
    } 
    else if (_tabController.index == 1 && _summary.isNotEmpty) {
      return FloatingActionButton.extended(
        onPressed: () {
          PdfService.generatePdf(
            title: widget.meetingData['title'],
            content: _summary,
            heading: AppStrings.get('summary'),
          );
        },
        label: Text("${AppStrings.get('exportPdf')} (${AppStrings.get('summary')})"),
        icon: const Icon(Icons.summarize),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
      );
    }
    return null;
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
            title: Text(AppStrings.get('welcome'), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            centerTitle: true,
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.meetingData['title'], style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    Text(widget.meetingData['date'] ?? '', style: const TextStyle(color: Colors.white70, fontSize: 16)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      TabBar(
                        controller: _tabController,
                        labelColor: const Color(0xFF1A237E),
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: const Color(0xFF1A237E),
                        indicatorWeight: 3,
                        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        tabs: [
                          Tab(text: AppStrings.get('transcript')),
                          Tab(text: AppStrings.get('summary')),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildContentText(_transcript),

                            _summary.isEmpty
                                ? Center(
                                    child: _isSummarizing
                                        ? Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              const CircularProgressIndicator(color: Color(0xFF1A237E)),
                                              const SizedBox(height: 20),
                                              Text(
                                                AppStrings.get('generatingSummary'), 
                                                style: const TextStyle(color: Colors.grey, fontSize: 16)
                                              ),
                                              const SizedBox(height: 10),
                                              const Text("Powered by Groq Llama 3", style: TextStyle(color: Colors.grey, fontSize: 12)),
                                            ],
                                          )
                                        : Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(Icons.analytics_outlined, size: 60, color: Colors.grey),
                                              const SizedBox(height: 10),
                                              ElevatedButton.icon(
                                                onPressed: _generateSummary,
                                                icon: const Icon(Icons.auto_awesome, color: Colors.white),
                                                label: Text(AppStrings.get('summarizeBtn')),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: const Color(0xFF1A237E),
                                                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                                ),
                                              ),
                                            ],
                                          ),
                                  )
                                : _buildContentText(_summary),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: _buildFloatingActionButton(),
        );
      }
    );
  }

  Widget _buildContentText(String text) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 80), 
        child: SelectableText(
          text,
          style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black87),
          textAlign: AppStrings.isArabic ? TextAlign.right : TextAlign.left,
        ),
      ),
    );
  }
}