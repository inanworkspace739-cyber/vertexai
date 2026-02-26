import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../models/generated_image_model.dart';
import '../viewmodels/image_generator_viewmodel.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';
import '../utils/pollinations_api_key.dart';
import '../widgets/neural_canvas.dart';
import '../widgets/premium_floating_input_bar.dart';
import '../widgets/staggered_history_grid.dart';
import '../widgets/magic_generation_popup.dart';
import '../widgets/gallery_overlay.dart';

class HomeViewFantastic extends StatefulWidget {
  const HomeViewFantastic({super.key});

  @override
  State<HomeViewFantastic> createState() => _HomeViewFantasticState();
}

class _HomeViewFantasticState extends State<HomeViewFantastic>
    with SingleTickerProviderStateMixin {
  AnimationController? _backgroundController;
  Animation<double>? _backgroundAnimation;
  bool _isPromptBarVisible = true;
  bool _isSaving = false;

  void _initAnimations() {
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat(reverse: true);

    _backgroundAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _backgroundController!, curve: Curves.easeInOut),
    );
  }

  @override
  void initState() {
    super.initState();
    _initAnimations();

    // Load saved style and aspect ratio preferences
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<ImageGeneratorViewModel>();
      vm.loadPreferences();
    });
  }

  @override
  void dispose() {
    _backgroundController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ImageGeneratorViewModel>();

    // Recovery from Hot Reload state
    if (_backgroundController == null) {
      _initAnimations();
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: AppTheme.backgroundDark,
      body: Stack(
        children: [
          // ═══════════════════════════════════════════════════════════════════
          // DEEP SPACE BACKGROUND
          // ═══════════════════════════════════════════════════════════════════
          AnimatedBuilder(
            animation: _backgroundAnimation!,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.lerp(
                        const Color(0xFF050510), // Deepest Space
                        const Color(0xFF111827), // Premium Grey Base
                        _backgroundAnimation!.value,
                      )!,
                      const Color(0xFF0F172A), // Dark Slate
                      Color.lerp(
                        const Color(0xFF1E1B4B), // Deep Indigo
                        const Color(0xFF312E81),
                        _backgroundAnimation!.value,
                      )!,
                      const Color(0xFF000000), // Pure Black
                    ],
                    stops: const [0.0, 0.4, 0.8, 1.0],
                  ),
                ),
              );
            },
          ),

          // ═══════════════════════════════════════════════════════════════════
          // STARFIELD ANIMATION
          // ═══════════════════════════════════════════════════════════════════
          const Positioned.fill(child: StarfieldAnimation()),

          // ═══════════════════════════════════════════════════════════════════
          // NEBULA OVERLAY
          // ═══════════════════════════════════════════════════════════════════
          AnimatedBuilder(
            animation: _backgroundAnimation!,
            builder: (context, child) {
              return Stack(
                children: [
                  // Nebula 1 - Cosmic Magenta
                  Positioned(
                    top: -100,
                    right: -50,
                    child: Container(
                      width: 400,
                      height: 400,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppTheme.accentMagenta.withValues(alpha: 0.1),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.7],
                        ),
                      ),
                    ),
                  ),
                  // Nebula 2 - Deep Violet
                  Positioned(
                    bottom: -50,
                    left: -100,
                    child: Container(
                      width: 500,
                      height: 500,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppTheme.accentViolet.withValues(alpha: 0.08),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.7],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          // ═══════════════════════════════════════════════════════════════════
          // MAIN CONTENT
          // ═══════════════════════════════════════════════════════════════════
          SafeArea(
            child: Column(
              children: [
                // Premium App Bar with Back Button
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
                  child: Row(
                    children: [
                      // Back Button (no background)
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.pop(context);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 10,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ShaderMask(
                                shaderCallback: (bounds) =>
                                    const LinearGradient(
                                      colors: [
                                        Color(0xFFCC66FF),
                                        Color(0xFF6688FF),
                                      ],
                                    ).createShader(bounds),
                                child: const Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  color: Colors.white,
                                  size: 15,
                                ),
                              ),
                              const SizedBox(width: 6),
                              ShaderMask(
                                shaderCallback: (bounds) =>
                                    const LinearGradient(
                                      colors: [
                                        Color(0xFFCC66FF),
                                        Color(0xFF6688FF),
                                      ],
                                    ).createShader(bounds),
                                child: const Text(
                                  'Back',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),

                      // Vertex AI Logo / Title badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withValues(alpha: 0.08),
                              Colors.white.withValues(alpha: 0.03),
                            ],
                          ),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.12),
                            width: 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                            child: Row(
                              children: [
                                Container(
                                  width: 7,
                                  height: 7,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF8B5CF6),
                                        Color(0xFF06B6D4),
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(
                                          0xFF8B5CF6,
                                        ).withValues(alpha: 0.8),
                                        blurRadius: 6,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 7),
                                const Text(
                                  'AI Studio',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Canvas & History
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight:
                                constraints.maxHeight -
                                140, // Adjust for padding
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // ═════════════════════════════════════════════════════
                              // RESULT CANVAS (Smaller when empty, shows history has content)
                              // ═════════════════════════════════════════════════════
                              NeuralCanvas(
                                imageUrl: vm.currentImage?.imageUrl,
                                isLoading: vm.state == GeneratorState.loading,
                                style: vm.style,
                                loadingStep: vm.loadingStep,
                                aspectRatio:
                                    vm.currentImage != null ||
                                        vm.state == GeneratorState.loading
                                    ? _getAspectRatio(vm.aspect) *
                                          1.3 // Slightly smaller
                                    : 3 / 4, // Taller aspect for empty state card
                                onTap: () {
                                  // Focus the prompt bar when empty state is tapped
                                  if (vm.currentImage == null &&
                                      vm.state != GeneratorState.loading) {
                                    HapticFeedback.mediumImpact();
                                    setState(() => _isPromptBarVisible = true);
                                  }
                                },
                              ),

                              // ═════════════════════════════════════════════════════
                              // DOWNLOAD BUTTON (Shows when image is ready)
                              // ═════════════════════════════════════════════════════
                              if (vm.currentImage != null &&
                                  vm.state != GeneratorState.loading)
                                _buildDownloadSection(context, vm),

                              const SizedBox(height: 24),

                              // ═════════════════════════════════════════════════════
                              // HISTORY PREVIEW SECTION (Show 4 items max)
                              // ═════════════════════════════════════════════════════
                              if (vm.history.isNotEmpty) ...[
                                _buildSectionHeader(
                                  context,
                                  'Your Creations',
                                  '${vm.history.length} artworks',
                                  onSeeAll: () =>
                                      _showAllHistorySheet(context, vm),
                                ),
                                const SizedBox(height: 16),
                                StaggeredHistoryGrid(
                                  items: vm.history
                                      .take(4)
                                      .toList(), // Only show 4 items
                                  onItemTap: (item) {
                                    final index = vm.history.indexOf(item);
                                    _openGalleryOverlay(
                                      context,
                                      vm.history,
                                      index,
                                    );
                                  },
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // ═══════════════════════════════════════════════════════════════════
          // PREMIUM FLOATING INPUT BAR
          // ═══════════════════════════════════════════════════════════════════
          if (_isPromptBarVisible ||
              vm.currentImage != null ||
              vm.history.isNotEmpty)
            PremiumFloatingInputBar(
              selectedStyle: vm.style,
              selectedAspect: vm.aspect,
              isLoading: vm.state == GeneratorState.loading,
              onPromptChanged: (value) => vm.prompt = value,
              onStyleChanged: (value) {
                HapticFeedback.lightImpact();
                vm.setStyle(value);
              },
              onAspectChanged: (value) {
                HapticFeedback.lightImpact();
                vm.setAspect(value);
              },
              onGenerate: () async {
                HapticFeedback.mediumImpact();
                // Validate prompt is not empty
                if (vm.prompt.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Row(
                        children: [
                          Icon(
                            Icons.edit_outlined,
                            color: Colors.white,
                            size: 18,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Please type a prompt first ✨',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: const Color(0xFF6C63FF),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                  return;
                }
                // Show the ad popup — generation always proceeds after
                await showMagicGenerationPopup(context);
                await vm.generateImage();
                if (vm.state == GeneratorState.error && mounted) {
                  _showErrorSnackbar(
                    context,
                    vm.errorMessage ?? 'Unknown error',
                  );
                }
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    String subtitle, {
    VoidCallback? onSeeAll,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 8),
              if (subtitle.isNotEmpty)
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textMuted.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
          if (onSeeAll != null)
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                onSeeAll();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.glassBorder),
                ),
                child: Row(
                  children: [
                    Text(
                      'See All',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: AppTheme.textSecondary,
                      size: 14,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _openGalleryOverlay(
    BuildContext context,
    List<GeneratedImageModel> items,
    int initialIndex,
  ) {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: false,
        barrierColor: Colors.transparent,
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 250),
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: GalleryOverlay(items: items, initialIndex: initialIndex),
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DOWNLOAD SECTION
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildDownloadSection(
    BuildContext context,
    ImageGeneratorViewModel vm,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        children: [
          // Format Selector
          Expanded(child: _buildFormatSelector(vm)),
          const SizedBox(width: 12),
          // Download Button
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: _isSaving ? null : () => _downloadImage(vm),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: _isSaving ? null : AppTheme.primaryGradient,
                  color: _isSaving ? AppTheme.surfaceColor : null,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _isSaving
                        ? AppTheme.glassBorder
                        : Colors.transparent,
                  ),
                  boxShadow: _isSaving
                      ? null
                      : [
                          BoxShadow(
                            color: AppTheme.accentViolet.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isSaving)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.accentViolet,
                          ),
                        ),
                      )
                    else
                      const Icon(
                        Icons.download_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    const SizedBox(width: 10),
                    Text(
                      _isSaving ? 'Saving...' : 'Download',
                      style: TextStyle(
                        color: _isSaving ? AppTheme.textMuted : Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormatSelector(ImageGeneratorViewModel vm) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.glassBorder),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: vm.format,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppTheme.textMuted,
          ),
          dropdownColor: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          items: formatOptions.map((f) {
            return DropdownMenuItem(
              value: f,
              child: Row(
                children: [
                  Icon(
                    f == 'PNG' ? Icons.image_rounded : Icons.photo_rounded,
                    size: 18,
                    color: AppTheme.accentViolet,
                  ),
                  const SizedBox(width: 8),
                  Text(f),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              HapticFeedback.lightImpact();
              vm.format = value; // Setter calls notifyListeners
            }
          },
        ),
      ),
    );
  }

  Future<void> _downloadImage(ImageGeneratorViewModel vm) async {
    if (vm.currentImage == null) return;

    setState(() => _isSaving = true);
    HapticFeedback.mediumImpact();

    try {
      // Request permission
      PermissionStatus status;
      if (Platform.isAndroid) {
        status = await Permission.photos.request();
        if (!status.isGranted) {
          status = await Permission.storage.request();
        }
      } else if (Platform.isIOS) {
        status = await Permission.photosAddOnly.request();
      } else {
        status = PermissionStatus.granted;
      }

      if (!status.isGranted && !status.isLimited) {
        if (!mounted) return;
        _showPermissionDialog();
        return;
      }

      // Download image
      final response = await http.get(
        Uri.parse(vm.currentImage!.imageUrl),
        headers: {'Authorization': 'Bearer $pollinationsApiKey'},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to download');
      }

      // Save to gallery with selected format
      final isJpg = vm.format == 'JPG';
      final result = await ImageGallerySaver.saveImage(
        response.bodyBytes,
        quality: isJpg ? 90 : 100,
        name: 'dream_canvas_${DateTime.now().millisecondsSinceEpoch}',
        isReturnImagePathOfIOS: true,
      );

      if (!mounted) return;

      if (result['isSuccess'] == true || result['filePath'] != null) {
        HapticFeedback.heavyImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Saved as ${vm.format}!',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            backgroundColor: AppTheme.accentViolet,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      } else {
        throw Exception('Save failed');
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackbar(context, 'Failed to save: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppTheme.glassBorder),
        ),
        title: const Row(
          children: [
            Icon(Icons.lock_rounded, color: AppTheme.accentViolet),
            SizedBox(width: 12),
            Text(
              'Permission Required',
              style: TextStyle(color: AppTheme.textPrimary),
            ),
          ],
        ),
        content: const Text(
          'Storage permission is needed to save images to your gallery.',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppTheme.textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentViolet,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
    setState(() => _isSaving = false);
  }

  void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showClearAllDialog(BuildContext context, ImageGeneratorViewModel vm) {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: AppTheme.glassBorder),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.delete_forever_rounded,
                color: Colors.red.shade300,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Clear All?',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: Text(
          'This will permanently delete all ${vm.history.length} artworks from your history. This action cannot be undone.',
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 14,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppTheme.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              HapticFeedback.heavyImpact();
              vm.clearHistory();
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close sheet
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      SizedBox(width: 12),
                      Text('All history cleared'),
                    ],
                  ),
                  backgroundColor: AppTheme.accentViolet,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.all(16),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text(
              'Clear All',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _showAllHistorySheet(BuildContext context, ImageGeneratorViewModel vm) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.backgroundMidnight.withValues(alpha: 0.95),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
                border: const Border(
                  top: BorderSide(color: AppTheme.glassBorder, width: 1),
                ),
              ),
              child: Column(
                children: [
                  // Handle bar
                  Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 8),
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppTheme.textMuted.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'All Creations',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            Text(
                              '${vm.history.length} artworks',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.textMuted.withValues(
                                  alpha: 0.8,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            // Clear All Button
                            GestureDetector(
                              onTap: () => _showClearAllDialog(context, vm),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.red.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.delete_outline_rounded,
                                      color: Colors.red.shade300,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Clear All',
                                      style: TextStyle(
                                        color: Colors.red.shade300,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Close Button
                            GestureDetector(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                Navigator.pop(context);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppTheme.glassBackground,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppTheme.glassBorder,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.close_rounded,
                                  color: AppTheme.textSecondary,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Grid
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: SingleChildScrollView(
                        controller: scrollController,
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          children: [
                            StaggeredHistoryGrid(
                              items: vm.history,
                              onItemTap: (item) {
                                Navigator.pop(context);
                                final index = vm.history.indexOf(item);
                                _openGalleryOverlay(context, vm.history, index);
                              },
                            ),
                            SizedBox(
                              height:
                                  MediaQuery.of(context).padding.bottom + 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  double _getAspectRatio(String aspect) {
    switch (aspect) {
      case 'Portrait 9:16':
        return 9 / 16;
      case 'Square 1:1':
        return 1.0;
      case 'Landscape 16:9':
        return 16 / 9;
      case 'Tablet 4:3':
        return 4 / 3;
      case 'Ultrawide 21:9':
        return 21 / 9;
      default:
        return 9 / 16;
    }
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// GALAXY ANIMATION CLASSES
// ═════════════════════════════════════════════════════════════════════════════

class StarfieldAnimation extends StatefulWidget {
  const StarfieldAnimation({super.key});

  @override
  State<StarfieldAnimation> createState() => _StarfieldAnimationState();
}

class _StarfieldAnimationState extends State<StarfieldAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Star> _stars = [];
  final int _starCount = 200; // More stars for galaxy feel

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat();

    final random = Random();
    for (int i = 0; i < _starCount; i++) {
      _stars.add(
        Star(
          x: random.nextDouble(),
          y: random.nextDouble(),
          size: random.nextDouble() * 2.0 + 0.5,
          opacity: random.nextDouble(),
          twinkleSpeed: random.nextDouble() * 0.8 + 0.2,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: StarPainter(_stars, _controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class Star {
  final double x;
  final double y;
  final double size;
  final double opacity;
  final double twinkleSpeed;

  Star({
    required this.x,
    required this.y,
    required this.size,
    required this.opacity,
    required this.twinkleSpeed,
  });
}

class StarPainter extends CustomPainter {
  final List<Star> stars;
  final double value;

  StarPainter(this.stars, this.value);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;

    for (var star in stars) {
      // Organic twinkling
      final t = (star.twinkleSpeed * value * 2 * pi);
      final opacityVariation = sin(t);
      final currentOpacity =
          (star.opacity * 0.5 + 0.3) + (opacityVariation * 0.2);

      paint.color = Colors.white.withValues(
        alpha: currentOpacity.clamp(0.0, 1.0),
      );

      canvas.drawCircle(
        Offset(star.x * size.width, star.y * size.height),
        star.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(StarPainter oldDelegate) => true;
}
