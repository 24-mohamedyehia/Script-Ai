import 'package:flutter/services.dart' show rootBundle;
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http_parser/http_parser.dart';

Future<String?> transcribeLocalAudioWithDio() async {
  final apiKey = dotenv.env['GROQ_API_KEY']; 
  const url = "https://api.groq.com/openai/v1/audio/transcriptions";
  const model = "whisper-large-v3";

  final dio = Dio();

  try {
    final audioBytes = await rootBundle.load('assets/audio/Recording.m4a');
    final audioData = audioBytes.buffer.asUint8List();

    final formData = FormData.fromMap({
      'model': model,
      'file': MultipartFile.fromBytes(
        audioData,
        filename: 'Recording.m4a',
        contentType: MediaType('audio', 'm4a'),
      ),
    });

    final response = await dio.post(
      url,
      data: formData,
      options: Options(
        headers: {
          'Authorization': 'Bearer $apiKey',
        },
      ),
    );

    if (response.statusCode == 200) {
      return response.data['text'];
    } else {
      print('❌ Error: ${response.statusCode}');
      print('Response: ${response.data}');
      return null;
    }
  } on DioException catch (e) {
    print('⚠️ Dio Exception: $e');
    if (e.response != null) {
      print('Response data: ${e.response?.data}');
    }
    return null;
  } catch (e) {
    print('⚠️ General Exception: $e');
    return null;
  }
}
