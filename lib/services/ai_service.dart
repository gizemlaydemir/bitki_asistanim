import 'dart:convert';
import 'package:http/http.dart' as http;

class AiResponse {
  final String advice;
  final int? remaining;
  final int? limit;

  AiResponse({required this.advice, this.remaining, this.limit});
}

class AiService {
  static const String _baseUrl = 'http://10.0.2.2:3000'; // Android emulator

  static Future<AiResponse> plantAdvice({
    required String problem,
    String plantName = '',
    required bool isTr,
    bool detailed = false,
    String userId = 'anon',
  }) async {
    final resp = await http.post(
      Uri.parse('$_baseUrl/plant-advice'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'plantName': plantName,
        'problem': problem,
        'language': isTr ? 'tr' : 'en',
        'detailed': detailed,
        'userId': userId,
      }),
    );

    final data = jsonDecode(resp.body);

    // Server 429 döndüğünde burada da yakalayalım:
    if (resp.statusCode != 200 || data['success'] != true) {
      throw Exception(data['message'] ?? data['error'] ?? 'Server error');
    }

    return AiResponse(
      advice: (data['advice'] ?? '').toString(),
      remaining: (data['remaining'] is int) ? data['remaining'] as int : null,
      limit: (data['limit'] is int) ? data['limit'] as int : null,
    );
  }
}
