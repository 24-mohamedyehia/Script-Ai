import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'app_strings.dart';

class GroqService {
  static String get apiKey => dotenv.env['GROQ_API_KEY'] ?? '';
  
  static const String _sttModel = 'whisper-large-v3-turbo'; 
  static const String _llmModel = 'llama-3.3-70b-versatile';

  static Future<String?> summarizeText(String text, String langCode) async {
    if (apiKey.isEmpty) throw Exception("API Key missing");
    if (text.trim().isEmpty) throw Exception("Empty text");

    final url = Uri.parse('https://api.groq.com/openai/v1/chat/completions');

    final prompt = langCode == 'ar' 
        ? "لخص النص التالي (تفريغ اجتماع) في نقاط رئيسية واضحة ومباشرة باللغة العربية:\n$text"
        : "Summarize the following meeting transcript into clear key points:\n$text";

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json; charset=utf-8',
        },
        body: jsonEncode({
          'model': _llmModel,
          'messages': [
            {'role': 'user', 'content': prompt}
          ],
          'temperature': 0.5,
          'max_tokens': 1024,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['choices'][0]['message']['content'];
      } else {
        throw Exception('API Error');
      }
    } catch (e) {
      throw Exception('Summary Failed');
    }
  }

  static Future<String?> transcribeAudioFile(File audioFile) async {
    if (apiKey.isEmpty) throw Exception("API Key missing");

    if (audioFile.lengthSync() > 25 * 1024 * 1024) {
      throw Exception("File too large");
    }

    final url = Uri.parse('https://api.groq.com/openai/v1/audio/transcriptions');

    try {
      final request = http.MultipartRequest('POST', url)
        ..headers['Authorization'] = 'Bearer $apiKey'
        ..fields['model'] = _sttModel
        ..fields['language'] = AppStrings.recordLanguageCode.split('-')[0] 
        ..files.add(await http.MultipartFile.fromPath('file', audioFile.path));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['text'];
      } else {
        throw Exception('API Error');
      }
    } catch (e) {
      throw Exception("Transcription Failed");
    }
  }
}

class PdfService {
  static Future<void> generatePdf({
    required String title,
    required String content,
    required String heading,
  }) async {
    final pdf = pw.Document();
    
    final fontRegular = await PdfGoogleFonts.cairoRegular();
    final fontBold = await PdfGoogleFonts.cairoBold();
    
    final bool isArabicContent = RegExp(r'[\u0600-\u06FF]').hasMatch(content) || RegExp(r'[\u0600-\u06FF]').hasMatch(title);
    final textDirection = isArabicContent ? pw.TextDirection.rtl : pw.TextDirection.ltr;
    final textAlign = isArabicContent ? pw.TextAlign.right : pw.TextAlign.left;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(
          base: fontRegular,
          bold: fontBold,
        ),
        textDirection: textDirection, 
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Center(
                child: pw.Text(
                  title, 
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                  textDirection: textDirection
                )
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Header(
              level: 1, 
              child: pw.Text(
                heading, 
                style: pw.TextStyle(fontSize: 18, color: PdfColors.grey700, fontWeight: pw.FontWeight.bold),
                textDirection: textDirection
              )
            ),
            pw.Divider(),
            pw.SizedBox(height: 10),
            pw.Paragraph(
              text: content,
              style: const pw.TextStyle(fontSize: 12, lineSpacing: 5),
              textAlign: textAlign, 
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }
}

class SupabaseService {
  static final client = Supabase.instance.client;

  static String get currentUserId => client.auth.currentUser!.id;

  static Future<List<Map<String, dynamic>>> getCollectionsList() async {
    final data = await client
        .from('collections')
        .select()
        .eq('user_id', currentUserId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }

  static Future<void> addCollection(String title) async {
    await client.from('collections').insert({
      'user_id': currentUserId,
      'title': title,
    });
  }

  static Future<void> deleteCollection(String id) async {
    await client.from('collections').delete().eq('id', id);
  }
  
  static Future<void> updateCollection(String id, String newTitle) async {
    await client.from('collections').update({'title': newTitle}).eq('id', id);
  }

  static Future<List<Map<String, dynamic>>> getMeetingsList(String collectionId) async {
    final data = await client
        .from('meetings')
        .select()
        .eq('collection_id', collectionId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }

  static Future<void> saveMeeting({
    required String collectionId,
    required String title,
    required String transcript,
    String? summary,
    required String date,
  }) async {
    await client.from('meetings').insert({
      'collection_id': collectionId,
      'title': title,
      'transcript': transcript,
      'summary': summary,
      'date': date,
    });
  }

  static Future<void> updateMeetingSummary(String meetingId, String summary) async {
    await client.from('meetings').update({'summary': summary}).eq('id', meetingId);
  }

  static Future<void> deleteMeeting(String meetingId) async {
    await client.from('meetings').delete().eq('id', meetingId);
  }

  static Future<void> updateMeetingTitle(String meetingId, String newTitle) async {
    await client.from('meetings').update({'title': newTitle}).eq('id', meetingId);
  }

  static Future<void> deleteUserAccount() async {
    await client.rpc('delete_user');
    await client.auth.signOut();
  }
}