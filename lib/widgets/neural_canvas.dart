import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import '../utils/app_theme.dart';
import '../utils/pollinations_api_key.dart';

/// Style-based gradient colors for Neural Shimmer effect
const Map<String, List<Color>> _neuralGradients = {
  'Anime': [Color(0xFFFF6B9D), Color(0xFFC44FE2), Color(0xFF6366F1)],
  'Neon': [Color(0xFFFF006E), Color(0xFF8338EC), Color(0xFF3A86FF)],
  'Realistic': [Color(0xFF6B7280), Color(0xFF374151), Color(0xFF4B5563)],
  'Fantasy': [Color(0xFFFCD34D), Color(0xFFA855F7), Color(0xFF14B8A6)],
  'Cyberpunk': [Color(0xFF00F5FF), Color(0xFFFF00FF), Color(0xFFFFFF00)],
  'Watercolor': [Color(0xFF93C5FD), Color(0xFFFDA4AF), Color(0xFF86EFAC)],
  'Oil Painting': [Color(0xFFA78BFA), Color(0xFFFB923C), Color(0xFFFFD700)],
  'Dark': [Color(0xFF1F2937), Color(0xFF4C1D95), Color(0xFF111827)],
  'Minimalist': [Color(0xFFE5E7EB), Color(0xFFF9FAFB), Color(0xFFD1D5DB)],
  'Vintage': [Color(0xFFD4A574), Color(0xFFF5DEB3), Color(0xFFDEB887)],
};

class NeuralCanvas extends StatefulWidget {
  final String? imageUrl;
  final bool isLoading;
  final String style;
  final String? loadingStep;
  final double aspectRatio;
  final VoidCallback? onTap;

  const NeuralCanvas({
    super.key,
    this.imageUrl,
    required this.isLoading,
    required this.style,
    this.loadingStep,
    this.aspectRatio = 9 / 16,
    this.onTap,
  });

  @override
  State<NeuralCanvas> createState() => _NeuralCanvasState();
}

