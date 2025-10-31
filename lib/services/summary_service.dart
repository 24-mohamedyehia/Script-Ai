import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<String?> summarizeText(String text) async {
  final apiKey = dotenv.env['GROQ_API_KEY'];
  const url = 'https://api.groq.com/openai/v1/chat/completions';
  const model = "openai/gpt-oss-120b";

  final dio = Dio();

  try {
    final response = await dio.post(
      url,
      options: Options(
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
      ),
      data: {
        "model": model,
        "messages": [
          {
            "role": "system",
            "content":
                "انت مساعد مفيد يلخص النص بوضوح وإيجاز. لخص بنفس لغة النص المدخل. لا تضيف معلومات غير موجودة في النص."
          },
          {
            "role": "user",
            "content": "لخص هذا النص:\n$text"
          }
        ],
      },
    );

    if (response.statusCode == 200) {
      final summary = response.data['choices'][0]['message']['content'];
      return summary;
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
