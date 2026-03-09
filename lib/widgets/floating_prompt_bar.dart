import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';

class FloatingPromptBar extends StatefulWidget {
  final String style;
  final String aspect;
  final bool isLoading;
  final String? initialPrompt;
  final ValueChanged<String> onPromptChanged;
  final ValueChanged<String> onStyleChanged;
  final ValueChanged<String> onAspectChanged;
  final VoidCallback onGenerate;

  const FloatingPromptBar({
    super.key,
    required this.style,
    required this.aspect,
    required this.isLoading,
    this.initialPrompt,
    required this.onPromptChanged,
    required this.onStyleChanged,
    required this.onAspectChanged,
    required this.onGenerate,
    this.focusNode,
  });

  final FocusNode? focusNode;

  @override
  State<FloatingPromptBar> createState() => _FloatingPromptBarState();
}

class _FloatingPromptBarState extends State<FloatingPromptBar> {
  final TextEditingController _promptController = TextEditingController();
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();

    // Set initial prompt if provided
    if (widget.initialPrompt != null && widget.initialPrompt!.isNotEmpty) {
      _promptController.text = widget.initialPrompt!;
      // Notify parent of initial prompt
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onPromptChanged(widget.initialPrompt!);
      });
    }
  }

  @override
  void dispose() {
    _promptController.dispose();
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30), // Fully rounded for floating
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.backgroundMidnight.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 40,
                offset: const Offset(0, 10),
              ),
              // Subtle inner glow
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Row 1: Full-width Text Input
              TextField(
                controller: _promptController,
                focusNode: _focusNode,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                  shadows: [
                    Shadow(
                      color: Colors.black45,
                      blurRadius: 4,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                maxLines: null,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  hintText: 'Describe your dream...',
                  hintStyle: TextStyle(color: AppTheme.textMuted, fontSize: 16),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
                  filled: false,
                ),
                onChanged: widget.onPromptChanged,
                onSubmitted: (_) {
                  if (!widget.isLoading) {
                    widget.onGenerate();
                  }
                },
              ),

              // Row 2: Action Chips & Generate Button
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 4, 24, 34),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Left: Action Chips
                    Row(
                      children: [
                        _buildActionChip(
                          icon: Icons.palette_rounded,
                          label: widget.style,
                          color: AppTheme.premiumGrey,
                          onTap: _showStylePicker,
                        ),
                        const SizedBox(width: 10),
                        _buildActionChip(
                          icon: Icons.aspect_ratio_rounded,
                          label: widget.aspect.split(' ').last,
                          color: AppTheme.premiumGrey,
                          onTap: _showAspectPicker,
                        ),
                      ],
                    ),

                    // Right: Glowing Generate Button
                    _buildGlowingGenerateButton(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionChip({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppTheme.geniusGrey, size: 16),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlowingGenerateButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        if (!widget.isLoading) {
          widget.onGenerate();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 12,
        ), // Larger touch area
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.accentViolet.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: widget.isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Generate',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      letterSpacing: 0.5,
                      shadows: [
                        Shadow(
                          color: Colors.black45,
                          blurRadius: 2,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                    size: 18,
                    shadows: [
                      Shadow(
                        color: Colors.black45,
                        blurRadius: 2,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }

  void _showStylePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent, // Crucial for glassmorphism
      isScrollControlled: true,
      builder: (context) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(25),
                ),
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withOpacity(0.5),
                    width: 1.5,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 30,
                    offset: const Offset(0, -10),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle indicator
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const Text(
                    'Select Style',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ...stylePresets.map((style) {
                    final isSelected = style == widget.style;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withOpacity(0.15)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        border: isSelected
                            ? Border.all(
                                color: AppTheme.accentViolet.withOpacity(0.5),
                              )
                            : null,
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        title: Text(
                          style,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.white70,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(
                                Icons.check_circle,
                                color: AppTheme.accentViolet,
                              )
                            : null,
                        onTap: () {
                          widget.onStyleChanged(style);
                          Navigator.pop(context);
                        },
                      ),
                    );
                  }),
                  const SizedBox(height: 20), // Bottom padding
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showAspectPicker() {
    const aspects = [
      'Phone 9:16',
      'Square 1:1',
      'Landscape 16:9',
      'Tablet 4:3',
      'Desktop 21:9',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(25),
                ),
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withOpacity(0.5),
                    width: 1.5,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 30,
                    offset: const Offset(0, -10),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const Text(
                    'Select Aspect Ratio',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ...aspects.map((aspect) {
                    final isSelected = aspect == widget.aspect;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withOpacity(0.15)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        border: isSelected
                            ? Border.all(
                                color: const Color(0xFF00FFFF).withOpacity(0.5),
                              )
                            : null,
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        title: Text(
                          aspect,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.white70,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(
                                Icons.check_circle,
                                color: Color(0xFF00FFFF),
                              )
                            : null,
                        onTap: () {
                          widget.onAspectChanged(aspect);
                          Navigator.pop(context);
                        },
                      ),
                    );
                  }),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
