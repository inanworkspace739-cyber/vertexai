import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shimmer/shimmer.dart';
import '../utils/pollinations_api_key.dart';

/// Style-based gradient colors for shimmer effect
Map<String, List<Color>> styleGradients = {
  'Anime': [Colors.pink.shade300, Colors.purple.shade400, Colors.blue.shade300],
  'Neon': [Colors.purple.shade600, Colors.pink.shade500, Colors.cyan.shade400],
  'Realistic': [
    Colors.grey.shade400,
    Colors.grey.shade600,
    Colors.grey.shade400,
  ],
  'Fantasy': [
    Colors.amber.shade300,
    Colors.purple.shade400,
    Colors.teal.shade300,
  ],
  'Cyberpunk': [
    Colors.cyan.shade400,
    Colors.pink.shade500,
    Colors.yellow.shade400,
  ],
  'Watercolor': [
    Colors.blue.shade200,
    Colors.pink.shade200,
    Colors.green.shade200,
  ],
  'Oil Painting': [
    Colors.brown.shade300,
    Colors.orange.shade300,
    Colors.amber.shade200,
  ],
  'Dark': [Colors.grey.shade800, Colors.purple.shade900, Colors.grey.shade700],
  'Minimalist': [Colors.grey.shade300, Colors.white, Colors.grey.shade300],
  'Vintage': [
    Colors.brown.shade200,
    Colors.amber.shade200,
    Colors.orange.shade200,
  ],
};

class MagicImageContainer extends StatefulWidget {
  final String? imageUrl;
  final bool isLoading;
  final String style;
  final String? loadingStep;
  final double aspectRatio;

  const MagicImageContainer({
    super.key,
    this.imageUrl,
    required this.isLoading,
    required this.style,
    this.loadingStep,
    this.aspectRatio = 9 / 16,
  });

  @override
  State<MagicImageContainer> createState() => _MagicImageContainerState();
}

class _MagicImageContainerState extends State<MagicImageContainer>
    with TickerProviderStateMixin {
  late AnimationController _blurController;
  late AnimationController _scaleController;
  late Animation<double> _blurAnimation;
  late Animation<double> _scaleAnimation;
  bool _previousLoading = false;

  @override
  void initState() {
    super.initState();
    _blurController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _blurAnimation = Tween<double>(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(parent: _blurController, curve: Curves.easeOutCubic),
    );
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutBack),
    );
  }

  @override
  void didUpdateWidget(MagicImageContainer oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Detect when loading finishes
    if (_previousLoading && !widget.isLoading && widget.imageUrl != null) {
      _triggerRevealAnimation();
    }
    _previousLoading = widget.isLoading;
  }

  void _triggerRevealAnimation() {
    // Heavy haptic feedback when image is ready
    HapticFeedback.heavyImpact();

    _blurController.forward(from: 0);
    _scaleController.forward(from: 0);
  }

  @override
  void dispose() {
    _blurController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  List<Color> _getStyleColors() {
    return styleGradients[widget.style] ??
        [Colors.indigo.shade300, Colors.purple.shade400, Colors.pink.shade300];
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AspectRatio(
          aspectRatio: widget.aspectRatio,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _getStyleColors()
                        .map((c) => c.withOpacity(0.3))
                        .toList(),
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),

              // Shimmer Loading Effect
              if (widget.isLoading) _buildLiquidShimmer(),

              // Image with Reveal Animation
              if (widget.imageUrl != null && !widget.isLoading)
                AnimatedBuilder(
                  animation: Listenable.merge([
                    _blurController,
                    _scaleController,
                  ]),
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
                      if (loadingProgress == null) return child;
                      return _buildLiquidShimmer();
                    },
                    errorBuilder: (_, __, ___) => const Center(
                      child: Icon(
                        Icons.broken_image,
                        size: 48,
                        color: Colors.white54,
                      ),
                    ),
                  ),
                ),

              // Glassmorphic Progress Bar
              if (widget.isLoading && widget.loadingStep != null)
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: _buildGlassmorphicProgress(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLiquidShimmer() {
    final colors = _getStyleColors();
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
                size: 48,
                color: Colors.white.withOpacity(0.8),
              ),
              const SizedBox(height: 12),
              Text(
                'Creating Magic...',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlassmorphicProgress() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white.withOpacity(0.9),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.loadingStep ?? 'Processing...',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.95),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              _buildProgressDots(),
            ],
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

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(left: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index <= activeIndex
                ? Colors.white.withOpacity(0.9)
                : Colors.white.withOpacity(0.3),
          ),
        );
      }),
    );
  }
}
