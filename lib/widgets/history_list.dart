import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/generated_image_model.dart';
import '../utils/pollinations_api_key.dart';

class HistoryList extends StatelessWidget {
  final List<GeneratedImageModel> items;
  const HistoryList({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Text('No history yet'),
        ),
      );
    }

    return Column(
      children: items
          .map(
            (item) => ListTile(
              onTap: () => _showImageDialog(context, item),
              leading: SizedBox(
                width: 56,
                height: 56,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.network(
                    item.imageUrl,
                    fit: BoxFit.cover,
                    headers: {'Authorization': 'Bearer $pollinationsApiKey'},
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      );
                    },
                    errorBuilder: (_, __, ___) =>
                        const Center(child: Icon(Icons.broken_image, size: 24)),
                  ),
                ),
              ),
              title: Text(
                item.prompt,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                item.createdAt.toLocal().toString().split('.').first,
              ),
            ),
          )
          .toList(),
    );
  }

  void _showImageDialog(BuildContext context, GeneratedImageModel item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.prompt,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: InteractiveViewer(
                  child: Center(
                    child: Image.network(
                      item.imageUrl,
                      fit: BoxFit.contain,
                      headers: {'Authorization': 'Bearer $pollinationsApiKey'},
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (_, __, ___) => const Center(
                        child: Icon(Icons.broken_image, size: 48),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: _DownloadButton(imageUrl: item.imageUrl),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DownloadButton extends StatefulWidget {
  final String imageUrl;
  const _DownloadButton({required this.imageUrl});

  @override
  State<_DownloadButton> createState() => _DownloadButtonState();
}

class _DownloadButtonState extends State<_DownloadButton> {
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: _isSaving ? null : _downloadImage,
        icon: const Icon(Icons.download),
        label: Text(_isSaving ? 'Saving...' : 'Download'),
      ),
    );
  }

  Future<void> _downloadImage() async {
    setState(() => _isSaving = true);
    try {
      // Request storage permission
      PermissionStatus status;

      if (Platform.isAndroid) {
        // For Android 13+ (API 33+), use photos permission
        // For older versions, use storage permission
        status = await Permission.photos.request();

        if (!status.isGranted) {
          // Fallback to storage permission for older Android versions
          status = await Permission.storage.request();
        }

        if (!status.isGranted && !status.isLimited) {
          if (!mounted) return;

          // Show dialog to open settings
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
          return;
        }
      } else if (Platform.isIOS) {
        // Use photosAddOnly for iOS - only needs permission to add photos, not read
        status = await Permission.photosAddOnly.request();

        if (!status.isGranted && !status.isLimited) {
          if (!mounted) return;

          // Show dialog to open settings
          final shouldOpenSettings = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Permission Required'),
              content: const Text(
                'Photos permission is required to save images. Would you like to open settings?',
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
          return;
        }
      }

      // Download the image from URL with authentication
      final response = await http.get(
        Uri.parse(widget.imageUrl),
        headers: {'Authorization': 'Bearer $pollinationsApiKey'},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to download image (${response.statusCode})');
      }

      // Verify we got image data
      if (response.bodyBytes.isEmpty) {
        throw Exception('No image data received');
      }

      // Check if response is actually image data
      final contentType = response.headers['content-type'] ?? '';
      if (!contentType.startsWith('image/')) {
        throw Exception('Response is not an image (got: $contentType)');
      }

      // Save to gallery using image_gallery_saver with proper format
      final result = await ImageGallerySaver.saveImage(
        response.bodyBytes,
        quality: 100,
        name: 'ai_wallpaper_${DateTime.now().millisecondsSinceEpoch}',
        isReturnImagePathOfIOS: true,
      );

      if (!mounted) return;

      if (result['isSuccess'] == true || result['filePath'] != null) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
            title: const Text('Success'),
            content: const Text('Image saved to gallery successfully!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Close bottom sheet
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        throw Exception(
          'Failed to save to gallery: ${result['errorMessage'] ?? 'Unknown error'}',
        );
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
}