class _NeuralCanvasState extends State<NeuralCanvas>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _revealController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _blurAnimation;
  late Animation<double> _scaleAnimation;
  bool _imageLoaded = false;

  @override
  void initState() {
    super.initState();

    // Pulsing animation for loading state
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Reveal animation for when image loads
    _revealController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _blurAnimation = Tween<double>(begin: 25.0, end: 0.0).animate(
      CurvedAnimation(parent: _revealController, curve: Curves.easeOutCubic),
    );

    _scaleAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _revealController, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
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

  List<Color> _getStyleColors() {
    return _neuralGradients[widget.style] ??
        [AppTheme.accentViolet, AppTheme.accentMagenta, AppTheme.accentCyan];
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'main_canvas',
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            boxShadow: widget.imageUrl != null || widget.isLoading
                ? AppTheme.canvasGlowShadow
                : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: AspectRatio(
              aspectRatio: widget.aspectRatio,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Background gradient
                  _buildBackground(),

                  // Loading: Neural Shimmer
                  if (widget.isLoading) _buildNeuralShimmer(),

                  // Image with reveal animation
                  if (widget.imageUrl != null && !widget.isLoading)
                    _buildImageWithReveal(),

                  // Empty state
                  if (widget.imageUrl == null && !widget.isLoading)
                    _buildEmptyState(),

                  // Glassmorphic Progress Overlay
                  if (widget.isLoading && widget.loadingStep != null)
                    _buildProgressOverlay(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackground() {
    final colors = _getStyleColors();
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: colors
                  .map(
                    (c) => c.withOpacity(
                      widget.isLoading ? 0.3 * _pulseAnimation.value : 0.15,
                    ),
                  )
                  .toList(),
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        );
      },
    );
  }

  Widget _buildNeuralShimmer() {
    final colors = _getStyleColors();
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Shimmer(
          gradient: LinearGradient(
            colors: [
              colors[0].withOpacity(0.3 * _pulseAnimation.value),
              colors[1].withOpacity(0.5 * _pulseAnimation.value),
              colors[2].withOpacity(0.3 * _pulseAnimation.value),
            ],
            stops: const [0.0, 0.5, 1.0],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  colors[1].withOpacity(0.2),
                  colors[0].withOpacity(0.1),
                  Colors.transparent,
                ],
                radius: 1.5,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated icon
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(seconds: 2),
                    builder: (context, value, child) {
                      return Transform.rotate(
                        angle: value * 2 * 3.14159,
                        child: child,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: colors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: colors[1].withOpacity(0.5),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        size: 32,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Creating Magic...',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageWithReveal() {
    return AnimatedBuilder(
      animation: Listenable.merge([_blurAnimation, _scaleAnimation]),
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
        widget.imageUrl!,
        fit: BoxFit.cover,
        headers: {'Authorization': 'Bearer $pollinationsApiKey'},
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _onImageLoaded();
            });
            return child;
          }
          return _buildNeuralShimmer();
        },
        errorBuilder: (_, __, ___) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.broken_image_rounded,
                size: 48,
                color: Colors.white.withOpacity(0.5),
              ),
              const SizedBox(height: 8),
              Text(
                'Failed to load',
                style: TextStyle(color: Colors.white.withOpacity(0.5)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          // Gradient Border Container
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF00FFFF), // Cyan
                  Color(0xFF9D00FF), // Electric Violet
                  Color(0xFFFF00CC), // Magenta
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                // Enhanced Nebula Glow
                BoxShadow(
                  color: const Color(
                    0xFF00FFFF,
                  ).withOpacity(0.2 * _pulseAnimation.value),
                  blurRadius: 30,
                  spreadRadius: 1,
                  offset: const Offset(-5, -5),
                ),
                BoxShadow(
                  color: const Color(
                    0xFF9D00FF,
                  ).withOpacity(0.3 * _pulseAnimation.value),
                  blurRadius: 40,
                  spreadRadius: 2,
                  offset: const Offset(5, 5),
                ),
              ],
            ),
            child: Container(
              margin: const EdgeInsets.all(1.5), // Border Width
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24), // Modern 24px radius
                color: Colors.black.withOpacity(0.6), // Darker base
              ),
              clipBehavior: Clip.antiAlias,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                child: Stack(
                  children: [
                    // Background Image (Darkened)
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.7,
                        child: Image.asset(
                          'assets/hero_background.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    // Deep Space Gradient Overlay
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(
                                0xFF2D1B69,
                              ).withOpacity(0.55), // deep purple
                              const Color(
                                0xFF1A0F3C,
                              ).withOpacity(0.70), // dark indigo
                              const Color(
                                0xFF0D0821,
                              ).withOpacity(0.80), // near-black indigo
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),
                    ),
                    // Content
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 32,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Robot Avatar
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF8B5CF6,
                                  ).withOpacity(0.5),
                                  blurRadius: 24,
                                  spreadRadius: 4,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.smart_toy_rounded,
                              color: Colors.white,
                              size: 42,
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Robot name tag
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF8B5CF6).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFF8B5CF6).withOpacity(0.4),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF10B981),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'VERTEX AI  •  ONLINE',
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF8B5CF6),
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Speech bubble
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(
                                  0xFF8B5CF6,
                                ).withOpacity(0.25),
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  '"Type a prompt and watch',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.lexend(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white.withOpacity(0.95),
                                    height: 1.4,
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'the ',
                                      style: GoogleFonts.lexend(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white.withOpacity(0.95),
                                        height: 1.4,
                                      ),
                                    ),
                                    ShaderMask(
                                      shaderCallback: (bounds) =>
                                          const LinearGradient(
                                            colors: [
                                              Color(0xFF8B5CF6),
                                              Color(0xFF06B6D4),
                                            ],
                                          ).createShader(bounds),
                                      child: Text(
                                        'magic',
                                        style: GoogleFonts.lexend(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      ' happen."',
                                      style: GoogleFonts.lexend(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white.withOpacity(0.95),
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Describe your vision. I\'ll create it.',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: Colors.white.withOpacity(0.45),
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProgressOverlay() {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Animated progress indicator
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getStyleColors()[1],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Step text
                Expanded(
                  child: Text(
                    widget.loadingStep ?? 'Processing...',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                // Progress dots
                _buildProgressDots(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressDots() {
    final step = widget.loadingStep ?? '';
    int activeIndex = 0;
    if (step.contains('Painting')) activeIndex = 1;
    if (step.contains('Polishing')) activeIndex = 2;

    final colors = _getStyleColors();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        final isActive = index <= activeIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: isActive ? 10 : 8,
          height: isActive ? 10 : 8,
          margin: const EdgeInsets.only(left: 6),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive
                ? colors[index % colors.length]
                : Colors.white.withOpacity(0.3),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: colors[index % colors.length].withOpacity(0.5),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
        );
      }),
    );
  }
}
