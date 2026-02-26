import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../models/generated_image_model.dart';
import '../utils/app_theme.dart';
import '../utils/pollinations_api_key.dart';

class StaggeredHistoryGrid extends StatelessWidget {
  final List<GeneratedImageModel> items;
  final Function(GeneratedImageModel) onItemTap;

  const StaggeredHistoryGrid({
    super.key,
    required this.items,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return _buildEmptyState();
    }

    return MasonryGridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _HistoryGridItem(
          item: item,
          index: index,
          onTap: () => onItemTap(item),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: AppTheme.glassDecoration(borderRadius: 24),
      child: Column(
        children: [
          Icon(
            Icons.photo_library_outlined,
            size: 48,
            color: AppTheme.textMuted.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No creations yet',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your generated wallpapers will appear here',
            style: TextStyle(
              color: AppTheme.textMuted.withOpacity(0.7),
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _HistoryGridItem extends StatefulWidget {
  final GeneratedImageModel item;
  final int index;
  final VoidCallback onTap;

  const _HistoryGridItem({
    required this.item,
    required this.index,
    required this.onTap,
  });

  @override
  State<_HistoryGridItem> createState() => _HistoryGridItemState();
}

class _HistoryGridItemState extends State<_HistoryGridItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  // Determine aspect ratio from prompt or use varied ratios for visual interest
  double _getAspectRatio() {
    // Use index to vary aspect ratios for a masonry effect
    final variations = [0.75, 1.0, 0.8, 1.2, 0.9, 0.7];
    return variations[widget.index % variations.length];
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(scale: _scaleAnimation.value, child: child);
      },
      child: GestureDetector(
        onTapDown: (_) {
          setState(() => _isPressed = true);
          _hoverController.forward();
          HapticFeedback.selectionClick();
        },
        onTapUp: (_) {
          setState(() => _isPressed = false);
          _hoverController.reverse();
        },
        onTapCancel: () {
          setState(() => _isPressed = false);
          _hoverController.reverse();
        },
        onTap: () {
          HapticFeedback.lightImpact();
          widget.onTap();
        },
        child: Hero(
          tag: 'history_${widget.item.hashCode}',
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.accentViolet.withOpacity(
                    _isPressed ? 0.3 : 0.1,
                  ),
                  blurRadius: _isPressed ? 20 : 10,
                  spreadRadius: _isPressed ? 2 : 0,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  // Image
                  AspectRatio(
                    aspectRatio: _getAspectRatio(),
                    child: Image.network(
                      widget.item.imageUrl,
                      fit: BoxFit.cover,
                      headers: {'Authorization': 'Bearer $pollinationsApiKey'},
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: AppTheme.surfaceColor,
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                  : null,
                              strokeWidth: 2,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppTheme.accentViolet,
                              ),
                            ),
                          ),
                        );
                      },
                      errorBuilder: (_, __, ___) => Container(
                        color: AppTheme.surfaceColor,
                        child: const Center(
                          child: Icon(
                            Icons.broken_image_rounded,
                            color: AppTheme.textMuted,
                            size: 32,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Gradient overlay at bottom
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                      child: Text(
                        widget.item.prompt,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ),

                  // Hover/Press overlay
                  if (_isPressed)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.accentViolet.withOpacity(0.1),
                          border: Border.all(
                            color: AppTheme.accentViolet.withOpacity(0.5),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(20),
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
}
