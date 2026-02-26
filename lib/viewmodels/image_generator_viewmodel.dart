import 'dart:async';
import 'package:flutter/material.dart';
import '../models/generated_image_model.dart';
import '../services/gemini_service.dart';
import '../services/pollinations_service.dart';
import '../utils/storage_service.dart';
import '../utils/pollinations_api_key.dart';

enum GeneratorState { idle, loading, success, error }

class ImageGeneratorViewModel extends ChangeNotifier {
  final GeminiService _gemini = GeminiService();
  final PollinationsService _pollinations = PollinationsService();
  final StorageService _storage = StorageService();

  GeneratorState _state = GeneratorState.idle;
  GeneratorState get state => _state;

  String prompt = '';
  String style = 'Anime';
  String aspect = 'Portrait 9:16';
  String model = 'flux';
  bool isAutoEnhanceEnabled = true;
  bool isRandomSeed = true;
  int fixedSeed = 0;

  String _format = 'PNG'; // Download format
  String get format => _format;
  set format(String value) {
    _format = value;
    notifyListeners();
  }

  String? errorMessage;
  String? loadingStep; // Track current generation step for UI

  GeneratedImageModel? currentImage;
  List<GeneratedImageModel> history = [];

  // Load saved preferences from storage
  Future<void> loadPreferences() async {
    final prefs = await _storage.loadPreferences();
    style = prefs['style'] ?? 'Anime';
    aspect = prefs['aspect'] ?? 'Portrait 9:16';
    model = prefs['model'] ?? 'flux';
    isAutoEnhanceEnabled = prefs['autoEnhance'] ?? true;
    isRandomSeed = prefs['isRandomSeed'] ?? true;
    fixedSeed = prefs['fixedSeed'] ?? 0;
    notifyListeners();
  }

  // Set style and auto-save to storage
  Future<void> setStyle(String newStyle) async {
    if (style != newStyle) {
      style = newStyle;
      await _saveCurrentPreferences();
      notifyListeners();
    }
  }

  // Set aspect ratio and auto-save to storage
  Future<void> setAspect(String newAspect) async {
    if (aspect != newAspect) {
      aspect = newAspect;
      await _saveCurrentPreferences();
      notifyListeners();
    }
  }

  Future<void> setModel(String newModel) async {
    if (model != newModel) {
      model = newModel;
      await _saveCurrentPreferences();
      notifyListeners();
    }
  }

  Future<void> setAutoEnhance(bool value) async {
    if (isAutoEnhanceEnabled != value) {
      isAutoEnhanceEnabled = value;
      await _saveCurrentPreferences();
      notifyListeners();
    }
  }

  Future<void> setSeedMode(bool random) async {
    if (isRandomSeed != random) {
      isRandomSeed = random;
      await _saveCurrentPreferences();
      notifyListeners();
    }
  }

  Future<void> setFixedSeed(int seed) async {
    if (fixedSeed != seed) {
      fixedSeed = seed;
      await _saveCurrentPreferences();
      notifyListeners();
    }
  }

  Future<void> _saveCurrentPreferences() async {
    await _storage.savePreferences(
      style: style,
      aspect: aspect,
      model: model,
      autoEnhance: isAutoEnhanceEnabled,
      isRandomSeed: isRandomSeed,
      fixedSeed: fixedSeed,
    );
  }

  Future<void> loadHistory() async {
    final json = await _storage.loadHistory();
    if (json != null) {
      try {
        history = GeneratedImageModel.fromJsonList(json);
      } catch (_) {
        history = [];
      }
    }
    notifyListeners();
  }

  Future<void> _saveHistory() async {
    // Save all history items without limit
    await _storage.saveHistory(GeneratedImageModel.toJsonList(history));
  }

  Future<void> generateImage() async {
    if (prompt.trim().isEmpty) {
      errorMessage = 'Please enter a prompt';
      _state = GeneratorState.error;
      notifyListeners();
      return;
    }

    _state = GeneratorState.loading;
    errorMessage = null;
    loadingStep = '✨ Analysing Prompt...';
    notifyListeners();

    try {
      String enhanced = prompt.trim();
      if (isAutoEnhanceEnabled) {
        enhanced = await _gemini.enhancePrompt(prompt.trim(), style);
      }

      loadingStep = '🎨 Painting Pixels...';
      notifyListeners();

      final seedToUse = isRandomSeed
          ? DateTime.now().millisecondsSinceEpoch % 1000000
          : fixedSeed;

      final (url, statusCode) = await _pollinations.generateImage(
        enhancedPrompt: enhanced,
        aspect: aspect,
        apiKey: pollinationsApiKey,
        model: model,
        seed: seedToUse,
      );

      loadingStep = '✨ Polishing...';
      notifyListeners();
      if (url == null) {
        loadingStep = null;
        switch (statusCode) {
          case 401:
          case 402:
          case 403:
          case 500:
          case 502:
          default:
            errorMessage =
                'The server is very busy right now. Please try again later ✨';
        }
        _state = GeneratorState.error;
        notifyListeners();
        return;
      }
      final imageModel = GeneratedImageModel(
        prompt: prompt.trim(),
        enhancedPrompt: enhanced,
        imageUrl: url,
        createdAt: DateTime.now(),
      );
      currentImage = imageModel;
      history.insert(0, imageModel);
      // No limit on history size
      await _saveHistory();
      loadingStep = null;
      _state = GeneratorState.success;
      notifyListeners();
    } catch (e) {
      errorMessage =
          'The server is very busy right now. Please try again later ✨';
      loadingStep = null;
      _state = GeneratorState.error;
      notifyListeners();
    }
  }

  Future<bool> downloadImage() async {
    // For simplicity, use GallerySaver which supports remote URL in most cases.
    try {
      final url = currentImage?.imageUrl;
      if (url == null) return false;
      // We'll import GallerySaver at call site (UI) to avoid platform checks here.
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> clearHistory() async {
    history = [];
    await _saveHistory();
    notifyListeners();
  }
}
