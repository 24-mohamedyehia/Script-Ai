import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'app_strings.dart';
import 'services.dart';
import 'meeting_details_screen.dart';
import 'recording_flow.dart';

class CollectionDetailsScreen extends StatefulWidget {
  final String collectionId;
  final String collectionTitle;

  const CollectionDetailsScreen({super.key, required this.collectionId, required this.collectionTitle});

  @override
  State<CollectionDetailsScreen> createState() => _CollectionDetailsScreenState();
}

class _CollectionDetailsScreenState extends State<CollectionDetailsScreen> {
  bool _isUploading = false;
  List<Map<String, dynamic>> _meetings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshMeetings();
  }

  Future<void> _refreshMeetings() async {
    if (!mounted) return;
    try {
      final data = await SupabaseService.getMeetingsList(widget.collectionId);
      if (mounted) {
        setState(() {
          _meetings = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickAndUploadAudio() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );

      if (result != null) {
        setState(() => _isUploading = true);

        PlatformFile platformFile = result.files.single;
        File file = File(platformFile.path!);
        
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppStrings.get('transcribing')), duration: const Duration(seconds: 2)));
        }
        
        final transcript = await GroqService.transcribeAudioFile(file);

        if (transcript != null && transcript.isNotEmpty) {
          final date = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());
          
          String fileName = platformFile.name;
          try {
             fileName = utf8.decode(fileName.runes.toList());
          } catch (e) {
             
          }

          if (fileName.contains('.')) {
            fileName = fileName.substring(0, fileName.lastIndexOf('.'));
          }

          await SupabaseService.saveMeeting(
            collectionId: widget.collectionId,
            title: fileName,
            transcript: transcript,
            date: date,
          );
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppStrings.get('success')), backgroundColor: Colors.green));
            _refreshMeetings();
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.get('unexpectedError')), 
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          )
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _showAddOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return ValueListenableBuilder<String>(
          valueListenable: AppStrings.languageNotifier,
          builder: (context, value, child) {
            return Container(
              padding: const EdgeInsets.all(20),
              height: 180,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppStrings.get('chooseOption'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildOptionItem(
                        icon: Icons.mic,
                        label: AppStrings.get('recordAudio'),
                        color: Colors.redAccent,
                        onTap: () async {
                          Navigator.pop(context); 
                          
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => RecordingScreen(collectionId: widget.collectionId)),
                          );

                          if (result == true) {
                            _refreshMeetings();
                          } else {
                             _refreshMeetings();
                          }
                        },
                      ),
                      _buildOptionItem(
                        icon: Icons.upload_file,
                        label: AppStrings.get('uploadAudio'),
                        color: Colors.blueAccent,
                        onTap: () {
                          Navigator.pop(context);
                          _pickAndUploadAudio();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          }
        );
      },
    );
  }

  Widget _buildOptionItem({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  void _showRenameDialog(String meetingId, String currentName) {
    final TextEditingController nameController = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) => ValueListenableBuilder<String>(
        valueListenable: AppStrings.languageNotifier,
        builder: (context, value, child) {
          return AlertDialog(
            title: Text(AppStrings.get('renameMeeting')),
            content: TextField(
              controller: nameController,
              decoration: InputDecoration(hintText: AppStrings.get('enterName')),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppStrings.get('cancel')),
              ),
              TextButton(
                onPressed: () async {
                  if (nameController.text.trim().isNotEmpty) {
                    await SupabaseService.updateMeetingTitle(meetingId, nameController.text.trim());
                    if (mounted) {
                      Navigator.pop(context);
                      _refreshMeetings();
                    }
                  }
                },
                child: Text(AppStrings.get('save')),
              ),
            ],
          );
        }
      ),
    );
  }

  void _showDeleteMeetingDialog(String meetingId) {
    showDialog(
      context: context,
      builder: (context) => ValueListenableBuilder<String>(
        valueListenable: AppStrings.languageNotifier,
        builder: (context, value, child) {
          return AlertDialog(
            title: Text(AppStrings.get('delete')),
            content: Text(AppStrings.get('confirmDelete')),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: Text(AppStrings.get('cancel'))),
              TextButton(
                onPressed: () async {
                   Navigator.pop(context);
                   try {
                     await SupabaseService.deleteMeeting(meetingId);
                     _refreshMeetings();
                   } catch (e) {
                      if (mounted) {
                         ScaffoldMessenger.of(context).showSnackBar(
                           SnackBar(content: Text(AppStrings.get('unexpectedError')), backgroundColor: Colors.red)
                         );
                      }
                   }
                },
                child: Text(AppStrings.get('delete'), style: const TextStyle(color: Colors.red)),
              ),
            ],
          );
        }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AppStrings.languageNotifier,
      builder: (context, value, child) {
        return Scaffold(
          backgroundColor: const Color(0xFF1A237E),
          resizeToAvoidBottomInset: false,
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
          body: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
                    child: Text(
                      widget.collectionTitle,
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.only(top: 20, left: 16, right: 16),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                      ),
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : RefreshIndicator(
                              onRefresh: _refreshMeetings,
                              child: _meetings.isEmpty
                                  ? ListView(
                                      children: [
                                        SizedBox(
                                          height: MediaQuery.of(context).size.height * 0.5,
                                          child: Center(child: Text(AppStrings.get('noRecordings'))),
                                        )
                                      ],
                                    )
                                  : ListView.separated(
                                      itemCount: _meetings.length,
                                      separatorBuilder: (context, index) => const Divider(color: Colors.grey),
                                      itemBuilder: (context, index) {
                                        final item = _meetings[index];
                                        return ListTile(
                                          contentPadding: EdgeInsets.zero,
                                          title: Text(
                                            item['title'],
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1A237E)),
                                          ),
                                          subtitle: Text(item['date'] ?? '', style: const TextStyle(color: Colors.grey)),
                                          onTap: () async {
                                            await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => MeetingDetailsScreen(meetingData: item),
                                              ),
                                            );
                                            _refreshMeetings();
                                          },
                                          trailing: PopupMenuButton<String>(
                                            onSelected: (value) {
                                              if (value == 'rename') {
                                                _showRenameDialog(item['id'], item['title']);
                                              } else if (value == 'delete') {
                                                _showDeleteMeetingDialog(item['id']);
                                              }
                                            },
                                            itemBuilder: (context) => [
                                              PopupMenuItem(
                                                value: 'rename',
                                                child: Row(
                                                  children: [
                                                    const Icon(Icons.edit, color: Colors.blue, size: 20),
                                                    const SizedBox(width: 8),
                                                    Text(AppStrings.get('rename')),
                                                  ],
                                                ),
                                              ),
                                              PopupMenuItem(
                                                value: 'delete',
                                                child: Row(
                                                  children: [
                                                    const Icon(Icons.delete, color: Colors.red, size: 20),
                                                    const SizedBox(width: 8),
                                                    Text(AppStrings.get('delete')),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                            ),
                    ),
                  ),
                ],
              ),
              if (_isUploading)
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(color: Colors.white),
                        const SizedBox(height: 20),
                        Text(AppStrings.get('transcribing'), style: const TextStyle(color: Colors.white, fontSize: 18)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddOptions(context),
            backgroundColor: Colors.white,
            child: const Icon(Icons.add, color: Color(0xFF1A237E), size: 30),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        );
      }
    );
  }
}