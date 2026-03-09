import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class GeminiService {
  final String? _apiKey = dotenv.env['AIzaSyAEcx73bn88nUI6ED0LF0FtWSSRTxVp8GA'];
  final String _apiUrl =
      dotenv.env['GEMINI_API_URL'] ??
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

  Future<String> enhancePrompt(String userPrompt, String style) async {
    // If API key missing, use a deterministic fallback enhancer.
    if ((_apiKey ?? '').isEmpty) {
      return '$style style, high detail, 4k, cinematic lighting: $userPrompt';
    }

    final instruction =
        'Enhance the following image-generation prompt for visual richness and descriptive detail in the style "$style":\n$userPrompt';

    final body = json.encode({
      'contents': [
        {
          'parts': [
            {'text': instruction},
          ],
        },
      ],
    });

    try {
      final resp = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'X-goog-api-key': _apiKey ?? '',
        },
        body: body,
      );

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        final dynamic decoded = json.decode(resp.body);
        // Try common shapes for Google Generative Language responses
        if (decoded is Map<String, dynamic>) {
          if (decoded.containsKey('candidates')) {
            final c = decoded['candidates'];
            if (c is List && c.isNotEmpty) {
              final first = c.first;
              if (first is Map && first['content'] is String) {
                return first['content'] as String;
              }
              if (first is Map && first['output'] is String) {
                return first['output'] as String;
              }
              if (first is String) return first;
            }
          }

          // Some responses may include 'outputs' with nested 'content' or 'text'
          if (decoded.containsKey('outputs')) {
            final outs = decoded['outputs'];
            if (outs is List && outs.isNotEmpty) {
              final o0 = outs.first;
              if (o0 is Map && o0['content'] is List) {
                final contentList = o0['content'] as List;
                if (contentList.isNotEmpty && contentList.first is Map) {
                  final m = contentList.first as Map<String, dynamic>;
                  if (m['text'] is String) return m['text'] as String;
                }
              }
            }
          }
        }
      }
    } catch (_) {}

    // Final fallback
    return '$style style, detailed, ultra-realistic: $userPrompt';
  }
}
