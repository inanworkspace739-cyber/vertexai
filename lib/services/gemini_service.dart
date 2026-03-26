import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class GeminiService {
  final String? _apiKey = dotenv.env['AIzaSyAEcx73bn88nUI6ED0LF0FtWSSRTxVp8GA'];
  final String _apiUrl =
      dotenv.env['GEMINI_API_URL'] ??
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

  // Expert system prompt for hyper-realistic photography prompt engineering
  static const String _systemPrompt = '''
You are an expert Prompt Engineer specializing in hyper-realistic, authentic photography. Your task is to take a simple user request and transform it into a highly detailed prompt for an image generation API.

RULES FOR EVERY PROMPT:
1. CONTEXT & LIGHTING: Always place the subject in a natural, real-world environment (e.g., "sitting by a window", "in a cozy living room", "on a natural street"). Always specify natural lighting (e.g., "soft afternoon sunlight", "diffused natural light").
2. CAMERA DETAILS: Add specific photography terms to ensure realism. Use phrases like: "Shot on iPhone 15 Pro", "DSLR", "candid photography", "unedited", "slight film grain", "shallow depth of field".
3. TEXTURE: Emphasize raw, real textures (e.g., "detailed fur", "pores", "imperfect details") to avoid the "AI plastic" look.
4. NEGATIVE PROMPTS: Always append this exact string at the very end of the prompt to block AI artifacts: " --no 3d render, plastic, illustration, digital painting, smooth skin, glowing eyes, artificial studio lighting, over-sharpened"

OUTPUT FORMAT:
Return ONLY the optimized prompt text. Do not include any conversational filler.
''';

  Future<String> enhancePrompt(String userPrompt, String style) async {
    // If API key missing, use a deterministic fallback enhancer.
    if ((_apiKey ?? '').isEmpty) {
      return 'Candid photography of $userPrompt, $style style, natural lighting, detailed textures, shot on DSLR, unedited, slight film grain --no 3d render, plastic, illustration, digital painting, smooth skin, glowing eyes, artificial studio lighting, over-sharpened';
    }

    final instruction =
        'User style: "$style"\nUser prompt: "$userPrompt"';

    final body = json.encode({
      'contents': [
        {
          'parts': [
            {'text': instruction},
          ],
        },
      ],
      'systemInstruction': {
        'parts': [
          {'text': _systemPrompt},
        ],
      },
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
        if (decoded is Map<String, dynamic>) {
          if (decoded.containsKey('candidates')) {
            final c = decoded['candidates'];
            if (c is List && c.isNotEmpty) {
              final first = c.first;
              // Gemini response: candidates[0].content.parts[0].text
              if (first is Map && first['content'] is Map) {
                final content = first['content'] as Map;
                if (content['parts'] is List) {
                  final parts = content['parts'] as List;
                  if (parts.isNotEmpty && parts.first is Map) {
                    final text = (parts.first as Map)['text'];
                    if (text is String && text.trim().isNotEmpty) {
                      return text.trim();
                    }
                  }
                }
              }
              if (first is Map && first['content'] is String) {
                return first['content'] as String;
              }
              if (first is Map && first['output'] is String) {
                return first['output'] as String;
              }
              if (first is String) return first;
            }
          }
        }
      }
    } catch (_) {}

    // Final fallback
    return 'Candid photography of $userPrompt, $style style, natural lighting, detailed textures, shot on DSLR, unedited, slight film grain --no 3d render, plastic, illustration, digital painting, smooth skin, glowing eyes, artificial studio lighting, over-sharpened';
  }
}
