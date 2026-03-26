import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MAGIC GENERATION POPUP
// Shows when the user taps Generate. Displays a beautiful message and
// an optional "Watch Ad" button to support the app.
// ─────────────────────────────────────────────────────────────────────────────

/// Returns [true] only if the user earned the reward by watching the ad.
/// Returns [false] if the user tapped "Maybe later" or dismissed the popup.
Future<bool> showMagicGenerationPopup(BuildContext context) async {
  final result = await showGeneralDialog<bool>(
    context: context,
    barrierDismissible: false, // must make a choice
    barrierLabel: 'magic_popup',
    barrierColor: Colors.black.withOpacity(0.6),
    transitionDuration: const Duration(milliseconds: 450),
    transitionBuilder: (context, anim, secondAnim, child) {
      return ScaleTransition(
        scale: CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
        child: FadeTransition(opacity: anim, child: child),
      );
    },
    pageBuilder: (context, _, __) => const _MagicPopupContent(),
  );
  return result == true;
}

class _MagicPopupContent extends StatefulWidget {
  const _MagicPopupContent();

  @override
  State<_MagicPopupContent> createState() => _MagicPopupContentState();
}

class _MagicPopupContentState extends State<_MagicPopupContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  bool _adLoading = false;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  bool _rewarded = false;

  void _watchAd() async {
    setState(() => _adLoading = true);
    appOpenAdManager.loadRewardedAndShow(
      onRewarded: () {
        // User earned the reward — mark it
        _rewarded = true;
        debugPrint('[AdMob] User earned reward — generation will proceed.');
      },
      onComplete: () {
        if (mounted) {
          setState(() => _adLoading = false);
          if (_rewarded) {
            // Show thank-you snackbar then close with true
            Navigator.of(context).pop(true);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: const Color(0xFF1E1B4B),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                content: Row(
                  children: [
                    const Icon(
                      Icons.favorite,
                      color: Color(0xFFEC4899),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Thank you! Generating your art now 🎨',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            // Ad was skipped/failed — do NOT generate
            debugPrint('[AdMob] Ad not completed — generation blocked.');
            // Stay on popup so user can try again, or pop with false
            // We pop with false so user knows they need to watch
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: const Color(0xFF7C3AED),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                content: Text(
                  'Please watch the full ad to generate ✨',
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
                ),
              ),
            );
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF2D1B69).withOpacity(0.95),
                    const Color(0xFF1A0F3C).withOpacity(0.98),
                  ],
                ),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: const Color(0xFF8B5CF6).withOpacity(0.4),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B5CF6).withOpacity(0.3),
                    blurRadius: 40,
                    spreadRadius: 5,
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Animated Robot Icon ──
                  AnimatedBuilder(
                    animation: _shimmerController,
                    builder: (context, _) {
                      return Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: SweepGradient(
                            transform: GradientRotation(
                              _shimmerController.value * 6.28,
                            ),
                            colors: const [
                              Color(0xFF8B5CF6),
                              Color(0xFF06B6D4),
                              Color(0xFFEC4899),
                              Color(0xFF8B5CF6),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF8B5CF6).withOpacity(0.5),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(3),
                        child: Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF1A0F3C),
                          ),
                          child: const Icon(
                            Icons.auto_awesome_rounded,
                            color: Colors.white,
                            size: 34,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // ── Title ──
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFFCC66FF), Color(0xFF66AAFF)],
                    ).createShader(bounds),
                    child: Text(
                      'Making Magic ✨',
                      style: GoogleFonts.lexend(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── Message ──
                  Text(
                    'We\'re generating your prompt\nand creating art with love 💜',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.85),
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '— Vertex AI Studio Team',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.4),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Divider ──
                  Divider(color: Colors.white.withOpacity(0.1), height: 1),
                  const SizedBox(height: 20),

                  // ── Support Message ──
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF8B5CF6).withOpacity(0.3),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF8B5CF6).withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 2),
                          child: Text('💖', style: TextStyle(fontSize: 24)),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'Watch a quick ad to support us and keep Vertex AI Studio completely free.',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.9),
                              height: 1.4,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Watch Ad Button ──
                  SizedBox(
                    width: double.infinity,
                    child: GestureDetector(
                      onTap: _adLoading ? null : _watchAd,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF8B5CF6), Color(0xFF06B6D4)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF8B5CF6).withOpacity(0.4),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: _adLoading
                            ? const Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.play_circle_fill_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Watch Ad & Support Us',
                                    style: GoogleFonts.lexend(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
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
          ),
        ),
      ),
    );
  }
}
