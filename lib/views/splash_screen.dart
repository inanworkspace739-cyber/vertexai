import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';
import '../utils/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  // Typewriter effect state
  final String _targetText = "Turning words into art...";
  String _currentText = "";
  int _characterIndex = 0;
  Timer? _typewriterTimer;

  // Concept cycler state
  final List<String> _concepts = [
    "Initializing Neural Net...",
    "Loading AI Models...",
    "Dreaming up concepts...",
    "Preparing Canvas...",
  ];
  int _conceptIndex = 0;
  Timer? _conceptTimer;

  @override
  void initState() {
    super.initState();

    // Main entrance animations
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
      ),
    );

    // Continuous pulse animation for the logo
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.0, end: 10.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _mainController.forward();

    // Start typewriter effect after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      _startTypewriter();
    });

    // Start concept cycling
    _startConceptCycling();

    // After splash, show App Open Ad then navigate
    Timer(const Duration(seconds: 5), () {
      appOpenAdManager.showOnLaunch(
        onComplete: () {
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/');
          }
        },
      );
    });
  }

  void _startTypewriter() {
    _typewriterTimer = Timer.periodic(const Duration(milliseconds: 80), (
      timer,
    ) {
      if (_characterIndex < _targetText.length) {
        if (mounted) {
          setState(() {
            _currentText += _targetText[_characterIndex];
            _characterIndex++;
          });
        }
      } else {
        timer.cancel();
      }
    });
  }

  void _startConceptCycling() {
    _conceptTimer = Timer.periodic(const Duration(milliseconds: 1200), (timer) {
      if (mounted) {
        setState(() {
          _conceptIndex = (_conceptIndex + 1) % _concepts.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    _typewriterTimer?.cancel();
    _conceptTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: Stack(
        children: [
          // 1. Dynamic Background
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: const AssetImage('assets/galaxy_of_brains.png'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.6),
                    BlendMode.darken,
                  ),
                ),
              ),
            ),
          ),

          // 2. Animated Mesh/Grid Overlay (AI Theme)
          Positioned.fill(
            child: Opacity(
              opacity: 0.3,
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.5,
                    colors: [
                      AppTheme.accentViolet.withOpacity(0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 3. Main Center Content
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // LOGO with Pulse
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Container(
                          padding: const EdgeInsets.all(30),
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.accentViolet.withOpacity(0.5),
                                blurRadius: 30 + _glowAnimation.value,
                                spreadRadius: -5 + (_glowAnimation.value * 0.2),
                              ),
                              BoxShadow(
                                color: AppTheme.accentCyan.withOpacity(0.3),
                                blurRadius: 50,
                                spreadRadius: -10,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.auto_awesome,
                            size: 64,
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 40),

                    // App Name
                    Text(
                      'Vertex Ai Studio',
                      style: GoogleFonts.lexend(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                        letterSpacing: -1.0,
                        shadows: [
                          Shadow(
                            color: AppTheme.accentViolet.withOpacity(0.5),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Typewriter Subtitle
                    Container(
                      height: 24, // Fixed height to prevent jumping
                      alignment: Alignment.center,
                      child: Text(
                        _currentText,
                        style: GoogleFonts.spaceMono(
                          // Code-like font for AI feel
                          fontSize: 14,
                          color: AppTheme.accentCyan,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 4. Bottom Processing Indicator
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    // Cycling concept text
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        _concepts[_conceptIndex],
                        key: ValueKey<int>(_conceptIndex),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppTheme.textMuted,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Thin progress bar
                    Container(
                      width: 150,
                      height: 2,
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: const LinearProgressIndicator(
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.accentMagenta,
                        ),
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
}
