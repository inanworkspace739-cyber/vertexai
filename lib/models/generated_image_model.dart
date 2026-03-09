import 'dart:convert';

class GeneratedImageModel {
  final String prompt;
  final String enhancedPrompt;
  final String imageUrl;
  final DateTime createdAt;

  GeneratedImageModel({
    required this.prompt,
    required this.enhancedPrompt,
    required this.imageUrl,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'prompt': prompt,
    'enhancedPrompt': enhancedPrompt,
    'imageUrl': imageUrl,
    'createdAt': createdAt.toIso8601String(),
  };

  factory GeneratedImageModel.fromJson(Map<String, dynamic> json) {
    return GeneratedImageModel(
      prompt: json['prompt'] as String,
      enhancedPrompt: json['enhancedPrompt'] as String,
      imageUrl: json['imageUrl'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  static List<GeneratedImageModel> fromJsonList(String jsonString) {
    final List<dynamic> arr = json.decode(jsonString) as List<dynamic>;
    return arr
        .map((e) => GeneratedImageModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static String toJsonList(List<GeneratedImageModel> list) {
    final arr = list.map((e) => e.toJson()).toList();
    return json.encode(arr);
  }
}
