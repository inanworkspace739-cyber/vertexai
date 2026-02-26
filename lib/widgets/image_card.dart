import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shimmer/shimmer.dart';
import '../main.dart';
import '../models/generated_image_model.dart';
import '../utils/pollinations_api_key.dart';

/// Style-based gradient colors for shimmer effect
const Map<String, List<Color>> _styleGradients = {
  'Anime': [Color(0xFFF48FB1), Color(0xFFAB47BC), Color(0xFF64B5F6)],
  'Neon': [Color(0xFF7B1FA2), Color(0xFFE91E63), Color(0xFF00BCD4)],
  'Realistic': [Color(0xFF9E9E9E), Color(0xFF616161), Color(0xFF9E9E9E)],
  'Fantasy': [Color(0xFFFFD54F), Color(0xFFAB47BC), Color(0xFF26A69A)],
  'Cyberpunk': [Color(0xFF00BCD4), Color(0xFFE91E63), Color(0xFFFFEB3B)],
  'Watercolor': [Color(0xFF90CAF9), Color(0xFFF8BBD9), Color(0xFFA5D6A7)],
  'Oil Painting': [Color(0xFF8D6E63), Color(0xFFFF8A65), Color(0xFFFFE082)],
  'Dark': [Color(0xFF424242), Color(0xFF4A148C), Color(0xFF616161)],
  'Minimalist': [Color(0xFFE0E0E0), Color(0xFFFFFFFF), Color(0xFFE0E0E0)],
  'Vintage': [Color(0xFFBCAAA4), Color(0xFFFFE082), Color(0xFFFFAB91)],
};

class ImageCard extends StatefulWidget {
  final GeneratedImageModel model;
  final String style;
  final String aspect;
  const ImageCard({
    super.key,
    required this.model,
    this.style = 'Anime',
    this.aspect = 'Phone 9:16',
  });

  @override
  State<ImageCard> createState() => _ImageCardState();
}

class _ImageCardState extends State<ImageCard>
    with SingleTickerProviderStateMixin {
  bool _isSaving = false;
  bool _imageLoaded = false;
  late AnimationController _revealController;
  late Animation<double> _blurAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _revealController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _blurAnimation = Tween<double>(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(parent: _revealController, curve: Curves.easeOutCubic),
    );
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _revealController, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _revealController.dispose();
    super.dispose();
  }

  void _onImageLoaded() {
    if (!_imageLoaded) {
      _imageLoaded = true;
      HapticFeedback.heavyImpact();
      _revealController.forward();
    }
  }

  double _getAspectRatio() {
    switch (widget.aspect) {
      case 'Phone 9:16':
        return 9 / 16;
      case 'Square 1:1':
        return 1.0;
      case 'Landscape 16:9':
        return 16 / 9;
      case 'Tablet 4:3':
        return 4 / 3;
      case 'Desktop 21:9':
        return 21 / 9;
      default:
        return 9 / 16;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.model.enhancedPrompt,
              style: const TextStyle(fontSize: 12, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: _getAspectRatio(),
                child: AnimatedBuilder(
                  animation: _revealController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: ImageFiltered(
                        imageFilter: ImageFilter.blur(
                          sigmaX: _blurAnimation.value,
                          sigmaY: _blurAnimation.value,
                        ),
                        child: child,
                      ),
                    );
                  },
                  child: Image.network(
                    widget.model.imageUrl,
                    fit: BoxFit.cover,
                    headers: {'Authorization': 'Bearer $pollinationsApiKey'},
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) {
                        // Image loaded - trigger reveal
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _onImageLoaded();
                        });
                        return child;
                      }
                      return _buildLoadingShimmer();
                    },
                    errorBuilder: (_, __, ___) =>
                        const Center(child: Icon(Icons.broken_image, size: 48)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _isSaving ? null : _downloadImage,
                icon: const Icon(Icons.download),
                label: _isSaving
                    ? const Text('Saving...')
                    : const Text('Download'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    final colors =
        _styleGradients[widget.style] ??
        [Colors.indigo.shade300, Colors.purple.shade400, Colors.pink.shade300];

    return Shimmer(
      gradient: LinearGradient(
        colors: [
          colors[0].withOpacity(0.4),
          colors[1].withOpacity(0.6),
          colors[2].withOpacity(0.4),
        ],
        stops: const [0.0, 0.5, 1.0],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors.map((c) => c.withOpacity(0.3)).toList(),
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.auto_awesome,
                size: 40,
                color: Colors.white.withOpacity(0.8),
              ),
              const SizedBox(height: 8),
              Text(
                'Loading...',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _downloadImage() async {
    setState(() => _isSaving = true);
    try {
      // Request storage permission
      PermissionStatus status;

      if (Platform.isAndroid) {
        status = await Permission.photos.request();
        if (!status.isGranted) {
          status = await Permission.storage.request();
        }
        if (!status.isGranted && !status.isLimited) {
          if (!mounted) return;
          _showPermissionDialog();
          return;
        }
      } else if (Platform.isIOS) {
        status = await Permission.photosAddOnly.request();
        if (!status.isGranted && !status.isLimited) {
          if (!mounted) return;
          _showPermissionDialog();
          return;
        }
      }

      // Download the image from URL with authentication
      final response = await http.get(
        Uri.parse(widget.model.imageUrl),
        headers: {'Authorization': 'Bearer $pollinationsApiKey'},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to download image (${response.statusCode})');
      }

      if (response.bodyBytes.isEmpty) {
        throw Exception('No image data received');
      }

      // Save to gallery
      final result = await ImageGallerySaver.saveImage(
        response.bodyBytes,
        quality: 100,
        name: 'ai_wallpaper_${DateTime.now().millisecondsSinceEpoch}',
        isReturnImagePathOfIOS: true,
      );

      if (!mounted) return;

      if (result['isSuccess'] == true || result['filePath'] != null) {
        HapticFeedback.heavyImpact();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.transparent,
            elevation: 0,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            content: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF059669), Color(0xFF10B981)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF059669).withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Saved to Photos! 📸',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Your artwork is in your gallery',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.photo_library_rounded,
                    color: Colors.white70,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        );
        // Show interstitial ad after download
        appOpenAdManager.loadInterstitialAndShow(onComplete: () {});
      } else {
        throw Exception('Failed to save to gallery');
      }
    } catch (e) {
      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          icon: const Icon(Icons.error, color: Colors.red, size: 48),
          title: const Text('Error'),
          content: Text('Save failed: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _showPermissionDialog() async {
    final shouldOpenSettings = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Required'),
        content: const Text(
          'Storage permission is required to save images. Would you like to open settings?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );

    if (shouldOpenSettings == true) {
      await openAppSettings();
    }
    setState(() => _isSaving = false);
  }
}
