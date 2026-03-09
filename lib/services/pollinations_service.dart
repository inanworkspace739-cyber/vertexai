import 'package:http/http.dart' as http;

class PollinationsService {
  Future<(String? url, int? statusCode)> generateImage({
    required String enhancedPrompt,
    required String aspect,
    required String apiKey,
    String model = 'flux',
    int? seed,
    int retries = 2,
  }) async {
    // Determine width and height based on aspect ratio
    int width;
    int height;

    switch (aspect) {
      case 'Portrait 9:16':
        width = 1080;
        height = 1920;
        break;
      case 'Square 1:1':
        width = 1024;
        height = 1024;
        break;
      case 'Landscape 16:9':
        width = 1920;
        height = 1080;
        break;
      case 'Tablet 4:3':
        width = 1440;
        height = 1080;
        break;
      case 'Ultrawide 21:9':
        width = 2520;
        height = 1080;
        break;
      default:
        width = 1024;
        height = 1024;
    }

    final encoded = Uri.encodeComponent(enhancedPrompt);
    final baseUrl =
        'https://gen.pollinations.ai/image/$encoded?model=$model&width=$width&height=$height';
    final url = seed != null ? '$baseUrl&seed=$seed' : baseUrl;
    for (int attempt = 0; attempt <= retries; attempt++) {
      try {
        final response = await http.get(
          Uri.parse(url),
          headers: {'Authorization': 'Bearer $apiKey'},
        );
        if (response.statusCode == 200) {
          return (url, 200);
        } else if (response.statusCode >= 500 && attempt < retries) {
          await Future.delayed(const Duration(seconds: 2));
          continue;
        } else {
          return (null, response.statusCode);
        }
      } catch (_) {
        if (attempt < retries) {
          await Future.delayed(const Duration(seconds: 2));
          continue;
        }
        return (null, null);
      }
    }
    return (null, null);
  }
}
