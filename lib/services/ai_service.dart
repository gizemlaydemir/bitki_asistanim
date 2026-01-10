import 'dart:convert';
import 'package:flutter/foundation.dart';
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
    final uri = Uri.parse('$_baseUrl/plant-advice');

    final pn = plantName.trim();
    final pr = problem.trim();

    // ✅ Backend hangi key'i bekliyorsa yakalasın diye çoklu key gönderiyoruz
    final Map<String, dynamic> body = {
      // Plant name alternatifleri
      'plantName': pn,
      'plant': pn,
      'plant_name': pn,
      'bitkiAdi': pn,
      'bitki_adı': pn,

      // Problem alternatifleri (bazı backend "issue" veya "question" bekleyebilir)
      'problem': pr,
      'issue': pr,
      'question': pr,

      // Dil alternatifleri
      'language': isTr ? 'tr' : 'en',
      'lang': isTr ? 'tr' : 'en',

      'detailed': detailed,
      'userId': userId,
    };

    debugPrint('📦 AI REQUEST -> $uri');
    debugPrint('📦 AI BODY    -> ${jsonEncode(body)}');

    final resp = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    debugPrint('📩 AI STATUS  -> ${resp.statusCode}');
    debugPrint('📩 AI RAW     -> ${resp.body}');

    Map<String, dynamic> data;
    try {
      final decoded = jsonDecode(resp.body);
      data = (decoded is Map<String, dynamic>)
          ? decoded
          : <String, dynamic>{'raw': decoded};
    } catch (_) {
      throw Exception('Server response is not JSON: ${resp.body}');
    }

    final success = data['success'];
    final isSuccess = success == true || success == 'true' || success == 1;

    if (resp.statusCode != 200 || !isSuccess) {
      final msg = (data['message'] ?? data['error'] ?? 'Server error')
          .toString();
      throw Exception(msg);
    }

    final advice = (data['advice'] ?? data['result'] ?? data['message'] ?? '')
        .toString();

    int? remaining;
    int? limit;

    final r = data['remaining'];
    final l = data['limit'];

    if (r is int) remaining = r;
    if (l is int) limit = l;

    remaining ??= int.tryParse('$r');
    limit ??= int.tryParse('$l');

    return AiResponse(advice: advice, remaining: remaining, limit: limit);
  }
}
